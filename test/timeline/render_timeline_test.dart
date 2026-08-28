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
}
