import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:test_process/test_process.dart';

import 'timeline_test_widget.dart';

Iterable<RegExpMatch> _screenshotMessageMatcher(String outPut) =>
    RegExp('Screenshot: file:').allMatches(outPut);
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
    expect(output, contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'));
    expect(
      output,
      contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(output, contains('🔴 - Already recording live timeline'));
    expect(_screenshotMessageMatcher(output).length, 2);
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
    expect(_screenshotMessageMatcher(output).length, 0);
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
    expect(_screenshotMessageMatcher(output).length, 2);
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
      expect(_screenshotMessageMatcher(output).length, 0);
      expect(output, contains('🔴 - Already recording error output timeline'));
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

      final tempDir = Directory.systemTemp.createTempSync();
      final tempTestFile = File('${tempDir.path}/temp_test.dart');
      await tempTestFile.writeAsString(testAsString);

      final testProcess =
          await TestProcess.start('flutter', ['test', tempTestFile.path]);

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

      await testProcess.shouldExit();

      tempDir.deleteSync(recursive: true);

      final stdout = stdoutBuffer.toString();

      final timeline = stdout.split('\n');
      expect(timeline.first, 'Timeline');
      expect(
        timeline[1].startsWith(
          'Tap Icon Widget with icon: "IconData(U+0E047)" at main.<fn> file:///',
        ),
        isTrue,
      );
      expect(
        timeline[2].startsWith(
          'Screenshot: file:///',
        ),
        isTrue,
      );
      expect(
        timeline[3].startsWith(
          'Tap Icon Widget with icon: "IconData(U+0E516)" at main.<fn> file:///',
        ),
        isTrue,
      );
      expect(
        timeline[4].startsWith(
          'Screenshot: file:///',
        ),
        isTrue,
      );
    });
  });
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
