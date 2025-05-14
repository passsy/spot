import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../act_drag_timeline_test_bodies.dart';

void main() {
  group('Drag Timeline Test', skip: kIsWeb, () {
    group('Without error', () {
      testWidgets('Local: record, without error', (tester) async {
        await ActDragTimelineTestBodies.liveWithoutError(tester);
      });
      testWidgets('Local: off does not record', (tester) async {
        await ActDragTimelineTestBodies.offWithoutError(tester);
      });
      testWidgets('Local: record, turn off during test', (tester) async {
        await ActDragTimelineTestBodies.recordTurnOff(tester);
      });
      testWidgets('Local: record - without error', (tester) async {
        await ActDragTimelineTestBodies.recordNoError(tester);
      });
    });
    group('Teardown test', () {
      test('Local: record, with error, prints timeline and html', () async {
        await ActDragTimelineTestBodies.recordWithErrorPrintsHTML();
      });
      test('Local: live - without error, prints HTML', () async {
        await ActDragTimelineTestBodies.liveWithoutErrorPrintsHTML();
      });
      test('Local: live - with error, prints HTML, no duplicates', () async {
        await ActDragTimelineTestBodies.liveWithErrorPrintsHTMLNoDuplicates();
      });
    });
  });
}
