import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../../util/capture_console_output.dart';
import '../../util/run_test_in_process.dart' as process;
import '../timeline_test_shared.dart' as shared;
import 'timeline_tap_test_widget.dart';

final WidgetSelector _addButtonSelector = spotIcon(Icons.add);
final _subtractButtonSelector = spotIcon(Icons.remove);
final _clearButtonSelector = spotIcon(Icons.clear);
const String counter3 = 'Counter: 3';
const String counter4 = 'Counter: 4';
const String counter99 = 'Counter: 99';

Future<void> recordWithoutError({
  required WidgetTester tester,
  bool isGlobalMode = false,
}) async {
  final output = await captureConsoleOutput(() async {
    if (!isGlobalMode) {
      timeline.mode = TimelineMode.record;
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
  _testTimeLineContent(output: output, eventCount: 0);
}

Future<void> recordWithError({
  bool isGlobalMode = false,
}) async {
  final stdout = await _outputFromTapTestProcess(
    title: 'OnError timeline - with error, prints timeline',
    timelineMode: TimelineMode.record,
    shouldFail: true,
    isGlobalMode: isGlobalMode,
    captureStart: 'Timeline',
  );

  final timeline = stdout.split('\n');

  expect(timeline.first, 'Timeline');
  expect(
    timeline[1],
    shared.timelineHeader,
  );
  expect(
    timeline[2],
    'Event: Tap Icon Widget with icon: "IconData(U+0E047)"',
  );
  expect(
    timeline[3].startsWith('Caller: at main.<fn> file:///'),
    isTrue,
  );
  expect(
    timeline[4].startsWith(
      'Screenshot: file:///',
    ),
    isTrue,
  );
  expect(
    timeline[5].startsWith(
      'Timestamp:',
    ),
    isTrue,
  );
  expect(
    timeline[6],
    shared.timelineSeparator,
  );
  final prefix = isGlobalMode ? 'global' : 'local';
  final htmlLine =
      timeline.firstWhere((line) => line.startsWith('View time line here:'));
  expect(
    htmlLine.endsWith(
      'timeline-$prefix-onerror-timeline-with-error-prints-timeline.html',
    ),
    isTrue,
  );
}

Future<void> liveWithoutErrorPrintsHtml({
  bool isGlobalMode = false,
}) async {
  final stdout = await _outputFromTapTestProcess(
    title: 'Live timeline without error prints html',
    timelineMode: TimelineMode.live,
    isGlobalMode: isGlobalMode,
  );

  final timeline = stdout.split('\n');
// Does not start with 'Timeline', this only happens on error
  expect(timeline.first, shared.timelineHeader);
  expect(
    timeline.second,
    'Event: Tap Icon Widget with icon: "IconData(U+0E047)"',
  );
  expect(
    timeline[2].startsWith('Caller: at'),
    isTrue,
  );
  expect(
    timeline[3].startsWith(
      'Screenshot: file:///',
    ),
    isTrue,
  );
  expect(
    timeline[4].startsWith(
      'Timestamp:',
    ),
    isTrue,
  );
  expect(
    timeline[5],
    shared.timelineSeparator,
  );
  final htmlLine =
      timeline.firstWhere((line) => line.startsWith('View time line here:'));
  final prefix = isGlobalMode ? 'global' : 'local';
  expect(
    htmlLine.endsWith(
      'timeline-$prefix-live-timeline-without-error-prints-html.html',
    ),
    isTrue,
  );
}

Future<void> liveWithErrorNoDuplicatesPrintsHtml({
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
  expect(
    timeline.second,
    'Event: Tap Icon Widget with icon: "IconData(U+0E047)"',
  );
  expect(
    timeline[2].startsWith('Caller: at main.<fn> file:///'),
    isTrue,
  );
  expect(
    timeline[3].startsWith(
      'Screenshot: file:///',
    ),
    isTrue,
  );
  expect(
    timeline[4].startsWith(
      'Timestamp:',
    ),
    isTrue,
  );
  expect(
    timeline[5],
    shared.timelineSeparator,
  );
  final prefix = isGlobalMode ? 'global' : 'local';
  final htmlLine =
      timeline.firstWhere((line) => line.startsWith('View time line here:'));
  expect(
    htmlLine.endsWith(
      'timeline-$prefix-live-timeline-with-error-no-duplicates-prints-html.html',
    ),
    isTrue,
  );
}

Future<void> offWithoutError({
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

  expect(output, contains('⏸︎ - Timeline recording is off'));
  expect(
    output,
    isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
  );
  expect(
    output,
    isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
  );
  _testTimeLineContent(output: output, eventCount: 0);
}

Future<void> liveTurnOffDuringTest({
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
  final containsMessage = output.contains('🔴 - Recording live timeline');
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
  _testTimeLineContent(output: output, eventCount: 2);
  expect(output, contains('⏸︎ - Timeline recording is off'));
}

Future<void> liveWithoutError({
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
  final containsMessage = output.contains('🔴 - Recording live timeline');
  // Changes in local test since it's `record` by default. Globally it does not
  // change since the global mode is already `live`.
  expect(containsMessage, isGlobalMode ? isFalse : isTrue);
  expect(
    output,
    contains('Event: Tap ${_addButtonSelector.toStringBreadcrumb()}'),
  );
  expect(
    output,
    contains('Event: Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
  );
  _testTimeLineContent(output: output, eventCount: 2);
}

void _testTimeLineContent({
  required String output,
  required int eventCount,
}) {
  expect(
    RegExp(shared.timelineHeader).allMatches(output).length,
    eventCount,
  );
  expect(
    RegExp('Event: Tap Icon Widget with icon:').allMatches(output).length,
    eventCount,
  );
  final callerParts = output.split('\n').where((line) {
    return line.startsWith('Caller: at') && line.contains('file://');
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

String _tapTestAsString({
  required String title,
  required TimelineMode timelineMode,
  bool shouldFail = false,
  bool isGlobalMode = false,
}) {
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

Future<String> _outputFromTapTestProcess({
  required String title,
  required TimelineMode timelineMode,
  String captureStart = shared.timelineHeader,
  bool shouldFail = false,
  bool isGlobalMode = false,
}) async {
  return process.runTestInProcessAndCaptureOutPut(
    shouldFail: shouldFail,
    testAsString: _tapTestAsString(
      title: title,
      timelineMode: timelineMode,
      shouldFail: shouldFail,
      isGlobalMode: isGlobalMode,
    ),
    captureStart: captureStart,
  );
}
