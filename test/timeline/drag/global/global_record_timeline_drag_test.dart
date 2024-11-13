import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.reportOnError;
  testWidgets('Global: reportOnError, turn off during test', (tester) async {
    await ActDragTimelineTestBodies.recordTurnOff(tester);
  });
  testWidgets('Global: reportOnError - without error', (tester) async {
    await ActDragTimelineTestBodies.recordNoError(tester);
  });
  test('Global: reportOnError, with error, prints timeline and html', () async {
    await ActDragTimelineTestBodies.recordWithErrorPrintsHTML();
  });
}
