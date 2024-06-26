import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:test_process/test_process.dart';

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

  static String localTimelineInitiator(TimelineMode timelineMode) {
    switch (timelineMode) {
      case TimelineMode.live:
        return 'localTimelineMode = TimelineMode.live;';
      case TimelineMode.record:
        return 'localTimelineMode = TimelineMode.record;';
      case TimelineMode.off:
        return 'localTimelineMode = TimelineMode.off;';
    }
  }

  static String globalTimelineInitiator(TimelineMode timelineMode) {
    switch (timelineMode) {
      case TimelineMode.live:
        return 'globalTimelineMode = TimelineMode.live;';
      case TimelineMode.record:
        return 'globalTimelineMode = TimelineMode.record;';
      case TimelineMode.off:
        return 'globalTimelineMode = TimelineMode.off;';
    }
  }

  static Future<void> recordTimelineTestWithoutError({
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

  static Future<void> recordTimelineTestWithError({
    bool isGlobalMode = false,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempTestFile = File('${tempDir.path}/temp_test.dart');
    final testTitle =
        '${isGlobalMode ? 'Global: ' : 'Local: '}OnError timeline - with error, prints timeline';
    await tempTestFile.writeAsString(
      testAsString(
        title: testTitle,
        timelineMode: TimelineMode.record,
        shouldFail: true,
        isGlobalMode: isGlobalMode,
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
      header,
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
      separator,
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

  static Future<void> liveTimelineWithoutErrorPrintsHtml({
    bool isGlobalMode = false,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempTestFile = File('${tempDir.path}/temp_test.dart');
    final testTitle =
        '${isGlobalMode ? 'Global: ' : 'Local: '}Live timeline without error prints html';
    await tempTestFile.writeAsString(
      testAsString(
        title: testTitle,
        timelineMode: TimelineMode.live,
        isGlobalMode: isGlobalMode,
      ),
    );

    final testProcess =
        await TestProcess.start('flutter', ['test', tempTestFile.path]);

    final stdoutBuffer = StringBuffer();

    bool write = false;
    await for (final line in testProcess.stdoutStream()) {
      if (line.isEmpty) continue;

      if (!write) {
        if (line == header) {
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
    expect(timeline.first, header);
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
      separator,
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

  static Future<void> liveTimelineWithErrorNoDuplicatesPrintsHtml({
    bool isGlobalMode = false,
  }) async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempTestFile = File('${tempDir.path}/temp_test.dart');
    final testTitle =
        '${isGlobalMode ? 'Global: ' : 'Local: '}Live timeline - with error, no duplicates, prints HTML';
    await tempTestFile.writeAsString(
      testAsString(
        title: testTitle,
        timelineMode: TimelineMode.live,
        shouldFail: true,
        isGlobalMode: isGlobalMode,
      ),
    );

    final testProcess =
        await TestProcess.start('flutter', ['test', tempTestFile.path]);

    final stdoutBuffer = StringBuffer();

    bool write = false;
    await for (final line in testProcess.stdoutStream()) {
      if (line.isEmpty) continue;

      if (!write) {
        if (line == header) {
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
    expect(timeline.first, header);
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
      separator,
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

  static String testAsString({
    required String title,
    required TimelineMode timelineMode,
    bool shouldFail = false,
    bool isGlobalMode = false,
  }) {
    final globalInitiator =
        isGlobalMode ? '${globalTimelineInitiator(timelineMode)};' : '';

    final localInitiator =
        isGlobalMode ? '' : '${localTimelineInitiator(timelineMode)};';

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
  testWidgets("$title", (WidgetTester tester) async {
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
}
