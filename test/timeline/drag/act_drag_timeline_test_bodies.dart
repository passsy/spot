import 'dart:io';
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
        '$prefix-live-timeline-without-error-prints-html/index.html',
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
        '$prefix-live-timeline-without-error-no-duplicates-prints-html/index.html',
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
        '$prefix-live-timeline-with-error-no-duplicates-prints-html/index.html',
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
        '$prefix-onerror-timeline-with-error-prints-timeline/index.html',
      ),
      isTrue,
    );
  }

  static Future<void> _testBody(WidgetTester tester) async {
    await tester.pumpWidget(const DragUntilVisibleTestWidget());
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
        .where((entry) => entry.value.startsWith('Event Type: Drag Event'))
        .map((entry) => entry.key)
        .toList();
    expect(indexesOfDragEvents.length, 2);

    // Event Type: Drag Event
    // Details: Scrolling downwards from Offset(398.0, 451.0) in order to find Widget with text with text "Item at index: 27".
    // Caller: at main file:///Users/pascalwelsch/Projects/passsy/spot/test/timeline/drag/local/local_timeline_drag_test.dart:8:9
    // Screenshot: file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/spot/act_drag_timeline_test_bodies:230-LSyb7.png
    // Timestamp: 2024-11-03T02:53:05.111569
    final indexOfStart = indexesOfDragEvents[0];
    assert(indexOfStart != -1);
    expect(
      _replaceOffsetWithDxDy(lines[indexOfStart + 1]),
      'Details: Scrolling ${isGoingDown ? 'downwards' : 'upwards'} from Offset(dx,dy) in order to find ${_secondItemSelector.toStringBreadcrumb()}.',
    );
    expect(
      lines[indexOfStart + 2],
      startsWith('Caller: at'),
    );
    expect(
      lines[indexOfStart + 3],
      startsWith('Screenshot: file://'),
    );
    expect(
      lines[indexOfStart + 4],
      startsWith('Timestamp: 20'),
    );

    final indexOfEnd = indexesOfDragEvents[1];
    assert(indexOfEnd != -1);
    expect(
      lines[indexOfEnd + 1],
      'Details: Target ${_secondItemSelector.toStringBreadcrumb()} ${findsWidget ? 'found' : 'not found'} after $drags drags. Total dragged offset: $totalExpectedOffset',
    );
    expect(
      lines[indexOfEnd + 2],
      startsWith('Caller: at'),
    );
    expect(
      lines[indexOfEnd + 3],
      startsWith('Screenshot: file://'),
    );
    expect(
      lines[indexOfEnd + 4],
      startsWith('Timestamp: 20'),
    );
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
    await tester.pumpWidget(const DragUntilVisibleTestWidget());
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
