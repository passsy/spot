import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

import '../util/browser/chrome.dart';

/// The timeline report in a real browser.
///
/// Everything else about the report is asserted on the rendered markup, which
/// says nothing about the JavaScript that makes it a report: the server-rendered
/// HTML looks complete even when hydration never runs. These tests open the
/// file Chrome the way a developer does and use it.
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
    expect(
      await page.evaluate<String>(
        "document.querySelector('img.thumbnail').getAttribute('src')",
      ),
      './screenshots/first.png',
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

  test('details longer than one line expand and collapse again', () async {
    final page = await _openReport();
    if (page == null) return;

    // Only the multi-line details of the first event get a collapsed box.
    const collapsedBox = "document.querySelector('.content')";
    const showMore = '.event .event-details .show-more';

    expect(
      await page.evaluate<String>('$collapsedBox.textContent'),
      contains('second line'),
    );
    expect(await page.evaluate<String>('$collapsedBox.style.maxHeight'), '25px');

    await page.click(showMore);
    await page.waitUntil(
      "$collapsedBox.style.maxHeight !== '25px'",
      description: 'the box expanded',
    );
    final expanded = await page.evaluate<String>('$collapsedBox.style.maxHeight');
    expect(int.parse(expanded.replaceAll('px', '')), greaterThan(25));
    expect(
      await page.evaluate<String>(
        "document.querySelector('$showMore').textContent",
      ),
      contains('Show less'),
    );

    await page.click(showMore);
    await page.waitUntil(
      "$collapsedBox.style.maxHeight === '25px'",
      description: 'the box collapsed again',
    );
  });

  test('clicking a screenshot opens the modal and Escape closes it', () async {
    final page = await _openReport();
    if (page == null) return;

    expect(await page.evaluate<bool>(_modalIsOpen), isFalse);

    await page.click('img.thumbnail');
    await page.waitUntil(_modalIsOpen, description: 'the modal opened');
    expect(await page.evaluate<String>(_modalScreenshot), './screenshots/first.png');

    await page.press('Escape');
    await page.waitUntil('!($_modalIsOpen)', description: 'the modal closed');
  });

  test('the arrow keys move between the screenshots in the modal', () async {
    final page = await _openReport();
    if (page == null) return;

    await page.click('img.thumbnail');
    await page.waitUntil(_modalIsOpen, description: 'the modal opened');

    await page.press('ArrowRight');
    await page.waitUntil(
      "$_modalScreenshot === './screenshots/second.png'",
      description: 'the next screenshot showed',
    );

    await page.press('ArrowLeft');
    await page.waitUntil(
      "$_modalScreenshot === './screenshots/first.png'",
      description: 'the previous screenshot showed',
    );
  });

  test('copying the test command confirms with a snackbar', () async {
    final page = await _openReport();
    if (page == null) return;

    expect(
      await page.evaluate<bool>(
        "document.querySelector('#snackbar').classList.contains('show')",
      ),
      isFalse,
    );

    await page.click('.button-spot');
    await page.waitUntil(
      "document.querySelector('#snackbar').classList.contains('show')",
      description: 'the snackbar showed',
    );
    expect(
      await page.evaluate<String>("document.querySelector('#snackbar').textContent"),
      'Test command copied to clipboard',
    );
  });
}

const String _modalIsOpen =
    "document.querySelector('.modal').classList.contains('show')";

const String _modalScreenshot =
    "document.querySelector('.modal-content img').getAttribute('src')";

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

/// Opens a report in Chrome, or returns null when the test has to skip.
Future<BrowserPage?> _openReport() async {
  final page = await openChrome();
  if (page == null) {
    markTestSkipped(
      'No Chrome available to drive, or this suite runs in a browser itself',
    );
    return null;
  }
  addTearDown(page.close);

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

/// Two events with a screenshot each, so the modal has somewhere to navigate,
/// and details over several lines, so a collapsed box exists.
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
