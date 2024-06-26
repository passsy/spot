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
    testWidgets('Local: live, without error', (tester) async {
      await TimelineTestHelpers.liveWithoutError(tester: tester);
    });
    testWidgets('Local: off, without error', (tester) async {
      await TimelineTestHelpers.offWithoutError(tester: tester);
    });
    testWidgets('Local: live, turn off during test', (tester) async {
      await TimelineTestHelpers.liveTurnOffDuringTest(tester: tester);
    });
  });

  group('Print on teardown', () {
    testWidgets('Local: record, without error', (tester) async {
      await TimelineTestHelpers.recordWithoutError(tester: tester);
    });

    test('Local: record, with error', () async {
      await TimelineTestHelpers.recordWithError();
    });
    test('Local: live - without error, prints HTML', () async {
      await TimelineTestHelpers.liveWithoutErrorPrintsHtml();
    });
    test('Local: live - with error, no duplicates, prints HTML', () async {
      await TimelineTestHelpers.liveWithErrorNoDuplicatesPrintsHtml();
    });
  });
}
