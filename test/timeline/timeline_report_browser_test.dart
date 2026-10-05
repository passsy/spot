@TestOn('vm')
// Driving a real browser is slower than the default timeout allows for,
// especially the first start on a cold CI machine.
@Timeout(Duration(minutes: 2))
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

import '../util/browser/headless_chrome.dart';

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

    // The report has to declare its own base. Jaspr injects <base href="/">
    // into a document that declares none, which sends every screenshot to the
    // root of the file system — but only into the first document rendered in a
    // process, so asserting on the loaded image alone would only catch the
    // regression in whichever test happens to render first.
    expect(
      await page.evaluate<int>("document.querySelectorAll('base').length"),
      1,
    );
    expect(
      await page.evaluate<String>(
        "document.querySelector('base').getAttribute('href')",
      ),
      './',
    );
    // A broken image still has a src and still renders an <img>, only its
    // intrinsic size gives it away.
    expect(
      await page.evaluate<int>(
        "document.querySelector('img.thumbnail').naturalWidth",
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
    await page.click('.button-spot');
    await page.waitUntil(
      "document.querySelector('#snackbar').classList.contains('show')",
      description: 'the snackbar showed',
    );
    expect(
      await page.evaluate<String>(
        "document.querySelector('#snackbar').textContent",
      ),
      'Test command copied to clipboard',
    );
  });
}

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
    markTestSkipped('No Chrome available to drive');
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
    File('${screenshots.path}/$name.png')
        .writeAsBytesSync(img.encodePng(_screenshot()));
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
        details: 'first line\nsecond line\nthird line',
        timestamp: '2026-10-05T00:00:00.000000',
        caller: 'main test/timeline_test.dart:1:1',
        jetBrainsLink: null,
      ),
      TimelineEvent(
        eventType: 'Screenshot',
        color: 0x2196F3,
        screenshotUrl: './screenshots/second.png',
        details: 'only one line',
        timestamp: '2026-10-05T00:00:01.000000',
        caller: 'main test/timeline_test.dart:2:1',
        jetBrainsLink: null,
      ),
    ];
