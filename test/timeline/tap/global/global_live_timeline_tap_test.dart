import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  testWidgets('Global: record, without error', (tester) async {
    await TimelineTestHelpers.liveWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
  test('Global: live - without error, prints HTML', () async {
    await TimelineTestHelpers.liveWithoutErrorPrintsHtml(
      isGlobalMode: true,
    );
  });
  test('Global: live - with error, no duplicates, prints HTML', () async {
    await TimelineTestHelpers.liveWithErrorNoDuplicatesPrintsHtml(
      isGlobalMode: true,
    );
  });
  testWidgets('Global: live, turn off during test', (tester) async {
    await TimelineTestHelpers.liveTurnOffDuringTest(
      isGlobalMode: true,
      tester: tester,
    );
  });
}
