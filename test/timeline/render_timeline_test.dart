import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

void main() {
  test(
    'timelines preserve relative screenshot URLs',
    () async {
      final html = await renderTimelineWithJaspr([
        TimelineEvent(
          eventType: 'Assertion',
          color: null,
          screenshotUrl: './screenshots/example.png',
          details: 'Example event',
          timestamp: '2026-08-04T00:00:00.000',
          caller: 'example_test.dart:1',
          jetBrainsLink: null,
        ),
      ]);

      expect(html, isNot(contains('<base href="/"/>')));
      expect(html, contains('<script>'));
      expect(html, isNot(contains('src="/script.js"')));
      expect(html, contains('src="./screenshots/example.png"'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'hot-restart timelines load the shared script from the server root',
    () async {
      final html = await renderTimelineWithJaspr(
        [],
        inlineScripts: false,
        hotRestart: true,
      );

      expect(html, contains('<script src="/script.js" defer></script>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'external standalone timelines use a relative client script',
    () async {
      final html = await renderTimelineWithJaspr([], inlineScripts: false);

      expect(html, contains('<script src="script.js" defer></script>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );
}
