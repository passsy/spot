import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../act_tap_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  group("Global: live - ", () {
    testWidgets('without error', (tester) async {
      await ActTapTimelineTestBodies.liveWithoutError(
        tester: tester,
        isGlobalMode: true,
      );
    });
    test('without error, prints HTML', () async {
      await ActTapTimelineTestBodies.liveWithoutErrorPrintsHtml(
        isGlobalMode: true,
      );
    });
    test('with error, no duplicates, prints HTML', () async {
      await ActTapTimelineTestBodies.liveWithErrorNoDuplicatesPrintsHtml(
        isGlobalMode: true,
      );
    });
    testWidgets('turn off during test', (tester) async {
      await ActTapTimelineTestBodies.liveTurnOffDuringTest(
        isGlobalMode: true,
        tester: tester,
      );
    });
  });
}
