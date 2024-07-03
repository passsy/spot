import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../act_tap_timeline_test_bodies.dart';

void main() {
  group('Override global timeline', () {
    testWidgets('Local: live, without error', (tester) async {
      await ActTapTimelineTestBodies.liveWithoutError(tester: tester);
    });
    testWidgets('Local: off, without error', (tester) async {
      await ActTapTimelineTestBodies.offWithoutError(tester: tester);
    });
    testWidgets('Local: live, turn off during test', (tester) async {
      await ActTapTimelineTestBodies.liveTurnOffDuringTest(tester: tester);
    });
  });

  group('Print on teardown', () {
    testWidgets('Local: record, without error', (tester) async {
      await ActTapTimelineTestBodies.recordWithoutError(tester: tester);
    });

    test('Local: record, with error', () async {
      await ActTapTimelineTestBodies.recordWithError();
    });
    test('Local: live - without error, prints HTML', () async {
      await ActTapTimelineTestBodies.liveWithoutErrorPrintsHtml();
    });
    test('Local: live - with error, no duplicates, prints HTML', () async {
      await ActTapTimelineTestBodies.liveWithErrorNoDuplicatesPrintsHtml();
    });
  });

  test('Throws when global mode is changed during test', () async {
    await ActTapTimelineTestBodies.throwOnGlobalTimelineChange(
      initialGlobalMode: TimelineMode.live,
      globalTimelineModeToSwitch: TimelineMode.record,
    );
  });
}
