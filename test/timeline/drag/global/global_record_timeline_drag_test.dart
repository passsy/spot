import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../timeline_drag_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.record;
  testWidgets('Global: record, turn off during test', (tester) async {
    await recordTurnOffDuringTestDrag(tester, isGlobal: true);
  });
  testWidgets('Global: record - without error', (tester) async {
    await recordTurnOffDuringTestDrag(tester, isGlobal: true);
  });
}
