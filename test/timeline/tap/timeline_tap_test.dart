import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:test_process/test_process.dart';
import '../../util/timeline_test_helpers.dart' as helpers;
import 'timeline_tap_test_widget.dart';

final _addButtonSelector = spotIcon(Icons.add);
final _subtractButtonSelector = spotIcon(Icons.remove);
final _clearButtonSelector = spotIcon(Icons.clear);

const _header = '==================== Timeline Event ====================';
const _separator = '========================================================';

String _testAsString({
  required String title,
  required TimelineMode timelineMode,
  bool shouldFail = false,
}) {
  final widgetPart = File('test/timeline/tap/timeline_tap_test_widget.dart')
      .readAsStringSync();
  return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';\n
$widgetPart\n
void main() async {
  final addButtonSelector = spotIcon(Icons.add);
  final subtractButtonSelector = spotIcon(Icons.remove);
  testWidgets("$title", (WidgetTester tester) async {
    ${helpers.timelineInitiatorForModeAsString(timelineMode)};
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
    testWidgets('Live timeline', (tester) async {
      final output = await helpers.captureConsoleOutput(() async {
        localTimelineMode = TimelineMode.live;
        await tester.pumpWidget(const TimelineTestWidget());
        _addButtonSelector.existsOnce();
        spotText('Counter: 3').existsOnce();
        await act.tap(_addButtonSelector);
        spotText('Counter: 4').existsOnce();
        await act.tap(_subtractButtonSelector);
        spotText('Counter: 3').existsOnce();
        // Notify that the timeline mode is already set to live
        localTimelineMode = TimelineMode.live;
      });
      print('output: $output');
      expect(output, contains('🔴 - Recording live timeline'));
      expect(
        output,
        contains('Event: Tap ${_addButtonSelector.toStringBreadcrumb()}'),
      );
      expect(
        output,
        contains('Event: Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
      );
      expect(output, contains('Timeline mode is already set to "live"'));
      _testTimeLineContent(output: output, eventCount: 2);
    });
    testWidgets('Start with Timeline Mode off', (tester) async {
      final output = await helpers.captureConsoleOutput(() async {
        localTimelineMode = TimelineMode.off;
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
    });
    testWidgets('Turn timeline mode off during test', (tester) async {
      final output = await helpers.captureConsoleOutput(() async {
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
      print('output: $output');
      expect(output, contains('🔴 - Recording live timeline'));
      expect(
          output, contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'));
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
//  globalTimelineMode = defaultTimelineMode();

  group('Print on teardown', () {
    testWidgets('OnError timeline - without error', (tester) async {
      final output = await helpers.captureConsoleOutput(() async {
        localTimelineMode = TimelineMode.record;
        await tester.pumpWidget(const TimelineTestWidget());
        _addButtonSelector.existsOnce();
        spotText('Counter: 3').existsOnce();
        await act.tap(_addButtonSelector);
        spotText('Counter: 4').existsOnce();
        await act.tap(_subtractButtonSelector);
        spotText('Counter: 3').existsOnce();
        // Notify that the timeline of this type is already recording.
        localTimelineMode = TimelineMode.record;
      });
      expect(output, contains('🔴 - Now recording error output timeline'));
      expect(
        output,
        isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
      );
      expect(
        output,
        isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
      );
      expect(output, contains('🔴 - Already recording error output timeline'));
      _testTimeLineContent(output: output, eventCount: 0);
    });

    test('OnError timeline - with error, prints timeline', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempTestFile = File('${tempDir.path}/temp_test.dart');
      await tempTestFile.writeAsString(
        _testAsString(
          title: 'OnError timeline - with error, prints timeline',
          timelineMode: TimelineMode.record,
          shouldFail: true,
        ),
      );

      final testProcess =
          await TestProcess.start('flutter', ['test', tempTestFile.path]);

      final stdoutBuffer = StringBuffer();

      bool write = false;
      await for (final line in testProcess.stdoutStream()) {
        if (line.isEmpty) continue;
        if (line == 'Timeline') {
          write = true;
        }
        if (write) {
          stdoutBuffer.writeln(line);
        }
      }

      // Error happens
      await testProcess.shouldExit(1);

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      final stdout = stdoutBuffer.toString();
      final timeline = stdout.split('\n');

      expect(timeline.first, 'Timeline');
      expect(
        timeline[1],
        _header,
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
        _separator,
      );
      final htmlLine = timeline
          .firstWhere((line) => line.startsWith('View time line here:'));
      expect(
        htmlLine.endsWith(
          'timeline-onerror-timeline-with-error-prints-timeline.html',
        ),
        isTrue,
      );
    });
    test('Live timeline - without error, prints HTML', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempTestFile = File('${tempDir.path}/temp_test.dart');
      await tempTestFile.writeAsString(
        _testAsString(
          title: 'Live timeline without error prints html',
          timelineMode: TimelineMode.live,
        ),
      );

      final testProcess =
          await TestProcess.start('flutter', ['test', tempTestFile.path]);

      final stdoutBuffer = StringBuffer();

      bool write = false;
      await for (final line in testProcess.stdoutStream()) {
        if (line.isEmpty) continue;

        if (!write) {
          if (line == _header) {
            write = true;
          }
        }

        if (write) {
          stdoutBuffer.writeln(line);
        }
      }

      // Error does not happen
      await testProcess.shouldExit(0);

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      final stdout = stdoutBuffer.toString();
      final timeline = stdout.split('\n');
      // Does not start with 'Timeline', this only happens on error
      expect(timeline.first, _header);
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
        _separator,
      );
      final htmlLine = timeline
          .firstWhere((line) => line.startsWith('View time line here:'));
      expect(
        htmlLine.endsWith(
          'timeline-live-timeline-without-error-prints-html.html',
        ),
        isTrue,
      );
    });
    test('Live timeline - with error, no duplicates, prints HTML', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempTestFile = File('${tempDir.path}/temp_test.dart');
      await tempTestFile.writeAsString(
        _testAsString(
          title: 'Live timeline - with error, no duplicates, prints HTML',
          timelineMode: TimelineMode.live,
          shouldFail: true,
        ),
      );

      final testProcess =
          await TestProcess.start('flutter', ['test', tempTestFile.path]);

      final stdoutBuffer = StringBuffer();

      bool write = false;
      await for (final line in testProcess.stdoutStream()) {
        if (line.isEmpty) continue;

        if (!write) {
          if (line == _header) {
            write = true;
          }
        }

        if (write) {
          stdoutBuffer.writeln(line);
        }
      }

      // Error does not happen
      await testProcess.shouldExit(1);

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }

      final stdout = stdoutBuffer.toString();
      final timeline = stdout.split('\n');
      // Does not start with 'Timeline', this only happens on error
      expect(timeline.first, _header);
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
        _separator,
      );
      final htmlLine = timeline
          .firstWhere((line) => line.startsWith('View time line here:'));
      expect(
        htmlLine.endsWith(
          'live-timeline-with-error-no-duplicates-prints-html.html',
        ),
        isTrue,
      );
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
