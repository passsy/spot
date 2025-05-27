import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../act_drag_timeline_test_bodies.dart';

void main() {
  globalTimelineMode = TimelineMode.always;
  group('Global: always', skip: kIsWeb, () {
    testWidgets(
      'turn off during test',
      (tester) async {
        await ActDragTimelineTestBodies.recordTurnOff(tester);
      },
      retry: 2,
    );
    testWidgets('no error print nothing', (tester) async {
      await ActDragTimelineTestBodies.alwaysNoError(tester);
    });
    test('with error, prints timeline and html', () async {
      await ActDragTimelineTestBodies.recordWithErrorPrintsHTML();
    });
  });
}
