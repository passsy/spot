import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.record;
  testWidgets('Global timeline - record, without error', (tester) async {
    await TimelineTestHelpers.recordTimelineTest(
      tester: tester,
      isGlobalMode: true,
    );
  });
}
