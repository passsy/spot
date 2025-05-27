import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../act_tap_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.off;
  group("Global: off - ", () {
    testWidgets(' without error', (tester) async {
      await ActTapTimelineTestBodies.offWithoutError(
        tester: tester,
        isGlobalMode: true,
      );
    });
  });
}
