import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';

void main() {
  test(
    'hot-restart timelines load the shared script from the server root',
    () async {
      final html = await renderTimelineWithJaspr(
        [],
        inlineScripts: false,
        hotRestart: true,
      );

      expect(html, contains('<script src="/script.js"></script>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'screenshots stay relative to the report, not the server root',
    () async {
      final html = await renderTimelineWithJaspr([]);

      // Jaspr inserts <base href="/"> when the document declares none, which
      // sends every relative screenshot path to the root of the file system.
      expect(html, contains('<base href="./"'));
      expect(html, isNot(contains('<base href="/"')));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );
}
