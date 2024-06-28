import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';
import '../timeline_tap_test_bodies.dart' as body;

void main() {
  globalTimelineMode = TimelineMode.record;
  testWidgets('Global: record, without error', (tester) async {
    await body.recordWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
  test('Global: record, with error', () async {
    await body.recordWithError(isGlobalMode: true);
  });
}
