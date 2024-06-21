import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:test_process/test_process.dart';
import '../../util/capture_console_output.dart';
import 'drag_until_visible_test_widget.dart';

final _firstItemSelector = spotText('Item at index: 3', exact: true);
final _secondItemSelector = spotText('Item at index: 27', exact: true);

const _header = '==================== Timeline Event ====================';
// const _separator = '========================================================';

String _testAsString({
  required String title,
  required TimelineMode timelineMode,
  bool shouldFail = false,
}) {
  final String methodForMode = () {
    switch (timelineMode) {
      case TimelineMode.live:
        return 'recordLiveTimeline()';
      case TimelineMode.record:
        return 'recordOnErrorTimeline()';
      case TimelineMode.off:
        return 'stopRecordingTimeline()';
    }
  }();

  final widgetPart =
      File('test/timeline/drag/drag_until_visible_test_widget.dart')
          .readAsStringSync();
  return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';\n
$widgetPart\n
void main() async {
  testWidgets("$title", (WidgetTester tester) async {
    $methodForMode;
    await tester.pumpWidget(const DragUntilVisibleTestWidget());
      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: ${shouldFail ? '10' : '30'},
        moveStep: const Offset(0, -100),
      );
      secondItem.existsOnce();
  });
}
''';
}

void main() {
  group('Drag Timeline Test', () {
    testWidgets('Drag Until Visible - Live timeline', (tester) async {
      final output = await captureConsoleOutput(() async {
        recordLiveTimeline();
        await tester.pumpWidget(const DragUntilVisibleTestWidget());
        _firstItemSelector.existsOnce();
        _secondItemSelector.doesNotExist();
        await act.dragUntilVisible(
          dragStart: _firstItemSelector,
          dragTarget: _secondItemSelector,
          maxIteration: 30,
          moveStep: const Offset(0, -100),
        );
        _secondItemSelector.existsOnce();
        // Notify that the timeline of this type is already recording.
        recordLiveTimeline();
      });
      expect(output, contains('🔴 - Now recording live timeline'));
      _testTimeLineContent(
        output: output,
        totalExpectedOffset: const Offset(0, -2300),
        drags: 23,
      );
      expect(output, contains('🔴 - Already recording live timeline'));
    });
    testWidgets('Start with Timeline Mode off', (tester) async {
      final output = await captureConsoleOutput(() async {
        stopRecordingTimeline();
        await tester.pumpWidget(const DragUntilVisibleTestWidget());
        _firstItemSelector.existsOnce();
        _secondItemSelector.doesNotExist();
        await act.dragUntilVisible(
          dragStart: _firstItemSelector,
          dragTarget: _secondItemSelector,
          maxIteration: 30,
          moveStep: const Offset(0, -100),
        );
        _secondItemSelector.existsOnce();
      });
      final splitted = output.split('\n')..removeWhere((line) => line.isEmpty);
      const expectedOutput = '⏸︎ - Timeline recording is off';
      expect(splitted.length, 1);
      expect(splitted.first, expectedOutput);
    });
    testWidgets('Turn timeline mode off during test', (tester) async {
      final output = await captureConsoleOutput(() async {
        recordLiveTimeline();
        await tester.pumpWidget(const DragUntilVisibleTestWidget());
        _firstItemSelector.existsOnce();
        _secondItemSelector.doesNotExist();
        await act.dragUntilVisible(
          dragStart: _firstItemSelector,
          dragTarget: _secondItemSelector,
          maxIteration: 30,
          moveStep: const Offset(0, -100),
        );
        _secondItemSelector.existsOnce();

        // Notify that the recording is off
        stopRecordingTimeline();
        stopRecordingTimeline();
      });
      expect(output, contains('🔴 - Now recording live timeline'));
      _testTimeLineContent(
        output: output,
        totalExpectedOffset: const Offset(0, -2300),
        drags: 23,
      );

      expect(output, contains('⏸︎ - Timeline recording stopped'));
      expect(output, contains('⏸︎ - Timeline recording is off'));
    });

    group('Print on teardown', () {
      testWidgets('OnError timeline - without error', (tester) async {
        final output = await captureConsoleOutput(() async {
          recordOnErrorTimeline();
          await tester.pumpWidget(const DragUntilVisibleTestWidget());
          _firstItemSelector.existsOnce();
          _secondItemSelector.doesNotExist();
          await act.dragUntilVisible(
            dragStart: _firstItemSelector,
            dragTarget: _secondItemSelector,
            maxIteration: 30,
            moveStep: const Offset(0, -100),
          );
          _secondItemSelector.existsOnce();
          recordOnErrorTimeline();
        });
        final splitted = output.split('\n')
          ..removeWhere((line) => line.isEmpty);
        expect(splitted.length, 2);
        expect(splitted.first, '🔴 - Now recording error output timeline');
        expect(splitted.second, '🔴 - Already recording error output timeline');
      });
      test('OnError timeline - with error, prints timeline', () async {
        final tempDir = Directory.systemTemp.createTempSync();
        final tempTestFile = File('${tempDir.path}/temp_test.dart');
        await tempTestFile.writeAsString(
          _testAsString(
            title: 'Drag - OnError timeline with error',
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

          if (!write) {
            if (line == 'Timeline') {
              write = true;
            }
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
        _testTimeLineContent(
          output: stdout,
          drags: 10,
          totalExpectedOffset: const Offset(0, -1000),
          findsWidget: false,
        );

        final htmlLine = stdout
            .split('\n')
            .firstWhere((line) => line.startsWith('View time line here:'));

        expect(
          htmlLine.endsWith(
            'timeline_drag_-_onerror_timeline_with_error.html',
          ),
          isTrue,
        );
      });
      // test('Live timeline - without error, prints HTML', () async {
      //   final tempDir = Directory.systemTemp.createTempSync();
      //   final tempTestFile = File('${tempDir.path}/temp_test.dart');
      //   await tempTestFile.writeAsString(
      //     _testAsString(
      //       title: 'Live timeline without error prints html',
      //       timelineMode: TimelineMode.live,
      //     ),
      //   );
      //   final testProcess =
      //       await TestProcess.start('flutter', ['test', tempTestFile.path]);
      //   final stdoutBuffer = StringBuffer();
      //   bool write = false;
      //   await for (final line in testProcess.stdoutStream()) {
      //     if (line.isEmpty) continue;
      //     if (!write) {
      //       if (line == _header) {
      //         write = true;
      //       }
      //       if (write) {
      //         stdoutBuffer.writeln(line);
      //       } // Error does not happen
      //     }
      //     await testProcess.shouldExit(0);
      //     tempDir.deleteSync(recursive: true);
      //     final stdout = stdoutBuffer.toString();
      //     final timeline = stdout.split('\n');
      //     // Does not start with 'Timeline', this only happens on error
      //     expect(timeline.first, _header);
      //     expect(
      //       timeline.second,
      //       'Event: Tap Icon Widget with icon: "IconData(U+0E047)"',
      //     );
      //     expect(
      //       timeline[2].startsWith('Caller: at main.<fn> file:///'),
      //       isTrue,
      //     );
      //     expect(
      //       timeline[3].startsWith(
      //         'Screenshot: file:///',
      //       ),
      //       isTrue,
      //     );
      //     expect(
      //       timeline[4].startsWith(
      //         'Timestamp:',
      //       ),
      //       isTrue,
      //     );
      //     expect(
      //       timeline[5],
      //       _separator,
      //     );
      //     final htmlLine = timeline
      //         .firstWhere((line) => line.startsWith('View time line here:'));
      //     expect(
      //       htmlLine.endsWith(
      //         'timeline_live_timeline_without_error_prints_html.html',
      //       ),
      //       isTrue,
      //     );
      //   }
      // });
      // test('Live timeline - with error, no duplicates, prints HTML', () async {
      //   final tempDir = Directory.systemTemp.createTempSync();
      //   final tempTestFile = File('${tempDir.path}/temp_test.dart');
      //   await tempTestFile.writeAsString(
      //     _testAsString(
      //       title: 'Live timeline - with error, no duplicates, prints HTML',
      //       timelineMode: TimelineMode.live,
      //       shouldFail: true,
      //     ),
      //   );
      //   final testProcess =
      //       await TestProcess.start('flutter', ['test', tempTestFile.path]);
      //   final stdoutBuffer = StringBuffer();
      //   bool write = false;
      //   await for (final line in testProcess.stdoutStream()) {
      //     if (line.isEmpty) continue;
      //     if (!write) {
      //       if (line == _header) {
      //         write = true;
      //       }
      //       if (write) {
      //         stdoutBuffer.writeln(line);
      //       } // Error does not happen
      //       await testProcess.shouldExit(1);
      //       tempDir.deleteSync(recursive: true);
      //       final stdout = stdoutBuffer.toString();
      //       final timeline = stdout.split('\n');
      //       // Does not start with 'Timeline', this only happens on error
      //       expect(timeline.first, _header);
      //       expect(
      //         timeline.second,
      //         'Event: Tap Icon Widget with icon: "IconData(U+0E047)"',
      //       );
      //       expect(
      //         timeline[2].startsWith('Caller: at main.<fn> file:///'),
      //         isTrue,
      //       );
      //       expect(
      //         timeline[3].startsWith(
      //           'Screenshot: file:///',
      //         ),
      //         isTrue,
      //       );
      //       expect(
      //         timeline[4].startsWith(
      //           'Timestamp:',
      //         ),
      //         isTrue,
      //       );
      //       expect(
      //         timeline[5],
      //         _separator,
      //       );
      //       final htmlLine = timeline
      //           .firstWhere((line) => line.startsWith('View time line here:'));
      //       expect(
      //         htmlLine.endsWith(
      //           'live_timeline_-_with_error,_no_duplicates,_prints_html.html',
      //         ),
      //         isTrue,
      //       );
      //     }
      //   }
      // });
    });
  });
}

void _testTimeLineContent({
  required String output,
  bool findsWidget = true,
  required Offset totalExpectedOffset,
  required int drags,
}) {
  final isGoingDown = totalExpectedOffset.dy < 0;
  final eventLines =
      output.split('\n').where((line) => line.startsWith('Event:'));
  final startEvent = _replaceOffsetWithDxDy(eventLines.first);
  final endEvent =
      'Event: Target ${_secondItemSelector.toStringBreadcrumb()} ${findsWidget ? 'found' : 'not found'} after $drags drags. Total dragged offset: $totalExpectedOffset';

  for (int i = 0; i < 2; i++) {
    expect(
      RegExp(_header).allMatches(output).length,
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
      RegExp('Caller: at main').allMatches(output).length,
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
