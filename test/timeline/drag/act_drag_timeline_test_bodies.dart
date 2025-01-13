import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../../util/capture_console_output.dart';
import '../../util/run_test_in_process.dart' as process;
import '../timeline_test_shared.dart' as shared;
import 'drag_until_visible_test_widget.dart';

class ActDragTimelineTestBodies {
  static final _firstItemSelector = spotText('Item at index: 3', exact: true);
  static final _secondItemSelector = spotText('Item at index: 27', exact: true);

  static const _failingDragAmount = 10;
  static const _failingOffset = Offset(0, -1000);
  static const _passingDragAmount = 23;
  static const _passingOffset = Offset(0, -2300);

  static Future<void> liveWithoutError(WidgetTester tester) async {
    final isGlobal = timeline.mode == TimelineMode.live;
    final output = await captureConsoleOutput(() async {
      if (!isGlobal) {
        timeline.mode = TimelineMode.live;
      }
      await _testBody(tester);
    });
    final hasMessage =
        output.contains('🔴 - Live! Shows all timeline events as they happen');

    expect(hasMessage, isGlobal ? isFalse : isTrue);

    _testTimeLineContent(
      output: output,
      totalExpectedOffset: _passingOffset,
      drags: _passingDragAmount,
    );
  }

  static Future<void> offWithoutError(WidgetTester tester) async {
    final isGlobal = timeline.mode == TimelineMode.off;
    final output = await captureConsoleOutput(() async {
      if (!isGlobal) {
        timeline.mode = TimelineMode.off;
      }
      await _testBody(tester);
    });
    final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
    const expectedOutput = '⏸︎ - Timeline recording is off';
    final hasMessage = output.contains(expectedOutput);
    expect(hasMessage, isGlobal ? isFalse : isTrue);
    expect(lines.length, isGlobal ? 0 : 1);
  }

  static Future<void> recordTurnOff(WidgetTester tester) async {
    final isGlobal = timeline.mode == TimelineMode.off;
    final output = await captureConsoleOutput(() async {
      if (!isGlobal) {
        timeline.mode = TimelineMode.off;
      }
      await _testBody(tester);
    });
    final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
    expect(lines.length, 1);
    expect(lines.first, contains('⏸︎ - Timeline recording is off'));
  }

  static Future<void> recordNoError(WidgetTester tester) async {
    final isGlobal = timeline.mode == TimelineMode.reportOnError;
    final output = await captureConsoleOutput(() async {
      if (!isGlobal) {
        // Won't change anything, since it's default. Here to make sure
        // nothing is printed when the mode doesn't change.
        timeline.mode = TimelineMode.reportOnError;
      }
      await _testBody(tester);
    });
    final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
    // Neither timeline output nor HTML link when onError timeline is
    // recorded when no error occurs.
    expect(lines.length, 0, reason: output);
  }

  static Future<void> alwaysNoError(WidgetTester tester) async {
    final isGlobal = timeline.mode == TimelineMode.always;
    final output = await captureConsoleOutput(() async {
      if (!isGlobal) {
        // always print the timeline
        timeline.mode = TimelineMode.always;
      }
      await _testBody(tester);
    });
    final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
    if (!isGlobal) {
      expect(lines.length, 1);
      expect(lines.first, contains('🔴 - Always shows the timeline'));
    } else {
      expect(lines.length, 0);
    }
  }

