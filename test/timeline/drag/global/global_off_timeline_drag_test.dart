import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../timeline_drag_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.off;
  testWidgets('Global: off does not record', (tester) async {
    await offTimelineWithoutErrorsDrag(tester, isGlobal: true);
  });
}
