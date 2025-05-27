import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.reportOnError;
  group("Global: reportOnError - ", () {
    testWidgets('turn off during test', (tester) async {
      await ActDragTimelineTestBodies.recordTurnOff(tester);
    });
    testWidgets('without error', (tester) async {
      await ActDragTimelineTestBodies.recordNoError(tester);
    });
    test('with error, prints timeline and html', () async {
      await ActDragTimelineTestBodies.recordWithErrorPrintsHTML();
    });
  });
}
