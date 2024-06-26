import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.off;
  testWidgets('Global: off, without error', (tester) async {
    await TimelineTestHelpers.offWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
}
