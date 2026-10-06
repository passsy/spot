@TestOn('browser')
library;

import 'package:jaspr_test/client_test.dart';
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
    testClient('clicking the capture opens the lightbox and Escape closes it', (
      tester,
    ) async {
      await _pumpReport(tester);

      expect(web.document.querySelector('.lightbox'), isNull);

      await _click(web.document.querySelector('.capture-canvas')!);

      expect(web.document.querySelector('.lightbox'), isNotNull);
      expect(_lightboxScreenshot(), './screenshots/first.png');

      await _press('Escape');

      expect(web.document.querySelector('.lightbox'), isNull);
    });

    testClient('the arrow keys move between the captures', (tester) async {
      await _pumpReport(tester);
      await _click(web.document.querySelector('.capture-canvas')!);

      await _press('ArrowRight');
      expect(_lightboxScreenshot(), './screenshots/second.png');

      await _press('ArrowLeft');
      expect(_lightboxScreenshot(), './screenshots/first.png');
    });

    testClient('the copy button reports back in a snackbar', (tester) async {
      await _pumpReport(tester);

      final snackbar = web.document.querySelector('#snackbar')!;
      expect(snackbar.classList.contains('show'), isFalse);

      await _click(
        web.document.querySelector('[aria-label="Copy test command"]')!,
      );
      // The clipboard write is asynchronous and either outcome shows the
      // snackbar. Which one it is depends on whether the browser grants the
      // clipboard to a synthetic click, so the message that confirms the copy
      // is asserted by the report test, which clicks for real.
      await _settle();

      expect(snackbar.classList.contains('show'), isTrue);
      expect(snackbar.textContent?.toLowerCase(), contains('test command'));
    });
  });
}

/// Mounts the report with two captured frames, so the lightbox has somewhere
/// to navigate.
Future<void> _pumpReport(ClientTester tester) async {
  tester.pumpComponent(
    TimelineApp(
      testName: 'a test',
      testNameWithHierarchy: 'a test',
      timelineEvents: [_event('first', frame: 1), _event('second', frame: 2)],
      sourceFiles: const {},
      renderedFrameCount: 2,
    ),
  );
  await _settle();
}

TimelineEvent _event(String screenshot, {required int frame}) => TimelineEvent(
  eventType: 'Screenshot',
  color: 0x2196F3,
  screenshotUrl: './screenshots/$screenshot.png',
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
  frameNumber: frame,
  renderedFrameNumber: frame,
);

String? _lightboxScreenshot() =>
    web.document.querySelector('.lightbox__image')?.getAttribute('src');

Future<void> _click(web.Element element) async {
  element.dispatchEvent(web.MouseEvent('click'));
  await _settle();
}

/// The report listens on the window, not on an element, so the key has to be
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
