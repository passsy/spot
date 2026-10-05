@TestOn('browser')
library;

import 'package:jaspr_test/browser_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:universal_web/web.dart' as web;

/// The report's components, mounted in a real browser document.
///
/// The test code runs in the browser here, so the DOM is the typed
/// `package:web` one and events are real events. What this cannot do is
/// produce a user gesture or test the file spot actually writes — that is
/// `timeline_report_browser_test.dart`, which drives the generated report
/// from the outside.
void main() {
  group('timeline report components', () {
    testBrowser('details longer than one line expand and collapse again',
        (tester) async {
      await _pumpReport(tester);

      // Only the multi-line details of an event get a collapsed box.
      final box = web.document.querySelector('.content')! as web.HTMLElement;
      expect(box.textContent, contains('second line'));
      expect(box.style.maxHeight, '25px');

      final showMore = web.document.querySelector('.show-more')!;
      await _click(showMore);

      expect(box.style.maxHeight, isNot('25px'));
      expect(_pixels(box.style.maxHeight), greaterThan(25));
      expect(showMore.textContent, contains('Show less'));

      await _click(showMore);

      expect(box.style.maxHeight, '25px');
      expect(showMore.textContent, contains('Show more'));
    });

    testBrowser('clicking a screenshot opens the modal and Escape closes it',
        (tester) async {
      await _pumpReport(tester);

      final modal = web.document.querySelector('.modal')!;
      expect(modal.classList.contains('show'), isFalse);

      await _click(web.document.querySelector('img.thumbnail')!);

      expect(modal.classList.contains('show'), isTrue);
      expect(_modalScreenshot(), './screenshots/first.png');

      await _press('Escape');

      expect(modal.classList.contains('show'), isFalse);
    });

    testBrowser('the arrow keys move between the screenshots', (tester) async {
      await _pumpReport(tester);
      await _click(web.document.querySelector('img.thumbnail')!);

      await _press('ArrowRight');
      expect(_modalScreenshot(), './screenshots/second.png');

      await _press('ArrowLeft');
      expect(_modalScreenshot(), './screenshots/first.png');
    });

    testBrowser('the copy button reports back in a snackbar', (tester) async {
      await _pumpReport(tester);

      final snackbar = web.document.querySelector('#snackbar')!;
      expect(snackbar.classList.contains('show'), isFalse);

      await _click(web.document.querySelector('.button-spot')!);
      // The clipboard write is asynchronous and either outcome shows the
      // snackbar. Which one it is depends on whether the browser grants the
      // clipboard to a synthetic click, so the message that confirms the copy
      // is asserted by the report test, which clicks for real.
      await _settle();

      expect(snackbar.classList.contains('show'), isTrue);
      expect(snackbar.textContent, contains('test command'));
    });
  });
}

/// Mounts the report with two screenshots, so the modal has somewhere to
/// navigate, and details over several lines, so a collapsed box exists.
Future<void> _pumpReport(BrowserTester tester) async {
  tester.pumpComponent(
    TimelineApp(
      testName: 'a test',
      testNameWithHierarchy: 'a test',
      timelineEvents: [_event('first'), _event('second')],
    ),
  );
  await _settle();
}

TimelineEvent _event(String screenshot) => TimelineEvent(
      eventType: 'Screenshot',
      color: 0x2196F3,
      screenshotUrl: './screenshots/$screenshot.png',
      details: 'first line\nsecond line\nthird line',
      timestamp: '2026-10-05T00:00:00.000000',
      caller: 'main test/timeline_test.dart:1:1',
      jetBrainsLink: null,
    );

String? _modalScreenshot() =>
    web.document.querySelector('.modal-content img')?.getAttribute('src');

Future<void> _click(web.Element element) async {
  element.dispatchEvent(web.MouseEvent('click'));
  await _settle();
}

/// The modal listens on the window, not on an element, so the key has to be
/// dispatched there.
Future<void> _press(String key) async {
  web.window.dispatchEvent(
    web.KeyboardEvent('keydown', web.KeyboardEventInit(key: key)),
  );
  await _settle();
}

Future<void> _settle() async {
  await pumpEventQueue();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await pumpEventQueue();
}

int _pixels(String cssLength) =>
    int.parse(cssLength.replaceAll(RegExp('[^0-9]'), ''));
