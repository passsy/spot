import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.record;
  testWidgets('Global: record, turn off during test', (tester) async {
    await ActDragTimelineTestBodies.recordTurnOff(tester, isGlobal: true);
  });
  testWidgets('Global: record - without error', (tester) async {
    await ActDragTimelineTestBodies.recordNoError(tester, isGlobal: true);
  });
  test('Global: record, with error, prints timeline and html', () async {
    await ActDragTimelineTestBodies.recordWithErrorPrintsHTML(isGlobal: true);
  });
}
