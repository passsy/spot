@TestOn('vm')
// Driving a real browser is slower than the default timeout allows for,
// especially the first start on a cold CI machine.
@Timeout(Duration(minutes: 2))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

import '../util/browser/headless_chrome.dart';
import '../util/run_test_in_process.dart' as process;

/// The generated report, opened in Chrome the way a developer opens it.
///
/// The components are tested from inside the browser in
/// `timeline_app_browser_test.dart`. What is left for here is the artifact:
/// the pre-compiled bundle in `script.js.g.dart`, inlined into a self-contained
/// document that is loaded over `file:` with no server to resolve anything.
/// Every assertion below fails when the client app is kept from hydrating.
void main() {
  test('the report hydrates without errors in the console', () async {
    final page = await _openReport();
    if (page == null) return;

    expect(page.errors, isEmpty);
  });

  test('screenshots load when the report is opened as a file', () async {
    final page = await _openReport();
    if (page == null) return;

    // The report must not have a base at all. Jaspr injects <base href="/">
    // unless the document opts out, which sends every screenshot to the root
    // of the file system.
    expect(
      await page.evaluate<int>("document.querySelectorAll('base').length"),
      0,
    );
    // A broken image still has a src and still renders an <img>, only its
    // intrinsic size gives it away.
    expect(
      await page.evaluate<int>(
        "document.querySelector('img.capture-base-image').naturalWidth",
      ),
      _screenshotWidth,
    );
  });

  test('the copy button copies the test command', () async {
    final page = await _openReport();
    if (page == null) return;

    // A real click, which a synthetic MouseEvent cannot be: without a user
    // gesture the browser denies the clipboard and the button reports a
    // failure instead. This is also the one interaction here that proves the
    // handlers survived hydration of the server-rendered markup.
    await page.click('[aria-label="Copy test command"]');
    await page.waitUntil(
      "document.querySelector('#snackbar').classList.contains('show')",
      description: 'the snackbar showed',
    );
    expect(
      await page.evaluate<String>(
        "document.querySelector('#snackbar').textContent",
      ),
      'Test command copied',
    );
  });
  test('a report written by a test run shows the widget tree', () async {
    final chrome = await HeadlessChrome.launch();
    if (chrome == null) {
      markTestSkipped('Needs a browser to drive');
      return;
    }
    addTearDown(chrome.close);

    // The real thing, end to end. The other tests render events built by
    // hand, which carry their widget tree in plain. The writer compresses it
    // and stores it once per frame, and only the client app can unpack that.
    final output = await process.runTestInProcessAndCaptureOutPut(
      testFileText: () => _recordedTest,
    );
    final link = const LineSplitter()
        .convert(output!)
        .firstWhere((line) => line.contains('View timeline here: file://'));
    final report = File(link.split('file://').last);

    final page = await chrome.newPage();
    await page.open(report.uri.toString());
    await page.waitUntil(_isHydrated, description: 'the client app hydrated');
    expect(page.errors, isEmpty);

    Future<void> expectWidgetTree() async {
      await page.waitUntil(
        "document.querySelectorAll('.tree-node__row').length > 0",
        description: 'the widget tree has rows',
      );
      expect(
        await page.evaluate<String>(
          "document.querySelector('#interactive-inspector').textContent",
        ),
        contains('Scaffold'),
      );
    }

    expect(
      await page.evaluate<int>(
        "document.querySelector('img.capture-base-image').naturalWidth",
      ),
      greaterThan(0),
    );
    await page.click('#inspector-tab-widgetInspector');
    await expectWidgetTree();

    // The second assertion was made on the same frame and has no tree stored
    // with it. It shows the one stored with the first.
    await page.click('.frame-events .event-marker:last-child');
    await expectWidgetTree();

    await page.click('#inspector-tab-widgetTree');
    await page.waitUntil(
      "document.querySelector('.tree-output') !== null",
      description: 'the tree text is shown',
    );
    expect(
      await page.evaluate<String>(
        "document.querySelector('.tree-output').textContent",
      ),
      contains('Counter: 3'),
    );
  });
}

/// A passing widget test that records two assertions on one frame.
const String _recordedTest = '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('recorded test', (tester) async {
    timeline.mode = TimelineMode.always;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Counter: 3'))),
    );
    spotText('Counter: 3').existsOnce();
    spot<Scaffold>().existsOnce();
  });
}
''';

/// Jaspr hands the server state to the client in a comment node and removes it
/// while hydrating, so its absence is the one signal that the client app took
/// over the server-rendered markup.
const String _isHydrated = '''
() => {
  const comments = document.createTreeWalker(document.body, NodeFilter.SHOW_COMMENT);
  let node;
  while ((node = comments.nextNode()) !== null) {
    if ((node.nodeValue ?? '').startsWith('\$')) return false;
  }
  return true;
}
''';

/// Opens a report in a browser of its own, or returns null when the test skips.
Future<BrowserPage?> _openReport() async {
  final chrome = await HeadlessChrome.launch();
  if (chrome == null) {
    markTestSkipped(
      'Needs a browser to drive: none installed, or a CI lane that leaves '
      'these to the Linux job',
    );
    return null;
  }
  addTearDown(chrome.close);

  final page = await chrome.newPage();
  await page.open(await _writeReport());
  await page.waitUntil(_isHydrated, description: 'the client app hydrated');
  return page;
}

const int _screenshotWidth = 40;

/// Writes a report to disk the way a test run leaves one behind: an
/// `index.html` with a `screenshots` directory next to it.
Future<String> _writeReport() async {
  final dir = Directory.systemTemp.createTempSync('spot_timeline_report');
  addTearDown(() => dir.deleteSync(recursive: true));

  final screenshots = Directory('${dir.path}/screenshots')
    ..createSync(recursive: true);
  for (final name in ['first', 'second']) {
    File(
      '${screenshots.path}/$name.png',
    ).writeAsBytesSync(img.encodePng(_screenshot()));
  }

  final html = await renderTimelineWithJaspr(_events());
  final index = File('${dir.path}/index.html')..writeAsStringSync(html);
  return index.uri.toString();
}

img.Image _screenshot() {
  final image = img.Image(width: _screenshotWidth, height: 20);
  img.fill(image, color: img.ColorRgb8(255, 0, 0));
  return image;
}

List<TimelineEvent> _events() => [
  TimelineEvent(
    eventType: 'Screenshot',
    color: 0x2196F3,
    screenshotUrl: './screenshots/first.png',
    overlayUrls: const [],
    details: 'first line\nsecond line\nthird line',
    timestamp: '2026-10-05T00:00:00.000000',
    wallTimestamp: '2026-10-05T00:00:00.000000',
    caller: 'main test/timeline_test.dart:1:1',
    ideLink: null,
    ideName: null,
    sourcePath: null,
    callerLine: null,
    isFailure: false,
    widgetTree: '',
    structuredWidgetTree: const {},
    frameNumber: 1,
    renderedFrameNumber: 1,
  ),
  TimelineEvent(
    eventType: 'Screenshot',
    color: 0x2196F3,
    screenshotUrl: './screenshots/second.png',
    overlayUrls: const [],
    details: 'only one line',
    timestamp: '2026-10-05T00:00:01.000000',
    wallTimestamp: '2026-10-05T00:00:01.000000',
    caller: 'main test/timeline_test.dart:2:1',
    ideLink: null,
    ideName: null,
    sourcePath: null,
    callerLine: null,
    isFailure: false,
    widgetTree: '',
    structuredWidgetTree: const {},
    frameNumber: 2,
    renderedFrameNumber: 2,
  ),
];
