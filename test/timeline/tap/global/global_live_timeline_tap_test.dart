import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../timeline_tap_test_bodies.dart' as body;

void main() {
  globalTimelineMode = TimelineMode.live;
  testWidgets('Global: record, without error', (tester) async {
    await body.liveWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
  test('Global: live - without error, prints HTML', () async {
    await body.liveWithoutErrorPrintsHtml(
      isGlobalMode: true,
    );
  });
  test('Global: live - with error, no duplicates, prints HTML', () async {
    await body.liveWithErrorNoDuplicatesPrintsHtml(
      isGlobalMode: true,
    );
  });
  testWidgets('Global: live, turn off during test', (tester) async {
    await body.liveTurnOffDuringTest(
      isGlobalMode: true,
      tester: tester,
    );
  });
}
