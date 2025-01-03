import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  group('Global: live', () {
    testWidgets('turn off during test', (tester) async {
      await ActDragTimelineTestBodies.recordTurnOff(tester);
    });
    testWidgets('no error print nothing', (tester) async {
      await ActDragTimelineTestBodies.alwaysNoError(tester);
    });
    test('with error, prints timeline and html', () async {
      await ActDragTimelineTestBodies.recordWithErrorPrintsHTML();
    });
    testWidgets('without error', (tester) async {
      await ActDragTimelineTestBodies.liveWithoutError(tester);
    });
    test('without error, prints HTML, no duplicates', () async {
      await ActDragTimelineTestBodies.liveWithoutErrorPrintsHTMLNoDuplicates();
    });
    test('with error, prints HTML, no duplicates', () async {
      await ActDragTimelineTestBodies.liveWithErrorPrintsHTMLNoDuplicates();
    });
  });
}