  static Future<void> liveWithoutErrorPrintsHTML() async {
    final isGlobal = timeline.mode == TimelineMode.live;
    final stdout = await _outputFromDragTestProcess(
      title: 'Live timeline - without error, prints HTML',
      timelineMode: TimelineMode.live,
      drags: _passingDragAmount,
      captureStart: ['Timeline', shared.timelineHeader],
    );

    // Does not start with 'Timeline', this only happens on error
    expect(stdout.startsWith('Timeline'), isFalse);

    _testTimeLineContent(
      output: stdout,
      drags: _passingDragAmount,
      totalExpectedOffset: _passingOffset,
    );

    final htmlLine = stdout
        .split('\n')
        .firstWhere((line) => line.startsWith('View timeline here:'));

    final prefix = isGlobal ? 'global' : 'local';
    expect(
      htmlLine.endsWith(
        '$prefix-live-timeline-without-error-prints-html${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> liveWithoutErrorPrintsHTMLNoDuplicates() async {
    final isGlobal = timeline.mode == TimelineMode.live;
    final stdout = await _outputFromDragTestProcess(
      isGlobalMode: isGlobal,
      title: 'Live timeline - without error, no duplicates, prints HTML',
      timelineMode: TimelineMode.live,
      drags: _passingDragAmount,
      captureStart: [shared.timelineHeader, '🔴 - Recording live timeline'],
    );

    final lines = stdout.split('\n');
    // In the local test, the default timeline mode is 'record'.
    // Switching to live within the test results in a change to the mode,
    // which is documented in the output.
    expect(
      lines.first,
      isGlobal ? shared.timelineHeader : '🔴 - Recording live timeline',
    );

    _testTimeLineContent(
      output: stdout,
      drags: _passingDragAmount,
      totalExpectedOffset: _passingOffset,
    );

    final htmlLine = stdout
        .split('\n')
        .firstWhere((line) => line.startsWith('View timeline here:'));

    final prefix = isGlobal ? 'global' : 'local';
    expect(
      htmlLine.endsWith(
        '$prefix-live-timeline-without-error-no-duplicates-prints-html${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> liveWithErrorPrintsHTMLNoDuplicates() async {
    final isGlobal = timeline.mode == TimelineMode.live;
    final stdout = await _outputFromDragTestProcess(
      isGlobalMode: isGlobal,
      title: 'Live timeline - with error, no duplicates, prints HTML',
      timelineMode: TimelineMode.live,
      drags: _failingDragAmount,
      captureStart: [
        if (isGlobal)
          shared.timelineHeader
        else
          '🔴 - Live! Shows all timeline events as they happen',
      ],
    );

    final lines = stdout.split('\n');
    // In the local test, the default timeline mode is 'record'.
    // Switching to live within the test results in a change to the mode,
    // which is documented in the output.
    expect(
      lines.first,
      isGlobal
          ? shared.timelineHeader
          : '🔴 - Live! Shows all timeline events as they happen',
    );

    _testTimeLineContent(
      output: stdout,
      drags: _failingDragAmount,
      totalExpectedOffset: _failingOffset,
    );

    final htmlLine = stdout
        .split('\n')
        .firstWhere((line) => line.startsWith('View timeline here:'));

    final prefix = isGlobal ? 'global' : 'local';
    expect(
      htmlLine.endsWith(
        '$prefix-live-timeline-with-error-no-duplicates-prints-html${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> recordWithErrorPrintsHTML() async {
    final isGlobal = timeline.mode == TimelineMode.reportOnError;
    final stdout = await _outputFromDragTestProcess(
      title: 'OnError timeline - with error, prints timeline',
      timelineMode: TimelineMode.reportOnError,
      drags: _failingDragAmount,
      isGlobalMode: isGlobal,
    );

    _testTimeLineContent(
      output: stdout,
      drags: _failingDragAmount,
      totalExpectedOffset: _failingOffset,
    );

    final htmlLine = stdout
        .split('\n')
        .firstWhere((line) => line.startsWith('View timeline here:'));
    final prefix = isGlobal ? 'global' : 'local';
    expect(
      htmlLine.endsWith(
        '$prefix-onerror-timeline-with-error-prints-timeline${Platform.pathSeparator}index.html',
      ),
      isTrue,
      reason: 'Actual: $htmlLine',
    );
  }

  static Future<void> _testBody(WidgetTester tester) async {
    await tester.pumpWidget(
      const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
    );
    _firstItemSelector.existsOnce();
    _secondItemSelector.doesNotExist();
    await act.dragUntilVisible(
      dragStart: _firstItemSelector,
      dragTarget: _secondItemSelector,
      moveStep: const Offset(0, -100),
      maxIteration: _passingDragAmount,
    );
    _secondItemSelector.existsOnce();
  }

  static void _testTimeLineContent({
    required String output,
    required Offset totalExpectedOffset,
    required int drags,
  }) {
    final isGoingDown = totalExpectedOffset.dy < 0;
    final findsWidget = drags == _passingDragAmount;
    final lines = output.split('\n');
    final indexesOfDragEvents = lines
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value.startsWith('Event Type: Drag Event') ||
              entry.value.startsWith('Event Type: Drag Error Event'),
        )
        .map((entry) => entry.key)
        .toList();
    final totalDragEvents = indexesOfDragEvents.length;

    expect(totalDragEvents, findsWidget ? 3 : 2);

    final List<List<String>> dragEvents = [];

    for (final index in indexesOfDragEvents) {
      final List<String> event = [];
      for (var i = index; i < index + 5; i++) {
        event.add(lines[i]);
      }
      dragEvents.add(event);
    }

    // Basics, shared by all Drag Events
    for (final event in dragEvents) {
      expect(
        event[2],
        startsWith('Caller: at'),
      );
      expect(
        event[3],
        startsWith('Screenshot: file://'),
      );
      expect(
        event[4],
        startsWith('Timestamp: 20'),
      );
    }
    final details = dragEvents.map((e) => e[1]).toList();
    // First drag event is always the same, no matter if it's a success or a failure
    expect(
      _replaceOffsetWithDxDy(details[0]),
      'Details: Scrolling ${isGoingDown ? 'to the end' : 'to the start'} beginning at Offset(dx,dy) in order to find ${_secondItemSelector.toStringBreadcrumb()}.',
    );
    if (!findsWidget) {
      expect(
        details[1],
        'Details: ${_secondItemSelector.toStringBreadcrumb()} is not visible after dragging $drags times and a total dragged offset of $totalExpectedOffset.',
      );
    } else {
      expect(
        details[1],
        'Details: Scrolling to fully reveal ${_secondItemSelector.toStringBreadcrumb()}.',
      );
      expect(
        _replaceOffsetWithDxDy(details[2]),
        "Details: Target ${_secondItemSelector.toStringBreadcrumb()} found after $drags drags. "
        "Total dragged offset: Offset(dx,dy)",
      );
    }
  }

  static String _replaceOffsetWithDxDy(String originalString) {
    // Regular expression to match 'Offset(any values)'
    final RegExp offsetPattern = RegExp(r'Offset\([^)]*\)');

    // Replace all matches with 'Offset(dx,dy)'
    return originalString.replaceAll(offsetPattern, 'Offset(dx,dy)');
  }

  static Future<String> _outputFromDragTestProcess({
    required String title,
    required TimelineMode timelineMode,
    List<String> captureStart = const [shared.timelineHeader],
    bool isGlobalMode = false,
    TimelineMode? globalTimelineModeToSwitch,
    required int drags,
  }) async {
    final testAsString = _testAsString(
      title: title,
      timelineMode: timelineMode,
      isGlobalMode: isGlobalMode,
      drags: drags,
    );

    return process.runTestInProcessAndCaptureOutPut(
      shouldFail:
          drags == _failingDragAmount || globalTimelineModeToSwitch != null,
      testFileText: testAsString,
      captureStart: captureStart,
    );
  }

  static String _testAsString({
    required String title,
    required TimelineMode timelineMode,
    required int drags,
    bool isGlobalMode = false,
  }) {
    final testTitle = '${isGlobalMode ? 'Global: ' : 'Local: '}$title';

    final globalInitiator =
        isGlobalMode ? shared.globalTimelineInitiator(timelineMode) : '';

    final localInitiator = shared.localTimelineInitiator(timelineMode);

    final widgetPart =
        File('test/timeline/drag/drag_until_visible_test_widget.dart')
            .readAsStringSync();
    return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';\n
$widgetPart\n
void main() async {
$globalInitiator
  testWidgets("$testTitle", (WidgetTester tester) async {
  $localInitiator
    await tester.pumpWidget(const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical));
      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: $drags,
        moveStep: const Offset(0, -100),
      );
      secondItem.existsOnce();
  });
}
''';
  }
}
