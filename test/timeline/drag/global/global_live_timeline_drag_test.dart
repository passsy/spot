import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../timeline_drag_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  testWidgets('Global: live, without error', (tester) async {
    await liveTimelineWithoutErrorsDrag(tester, isGlobal: true);
  });
  testWidgets('Global: record, without error', (tester) async {
    await liveTimelineWithoutErrorsDrag(tester, isGlobal: true);
  });
  test('Global: live - with error, prints HTML, no duplicates', () async {
    await liveWitErrorPrintsHTMLNoDuplicates(isGlobal: true);
  });
}
