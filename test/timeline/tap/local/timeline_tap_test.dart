import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import '../../../util/timeline_test_helpers.dart';

void main() {
  group('Initial Values', () {
    test('Global Timeline', () {
      expect(globalTimelineMode, TimelineMode.record);
    });
    test('Local Timeline', () {
      expect(localTimelineMode, isNull);
    });
  });

  group('Override global timeline', () {
    testWidgets('Local: Start with Timeline Mode off', (tester) async {
      await TimelineTestHelpers.offTimelineTest(tester: tester);
    });
    testWidgets('Local: Turn live timeline off during test', (tester) async {
      await TimelineTestHelpers.liveTimelineTurnOffDuringTest(tester: tester);
    });
  });

  group('Print on teardown', () {
    testWidgets('Local: OnError timeline - without error', (tester) async {
      await TimelineTestHelpers.recordTimelineTestWithoutError(tester: tester);
    });

    test('Local: OnError timeline - with error, prints timeline', () async {
      await TimelineTestHelpers.recordTimelineTestWithError();
    });
    test('Local: Live timeline - without error, prints HTML', () async {
      await TimelineTestHelpers.liveTimelineWithoutErrorPrintsHtml();
    });
    test('Local: Live timeline - with error, no duplicates, prints HTML',
        () async {
      await TimelineTestHelpers.liveTimelineWithErrorNoDuplicatesPrintsHtml();
    });
  });
}
