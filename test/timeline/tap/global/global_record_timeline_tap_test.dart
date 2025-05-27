import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../act_tap_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.reportOnError;
  group("Global: reportOnError - ", () {
    testWidgets('without error', (tester) async {
      await ActTapTimelineTestBodies.recordWithoutError(
        tester: tester,
        isGlobalMode: true,
      );
    });
    test('with error', () async {
      await ActTapTimelineTestBodies.recordWithError(isGlobalMode: true);
    });
  });
}
