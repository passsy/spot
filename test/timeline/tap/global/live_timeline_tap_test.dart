import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../../../util/timeline_test_helpers.dart';

void main() {
  globalTimelineMode = TimelineMode.live;
  test('Global: Live timeline - without error, prints HTML', () async {
    await TimelineTestHelpers.liveTimelineWithoutErrorPrintsHtml(
      isGlobalMode: true,
    );
  });
}
