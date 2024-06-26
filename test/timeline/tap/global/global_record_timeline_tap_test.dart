import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.record;
  testWidgets('Global: record, without error', (tester) async {
    await TimelineTestHelpers.recordWithoutError(
      tester: tester,
      isGlobalMode: true,
    );
  });
  test('Global: record, with error', () async {
    await TimelineTestHelpers.recordWithError(isGlobalMode: true);
  });
}
