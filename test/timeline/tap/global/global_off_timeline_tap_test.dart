import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.off;
  testWidgets('Global timeline - Timeline off', (tester) async {
    await TimelineTestHelpers.offTimelineTest(
      tester: tester,
      isGlobalMode: true,
    );
  });
}
