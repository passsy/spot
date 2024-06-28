import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../../util/capture_console_output.dart';
import '../../util/run_test_in_process.dart' as process;
import '../timeline_test_shared.dart' as shared;
import '../timeline_test_shared.dart';
import 'drag_until_visible_test_widget.dart';

final _firstItemSelector = spotText('Item at index: 3', exact: true);
final _secondItemSelector = spotText('Item at index: 27', exact: true);

const _failingDragAmount = 10;
const _failingOffset = Offset(0, -1000);
const _passingDragAmount = 23;
const _passingOffset = Offset(0, -2300);

Future<void> liveTimelineWithoutErrorsDrag(
  WidgetTester tester, {
  bool isGlobal = false,
}) async {
  final output = await captureConsoleOutput(() async {
    if (!isGlobal) {
      timeline.mode = TimelineMode.live;
    }
    await _testBody(tester);
  });
  final hasMessage = output.contains('🔴 - Recording live timeline');

  expect(hasMessage, isGlobal ? isFalse : isTrue);
  _testTimeLineContent(
    output: output,
    totalExpectedOffset: _passingOffset,
    drags: _passingDragAmount,
  );
}

Future<void> offTimelineWithoutErrorsDrag(
  WidgetTester tester, {
  bool isGlobal = false,
}) async {
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

Future<void> recordTurnOffDuringTestDrag(
  WidgetTester tester, {
  bool isGlobal = false,
}) async {
  final output = await captureConsoleOutput(() async {
    timeline.mode = TimelineMode.off;
    await _testBody(tester);
  });
  final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
  expect(lines.length, 1);
  expect(lines.first, contains('⏸︎ - Timeline recording is off'));
}

Future<void> recordNoErrorsDrag(
  WidgetTester tester, {
  bool isGlobal = false,
}) async {
  final output = await captureConsoleOutput(() async {
    // Won't change anything, since it's default. Here to make sure
    // nothing is printed when the mode doesn't change.
    timeline.mode = TimelineMode.record;
    await _testBody(tester);
  });
  final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
  // Neither timeline output nor HTML link when onError timeline is
  // recorded when no error occurs.
  expect(lines.length, 0);
}

Future<void> liveWithoutErrorPrintsHTML({
  bool isGlobal = false,
}) async {
  final stdout = await _outputFromDragTestProcess(
    title: 'Live timeline - without error, prints HTML',
    timelineMode: TimelineMode.live,
    drags: _passingDragAmount,
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
      .firstWhere((line) => line.startsWith('View time line here:'));

  final prefix = isGlobal ? 'global' : 'local';
  expect(
    htmlLine.endsWith(
      'timeline-$prefix-live-timeline-without-error-prints-html.html',
    ),
    isTrue,
  );
}

Future<void> recordWithErrorPrintsHTML({
  bool isGlobal = false,
}) async {
  final stdout = await _outputFromDragTestProcess(
    title: 'OnError timeline - with error, prints timeline',
    timelineMode: TimelineMode.record,
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
      .firstWhere((line) => line.startsWith('View time line here:'));
  final prefix = isGlobal ? 'global' : 'local';
  expect(
    htmlLine.endsWith(
      'timeline-$prefix-onerror-timeline-with-error-prints-timeline.html',
    ),
    isTrue,
  );
}

Future<void> _testBody(WidgetTester tester) async {
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

void _testTimeLineContent({
  required String output,
  required Offset totalExpectedOffset,
  required int drags,
}) {
  final isGoingDown = totalExpectedOffset.dy < 0;
  final findsWidget = drags == _passingDragAmount;
  final eventLines =
      output.split('\n').where((line) => line.startsWith('Event:'));
  final startEvent = _replaceOffsetWithDxDy(eventLines.first);
  final endEvent =
      'Event: Target ${_secondItemSelector.toStringBreadcrumb()} ${findsWidget ? 'found' : 'not found'} after $drags drags. Total dragged offset: $totalExpectedOffset';

  for (int i = 0; i < 2; i++) {
    expect(
      RegExp(timelineHeader).allMatches(output).length,
      2,
    );
    if (i == 0) {
      expect(
        startEvent,
        'Event: Scrolling ${isGoingDown ? 'downwards' : 'upwards'} from Offset(dx,dy) in order to find ${_secondItemSelector.toStringBreadcrumb()}.',
      );
    } else {
      expect(
        eventLines.last,
        endEvent,
      );
    }
    expect(
      RegExp('Caller: at').allMatches(output).length,
      2,
    );
    expect(
      RegExp('Screenshot: file:').allMatches(output).length,
      2,
    );
    expect(
      RegExp('Timestamp: ').allMatches(output).length,
      2,
    );
  }
}

String _replaceOffsetWithDxDy(String originalString) {
  // Regular expression to match 'Offset(any values)'
  final RegExp offsetPattern = RegExp(r'Offset\([^)]*\)');

  // Replace all matches with 'Offset(dx,dy)'
  return originalString.replaceAll(offsetPattern, 'Offset(dx,dy)');
}

Future<String> _outputFromDragTestProcess({
  required String title,
  required TimelineMode timelineMode,
  String captureStart = shared.timelineHeader,
  bool isGlobalMode = false,
  TimelineMode? globalTimelineModeToSwitch,
  required int drags,
}) async {
  final testAsString = _testAsString(
    title: title,
    timelineMode: timelineMode,
    isGlobalMode: isGlobalMode,
    globalTimelineModeToSwitch: globalTimelineModeToSwitch,
    drags: drags,
  );
  return process.runTestInProcessAndCaptureOutPut(
    shouldFail:
        drags == _failingDragAmount || globalTimelineModeToSwitch != null,
    testAsString: testAsString,
    captureStart: captureStart,
  );
}

String _testAsString({
  required String title,
  required TimelineMode timelineMode,
  required int drags,
  bool isGlobalMode = false,
  TimelineMode? globalTimelineModeToSwitch,
}) {
  final switchPart = globalTimelineModeToSwitch != null
      ? '''
      globalTimelineMode = TimelineMode.${globalTimelineModeToSwitch.toString().split('.').last};
      '''
      : '';
  final testTitle = '${isGlobalMode ? 'Global: ' : 'Local: '}$title';

  final globalInitiator =
      isGlobalMode ? shared.globalTimelineInitiator(timelineMode) : '';

  final localInitiator =
      isGlobalMode ? '' : shared.localTimelineInitiator(timelineMode);

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
  $switchPart
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
