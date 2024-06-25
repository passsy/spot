import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../timeline/tap/timeline_tap_test_widget.dart';

class TimelineTestHelpers {
  static final WidgetSelector addButtonSelector = spotIcon(Icons.add);
  static final subtractButtonSelector = spotIcon(Icons.remove);
  static final clearButtonSelector = spotIcon(Icons.clear);

  static const header =
      '==================== Timeline Event ====================';
  static const separator =
      '========================================================';

  static Future<String> captureConsoleOutput(
    Future<void> Function() testFunction,
  ) async {
    final StringBuffer buffer = StringBuffer();
    final ZoneSpecification spec = ZoneSpecification(
      print: (self, parent, zone, line) {
        buffer.writeln(line);
      },
    );

    await Zone.current.fork(specification: spec).run(() async {
      await testFunction();
    });

    return buffer.toString();
  }

  static String timelineInitiatorForModeAsString(TimelineMode timelineMode) {
    switch (timelineMode) {
      case TimelineMode.live:
        return 'localTimelineMode = TimelineMode.live;';
      case TimelineMode.record:
        return 'localTimelineMode = TimelineMode.record;';
      case TimelineMode.off:
        return 'localTimelineMode = TimelineMode.off;';
    }
  }

  static Future<void> recordTimelineTest({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await TimelineTestHelpers.captureConsoleOutput(() async {
      if (!isGlobalMode) {
        localTimelineMode = TimelineMode.record;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      // Notify that the timeline of this type is already recording.
      localTimelineMode = TimelineMode.record;
    });
    expect(output, contains('🔴 - Recording error output timeline'));
    expect(
      output,
      isNot(contains('Tap ${addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${subtractButtonSelector.toStringBreadcrumb()}')),
    );
    expect(output, contains('Timeline mode is already set to "record"'));
    _testTimeLineContent(output: output, eventCount: 0);
  }

  static Future<void> offTimelineTest({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await TimelineTestHelpers.captureConsoleOutput(() async {
      if (!isGlobalMode) {
        localTimelineMode = TimelineMode.off;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });

    expect(output, contains('⏸︎ - Timeline recording is off'));
    expect(
      output,
      isNot(contains('Tap ${addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${subtractButtonSelector.toStringBreadcrumb()}')),
    );
    _testTimeLineContent(output: output, eventCount: 0);
  }

  static Future<void> liveTimelineTest({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await TimelineTestHelpers.captureConsoleOutput(() async {
      if (!isGlobalMode) {
        localTimelineMode = TimelineMode.live;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      // Notify that the timeline mode is already set to live
      localTimelineMode = TimelineMode.live;
    });
    expect(output, contains('🔴 - Recording live timeline'));
    expect(
      output,
      contains('Event: Tap ${addButtonSelector.toStringBreadcrumb()}'),
    );
    expect(
      output,
      contains('Event: Tap ${subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(output, contains('Timeline mode is already set to "live"'));
    _testTimeLineContent(output: output, eventCount: 2);
  }

  static void _testTimeLineContent({
    required String output,
    required int eventCount,
  }) {
    expect(
      RegExp(header).allMatches(output).length,
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
}
