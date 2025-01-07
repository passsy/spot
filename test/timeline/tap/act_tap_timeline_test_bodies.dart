import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../../util/capture_console_output.dart';
import '../../util/run_test_in_process.dart' as process;
import '../timeline_test_shared.dart' as shared;
import 'timeline_tap_test_widget.dart';

class ActTapTimelineTestBodies {
  static final WidgetSelector _addButtonSelector = spotIcon(Icons.add);
  static final _subtractButtonSelector = spotIcon(Icons.remove);
  static final _clearButtonSelector = spotIcon(Icons.clear);

  static Future<void> recordWithoutError({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await captureConsoleOutput(() async {
      if (!isGlobalMode) {
        timeline.mode = TimelineMode.reportOnError;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });
    expect(output, isNot(contains('🔴 - Recording error output timeline')));
    expect(
      output,
      isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
    );
    _testTimeLineContent(output: output, tapCount: 0, assertionCount: 0);
  }

  static Future<void> throwOnGlobalTimelineChange({
    bool isGlobalMode = false,
    required TimelineMode initialGlobalMode,
    required TimelineMode globalTimelineModeToSwitch,
  }) async {
    final stdout = await _outputFromTapTestProcess(
      title: 'Throws if global timeline mode is changed mid test',
      timelineMode: initialGlobalMode,
      shouldFail: true,
      isGlobalMode: isGlobalMode,
      captureStart: ['The following StateError was thrown running a test:'],
      globalTimelineModeToSwitch: globalTimelineModeToSwitch,
    );
    final expectedErrorMessage = '''
Cannot change global timeline mode within a test.
Use "timeline.mode" instead.
Example: timeline.mode = $globalTimelineModeToSwitch;
''';
    expect(stdout, contains(expectedErrorMessage));
  }

  static Future<void> recordWithError({
    bool isGlobalMode = false,
  }) async {
    final stdout = await _outputFromTapTestProcess(
      title: 'OnError timeline - with error, prints timeline',
      timelineMode: TimelineMode.reportOnError,
      shouldFail: true,
      isGlobalMode: isGlobalMode,
      captureStart: ['Timeline of test'],
    );

    final timeline = stdout.split('\n');

    expect(timeline[0], startsWith('Timeline of test:'));
    expect(
      timeline[1],
      shared.timelineHeader,
    );
    final start = timeline.indexOf('Event Type: Tap Event');
    expect(
      timeline[start],
      'Event Type: Tap Event',
    );
    expect(
      timeline[start + 1],
      'Details: Tap Icon Widget with icon: "IconData(U+0E047)"',
    );
    expect(
      timeline[start + 2],
      startsWith('Caller: at'),
    );
    expect(
      timeline[start + 3],
      startsWith('Screenshot: file://'),
    );
    expect(
      timeline[start + 4],
      startsWith('Timestamp:'),
    );
    expect(
      timeline[start + 5],
      shared.timelineSeparator,
    );
    final prefix = isGlobalMode ? 'global' : 'local';
    final htmlLine =
        timeline.firstWhere((line) => line.startsWith('View timeline here:'));
    expect(
      htmlLine.endsWith(
        '$prefix-onerror-timeline-with-error-prints-timeline${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> liveWithoutErrorPrintsHtml({
    bool isGlobalMode = false,
  }) async {
    final stdout = await _outputFromTapTestProcess(
      title: 'Live timeline without error prints html',
      timelineMode: TimelineMode.live,
      isGlobalMode: isGlobalMode,
      captureStart: ['Timeline', shared.timelineHeader],
    );

    final timeline = stdout.split('\n');
    // Does not start with 'Timeline', this only happens on error
    expect(timeline.first, shared.timelineHeader);
    final start = timeline.indexOf('Event Type: Tap Event');
    expect(
      timeline[start],
      'Event Type: Tap Event',
    );
    expect(
      timeline[start + 1],
      'Details: Tap Icon Widget with icon: "IconData(U+0E047)"',
    );
    expect(
      timeline[start + 2],
      startsWith('Caller: at'),
    );
    expect(
      timeline[start + 3],
      startsWith('Screenshot: file://'),
    );
    final screenshotPath =
        timeline[start + 3].split('Screenshot: ').last.split('file://').last;
    final screenshotFile = File(screenshotPath);
    expect(
      screenshotFile.existsSync(),
      isTrue,
      reason: 'Screenshot file does not exist at $screenshotPath',
    );
    expect(
      screenshotFile.readAsBytesSync(),
      isNotEmpty,
      reason: 'file is empty, no data written',
    );

    expect(
      timeline[start + 4],
      startsWith('Timestamp:'),
    );
    expect(
      timeline[start + 5],
      shared.timelineSeparator,
    );
    final htmlLine =
        timeline.firstWhere((line) => line.startsWith('View timeline here:'));
    final prefix = isGlobalMode ? 'global' : 'local';
    expect(
      htmlLine.endsWith(
        '$prefix-live-timeline-without-error-prints-html${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> liveWithErrorNoDuplicatesPrintsHtml({
    bool isGlobalMode = false,
  }) async {
    final stdout = await _outputFromTapTestProcess(
      title: 'Live timeline - with error, no duplicates, prints HTML',
      timelineMode: TimelineMode.live,
      shouldFail: true,
      isGlobalMode: isGlobalMode,
    );

    final timeline = stdout.split('\n');
    // Does not start with 'Timeline', this only happens on error
    expect(timeline.first, shared.timelineHeader);
    final first = timeline.indexOf('Event Type: Tap Event');
    final start = timeline.indexOf('Event Type: Tap Event', first + 1);
    expect(start, isNot(-1));
    expect(
      timeline[start],
      'Event Type: Tap Event',
    );
    expect(
      timeline[start + 1],
      'Details: Tap Icon Widget with icon: "IconData(U+0E516)"',
    );
    expect(
      timeline[start + 2],
      startsWith('Caller: at'),
    );
    expect(
      timeline[start + 3],
      startsWith('Screenshot: file://'),
    );
    expect(
      timeline[start + 4],
      startsWith('Timestamp:'),
    );
    expect(
      timeline[start + 5],
      shared.timelineSeparator,
    );
    final prefix = isGlobalMode ? 'global' : 'local';
    final htmlLine =
        timeline.firstWhere((line) => line.startsWith('View timeline here:'));
    expect(
      htmlLine.endsWith(
        '$prefix-live-timeline-with-error-no-duplicates-prints-html${Platform.pathSeparator}index.html',
      ),
      isTrue,
    );
  }

  static Future<void> offWithoutError({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await captureConsoleOutput(() async {
      if (!isGlobalMode) {
        timeline.mode = TimelineMode.off;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });
    final showsMessage = output.contains('⏸︎ - Timeline recording is off');
    expect(showsMessage, isGlobalMode ? isFalse : isTrue);
    expect(
      output,
      isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
    );
    _testTimeLineContent(output: output, tapCount: 0, assertionCount: 0);
  }

  static Future<void> liveTurnOffDuringTest({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await captureConsoleOutput(() async {
      if (!isGlobalMode) {
        timeline.mode = TimelineMode.live;
      }
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
      timeline.mode = TimelineMode.off;
      await act.tap(_clearButtonSelector);
      spotText('Counter: 0').existsOnce();
    });
    final containsMessage =
        output.contains('🔴 - Live! Shows all timeline events as they happen');
    // Changes in local test since it's `record` by default. Globally it does not
    // change since the global mode is already `live`.
    expect(containsMessage, isGlobalMode ? isFalse : isTrue);
    expect(output, contains('⏸︎ - Timeline recording is off'));
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
    _testTimeLineContent(output: output, tapCount: 2, assertionCount: 10);
    expect(output, contains('⏸︎ - Timeline recording is off'));
  }

  static Future<void> liveWithoutError({
    required WidgetTester tester,
    bool isGlobalMode = false,
  }) async {
    final output = await captureConsoleOutput(() async {
      if (!isGlobalMode) {
        timeline.mode = TimelineMode.live;
      }
      await tester.pumpWidget(const TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });
    final containsMessage =
        output.contains('🔴 - Live! Shows all timeline events as they happen');
    // Changes in local test since it's `record` by default. Globally it does not
    // change since the global mode is already `live`.
    expect(containsMessage, isGlobalMode ? isFalse : isTrue);

    expect(
      output,
      contains(
        'Event Type: Assertion\n'
        'Details: ${_addButtonSelector.toStringBreadcrumb()} exists once',
      ),
    );
    expect(
      output,
      contains(
        'Event Type: Assertion\n'
        'Details: ${spotText('Counter: 3')} exists once',
      ),
    );
    expect(
      output,
      contains(
        'Event Type: Tap Event\n'
        'Details: Tap ${_addButtonSelector.toStringBreadcrumb()}',
      ),
    );
    expect(
      output,
      contains(
        'Event Type: Assertion\n'
        'Details: ${spotText('Counter: 4')} exists once',
      ),
    );
    expect(
      output,
      contains(
        'Event Type: Tap Event\n'
        'Details: Tap ${_subtractButtonSelector.toStringBreadcrumb()}',
      ),
    );
    expect(
      output,
      contains(
        'Event Type: Assertion\n'
        'Details: ${spotText('Counter: 3')} exists once',
      ),
    );
    _testTimeLineContent(output: output, tapCount: 2, assertionCount: 10);
  }

  static void _testTimeLineContent({
    required String output,
    required int tapCount,
    required int assertionCount,
  }) {
    expect(
      RegExp('Event Type: Tap Event').allMatches(output).length,
      tapCount,
    );
    expect(
      RegExp('Event Type: Assertion').allMatches(output).length,
      assertionCount,
    );
    expect(
      RegExp(shared.timelineHeader).allMatches(output).length,
      tapCount + assertionCount,
    );
    final callerParts = output.split('\n').where((line) {
      return line.startsWith('Caller: at') && line.contains('file://');
    }).toList();
    expect(
      callerParts.length,
      tapCount + assertionCount,
    );
    final screenshots = output.split('\n').where((line) {
      return line.startsWith('Screenshot: file:');
    }).toList();
    if (WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding) {
      expect(
        screenshots.length,
        tapCount + assertionCount,
      );
    } else {
      expect(
        screenshots.length,
        0,
      );
    }
    expect(
      RegExp('Timestamp: ').allMatches(output).length,
      tapCount + assertionCount,
    );
  }

  static String _tapTestAsString({
    required String title,
    required TimelineMode timelineMode,
    bool shouldFail = false,
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

    final widgetPart = File('test/timeline/tap/timeline_tap_test_widget.dart')
        .readAsStringSync();
    return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';\n
$widgetPart\n
void main() async {
  $globalInitiator
  final addButtonSelector = spotIcon(Icons.add);
  final subtractButtonSelector = spotIcon(Icons.remove);
  testWidgets("$testTitle", (WidgetTester tester) async {
  $switchPart
   $localInitiator
    await tester.pumpWidget(const TimelineTestWidget());
      addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      ${shouldFail ? 'spotText("Counter: 99").existsOnce();' : ''}
  });
}
''';
  }

  static Future<String> _outputFromTapTestProcess({
    required String title,
    required TimelineMode timelineMode,
    List<String> captureStart = const [shared.timelineHeader],
    bool shouldFail = false,
    bool isGlobalMode = false,
    TimelineMode? globalTimelineModeToSwitch,
  }) async {
    final testAsString = _tapTestAsString(
      title: title,
      timelineMode: timelineMode,
      shouldFail: shouldFail,
      isGlobalMode: isGlobalMode,
      globalTimelineModeToSwitch: globalTimelineModeToSwitch,
    );
    return await process.runTestInProcessAndCaptureOutPut(
      shouldFail: shouldFail,
      testFileText: testAsString,
      captureStart: captureStart,
    );
  }
}
