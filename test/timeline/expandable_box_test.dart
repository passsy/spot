import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

void main() {
  test(
    'details spanning multiple lines get an expandable box',
    () async {
      final html = await renderTimelineWithJaspr([
        TimelineEvent(
          eventType: 'Assertion',
          color: 0x2196F3,
          screenshotUrl: null,
          details: 'first line\nsecond line\nthird line',
          timestamp: '2026-08-28T00:00:00.000000',
          caller: 'main file:///tmp/x.dart:1:1',
          jetBrainsLink: null,
        ),
      ]);

      expect(html, contains('class="show-more"'));
      // Only the first line is outside the collapsed <pre>.
      expect(html, contains('<pre>second line\nthird line</pre>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'single line details render without an expandable box',
    () async {
      final html = await renderTimelineWithJaspr([
        TimelineEvent(
          eventType: 'Assertion',
          color: 0x2196F3,
          screenshotUrl: null,
          details: 'only one line',
          timestamp: '2026-08-28T00:00:00.000000',
          caller: 'main file:///tmp/x.dart:1:1',
          jetBrainsLink: null,
        ),
      ]);

      expect(html, isNot(contains('class="show-more"')));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );
}
