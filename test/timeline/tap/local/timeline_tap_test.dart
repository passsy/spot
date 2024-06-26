import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import '../../../util/timeline_test_helpers.dart';
import '../timeline_tap_test_widget.dart';

final _addButtonSelector = spotIcon(Icons.add);
final _subtractButtonSelector = spotIcon(Icons.remove);
final _clearButtonSelector = spotIcon(Icons.clear);

const _header = '==================== Timeline Event ====================';

void main() {
  group('Initial Values', () {
    test('global timeline', () {
      expect(globalTimelineMode, TimelineMode.record);
    });
    test('local timeline', () {
      expect(localTimelineMode, isNull);
    });
  });

  group('Override global timeline', () {
    testWidgets('Start with Timeline Mode off', (tester) async {
      TimelineTestHelpers.offTimelineTest(tester: tester);
    });
    testWidgets('Turn timeline mode off during test', (tester) async {
      final output = await TimelineTestHelpers.captureConsoleOutput(() async {
        localTimelineMode = TimelineMode.live;
        await tester.pumpWidget(
          const TimelineTestWidget(),
        );
        spotText('Counter: 3').existsOnce();
        _addButtonSelector.existsOnce();
        await act.tap(_addButtonSelector);
        spotText('Counter: 4').existsOnce();
        await act.tap(_subtractButtonSelector);
        spotText('Counter: 3').existsOnce();
        // Notify that the recording stopped
        localTimelineMode = TimelineMode.off;
        await act.tap(_clearButtonSelector);
        spotText('Counter: 0').existsOnce();
        // Notify that the recording is already off
        localTimelineMode = TimelineMode.off;
      });
      expect(output, contains('🔴 - Recording live timeline'));
      expect(
        output,
        contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'),
      );
      expect(
        output,
        contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
      );
      // No further events were added to the timeline, including screenshots
      expect(
        output,
        isNot(contains('Tap ${_clearButtonSelector.toStringBreadcrumb()}')),
      );
      _testTimeLineContent(output: output, eventCount: 2);
      expect(output, contains('⏸︎ - Timeline recording is off'));
      expect(output, contains('Timeline mode is already set to "off"'));
    });
  });

  group('Print on teardown', () {
    testWidgets('OnError timeline - without error', (tester) async {
      await TimelineTestHelpers.recordTimelineTestWithoutError(tester: tester);
    });

    test('OnError timeline - with error, prints timeline', () async {
      await TimelineTestHelpers.recordTimelineTestWithError();
    });
    test('Live timeline - without error, prints HTML', () async {
      await TimelineTestHelpers.liveTimelineWithoutErrorPrintsHtml();
    });
    test('Live timeline - with error, no duplicates, prints HTML', () async {
      await TimelineTestHelpers.liveTimelineWithErrorNoDuplicatesPrintsHtml();
    });
  });
}

void _testTimeLineContent({
  required String output,
  required int eventCount,
}) {
  expect(
    RegExp(_header).allMatches(output).length,
    eventCount,
  );
  expect(
    RegExp('Event: Tap Icon Widget with icon:').allMatches(output).length,
    eventCount,
  );
  final callerParts = output.split('\n').where((line) {
    return line.startsWith('Caller: at main') && line.contains('file://');
  }).toList();

  expect(
    callerParts.length,
    eventCount,
  );
  expect(
    RegExp('Screenshot: file:').allMatches(output).length,
    eventCount,
  );
  expect(
    RegExp('Timestamp: ').allMatches(output).length,
    eventCount,
  );
}
