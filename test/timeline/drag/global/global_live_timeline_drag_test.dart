import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  testWidgets('Global: live, without error', (tester) async {
    await ActDragTimelineTestBodies.liveWithoutError(
      tester,
      isGlobal: true,
    );
  });
  test('Global: live - without error, prints HTML, no duplicates', () async {
    await ActDragTimelineTestBodies.liveWithoutErrorPrintsHTMLNoDuplicates(
      isGlobal: true,
    );
  });
  test('Global: live - with error, prints HTML, no duplicates', () async {
    await ActDragTimelineTestBodies.liveWithErrorPrintsHTMLNoDuplicates(
      isGlobal: true,
    );
  });
}
