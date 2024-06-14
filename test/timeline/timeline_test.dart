import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:test_process/test_process.dart';

import 'timeline_test_widget.dart';

final _addButtonSelector = spotIcon(Icons.add);
final _subtractButtonSelector = spotIcon(Icons.remove);
final _clearButtonSelector = spotIcon(Icons.clear);

void main() {
  testWidgets('Live timeline', (tester) async {
    final output = await _captureConsoleOutput(() async {
      recordLiveTimeline();
      await tester.pumpWidget(const TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      // Notify that the timeline of this type is already recording.
      recordLiveTimeline();
    });
    expect(output, contains('🔴 - Now recording live timeline'));
    expect(
      output,
      contains('Event: Tap ${_addButtonSelector.toStringBreadcrumb()}'),
    );
    expect(
      output,
      contains('Event: Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(output, contains('🔴 - Already recording live timeline'));
    _testTimeLineContent(output: output, eventCount: 2);
  });
  testWidgets('Start with Timeline Mode off', (tester) async {
    final output = await _captureConsoleOutput(() async {
      stopRecordingTimeline();
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
    final output = await _captureConsoleOutput(() async {
      recordLiveTimeline();
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
      stopRecordingTimeline();
      await act.tap(_clearButtonSelector);
      spotText('Counter: 0').existsOnce();
      // Notify that the recording is off
      stopRecordingTimeline();
    });
    expect(output, contains('🔴 - Now recording live timeline'));
    expect(output, contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'));
    expect(
      output,
      contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(output, contains('⏸︎ - Timeline recording stopped'));
    // No further events were added to the timeline, including screenshots
    expect(
      output,
      isNot(contains('Tap ${_clearButtonSelector.toStringBreadcrumb()}')),
    );
    _testTimeLineContent(output: output, eventCount: 2);
    expect(output, contains('⏸︎ - Timeline recording is off'));
  });

  group('onError timeline', () {
    testWidgets('OnError timeline - without error', (tester) async {
      final output = await _captureConsoleOutput(() async {
        recordOnErrorTimeline();
        await tester.pumpWidget(const TimelineTestWidget());
        _addButtonSelector.existsOnce();
        spotText('Counter: 3').existsOnce();
        await act.tap(_addButtonSelector);
        spotText('Counter: 4').existsOnce();
        await act.tap(_subtractButtonSelector);
        spotText('Counter: 3').existsOnce();
        // Notify that the timeline of this type is already recording.
        recordOnErrorTimeline();
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
      const importPart = '''
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';
''';

      final widgetPart =
          File('test/timeline/timeline_test_widget.dart').readAsStringSync();

      const testPart = '''
void main() async {
  final addButtonSelector = spotIcon(Icons.add);
  final subtractButtonSelector = spotIcon(Icons.remove);
  testWidgets('OnError timeline with error', (WidgetTester tester) async {
    recordOnErrorTimeline();
    await tester.pumpWidget(const TimelineTestWidget());
      addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      // Make test fail intentionally
      spotText('Counter: 99').existsOnce();
  });
}
''';
      final testAsString = [importPart, widgetPart, testPart].join('\n');
String result = "";
        final tempDir = Directory.systemTemp.createTempSync();
      try{
        final tempTestFile = File('${tempDir.path}/temp_test.dart');
        await tempTestFile.writeAsString(testAsString);

        final testProcess = await TestProcess.start(
          'flutter',
          ['test', tempTestFile.path],
          runInShell: true,
        );

        final stdoutBuffer = StringBuffer();

        bool write = false;
        await for (final line in testProcess.stdoutStream()) {
          if (line == 'Timeline') {
            write = true;
          }
          if (line.startsWith('To run this test again:')) {
            write = false;
          }
          if (write) {
            stdoutBuffer.writeln(line);
          }
        }

        await testProcess.shouldExit(1);
        result = stdoutBuffer.toString();
      }catch(_, __){

      }

      if(tempDir.existsSync()){
        tempDir.deleteSync(recursive: true);
      }


      if(result.isEmpty) {
        throw TestFailure('No output from test process');
      }

      final timeline = result.split('\n')..removeWhere((line) => line.isEmpty);
 
      expect(timeline.first, 'Timeline');
      expect(
        timeline[1],
        '==================== Timeline Event ====================',
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
        '========================================================',
      );
      expect(
        timeline.last,
        startsWith('View time line here:'),
      );
    });
  });
}

void _testTimeLineContent({
  required String output,
  required int eventCount,
}) {
  expect(
    RegExp('==================== Timeline Event ====================')
        .allMatches(output)
        .length,
    eventCount,
  );
  expect(
    RegExp('Event: Tap Icon Widget with icon:').allMatches(output).length,
    eventCount,
  );
  expect(
    RegExp('Caller: at main.<fn>.<fn> file:///').allMatches(output).length,
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

Future<String> _captureConsoleOutput(
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
