import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../timeline_tap_test_bodies.dart' as body;

void main() {
  globalTimelineMode = TimelineMode.off;
  testWidgets('Global: off, without error', (tester) async {
    await body.offWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
}
