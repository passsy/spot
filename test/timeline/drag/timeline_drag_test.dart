import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:test_process/test_process.dart';
import '../../util/capture_console_output.dart';
import '../timeline_test_shared.dart' as shared;
import 'drag_until_visible_test_widget.dart';

final _firstItemSelector = spotText('Item at index: 3', exact: true);
final _secondItemSelector = spotText('Item at index: 27', exact: true);

const _failingDragAmount = 10;
const _failingOffset = Offset(0, -1000);
const _passingDragAmount = 23;
const _passingOffset = Offset(0, -2300);

const _header = '==================== Timeline Event ====================';

String _testAsString({
  required String title,
  required TimelineMode timelineMode,
  required int drags,
}) {
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
  ${shared.localTimelineInitiator(timelineMode)};
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

void main() {
  group('Drag Timeline Test', () {
    group('Without error', () {
      testWidgets('Drag Until Visible - Live timeline', (tester) async {
        final output = await captureConsoleOutput(() async {
          timeline.mode = TimelineMode.live;
          await _testBody(tester);
          // Notify that the timeline of this type is already recording.
          timeline.mode = TimelineMode.live;
        });
        expect(output, contains('🔴 - Now recording live timeline'));
        _testTimeLineContent(
          output: output,
          totalExpectedOffset: _passingOffset,
          drags: _passingDragAmount,
        );
        expect(output, contains('🔴 - Already recording live timeline'));
      });
      testWidgets('Start with Timeline Mode off', (tester) async {
        final output = await captureConsoleOutput(() async {
          timeline.mode = TimelineMode.off;
          await _testBody(tester);
        });
        final splitted = output.split('\n')
          ..removeWhere((line) => line.isEmpty);
        const expectedOutput = '⏸︎ - Timeline recording is off';
        expect(splitted.length, 1);
        expect(splitted.first, expectedOutput);
      });
      testWidgets('Turn timeline mode off during test', (tester) async {
        final output = await captureConsoleOutput(() async {
          timeline.mode = TimelineMode.record;
          await _testBody(tester);
          // Notify that the recording is off
          timeline.mode = TimelineMode.off;
          timeline.mode = TimelineMode.off;
        });
        expect(output, contains('🔴 - Now recording live timeline'));

        _testTimeLineContent(
          output: output,
          totalExpectedOffset: _passingOffset,
          drags: _passingDragAmount,
        );

        expect(output, contains('⏸︎ - Timeline recording stopped'));
        expect(output, contains('⏸︎ - Timeline recording is off'));
      });
      testWidgets('act.drag: OnError timeline - without error', (tester) async {
        final output = await captureConsoleOutput(() async {
          timeline.mode = TimelineMode.record;
          await _testBody(tester);
          timeline.mode = TimelineMode.record;
        });
        final lines = output.split('\n')..removeWhere((line) => line.isEmpty);
        expect(lines.first, '🔴 - Now recording error output timeline');
        expect(lines.second, '🔴 - Already recording error output timeline');

        // Neither timeline output nor HTML link when onError timeline is
        // recorded and no error occurs.
        expect(lines.length, 2);
      });
    });
    group('Teardown test', () {
      test('OnError timeline - with error, prints timeline and html', () async {
        final tempDir = Directory.systemTemp.createTempSync();
        final tempTestFile = File('${tempDir.path}/temp_test.dart');

        await tempTestFile.writeAsString(
          _testAsString(
            title: 'OnError timeline - with error, prints timeline',
            timelineMode: TimelineMode.record,
            drags: _failingDragAmount,
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
          drags: _failingDragAmount,
          totalExpectedOffset: _failingOffset,
          runInTestProcess: true,
        );

        final htmlLine = stdout
            .split('\n')
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
            title: 'Live timeline - without error, prints HTML',
            timelineMode: TimelineMode.live,
            drags: _passingDragAmount,
          ),
        );
        final testProcess =
            await TestProcess.start('flutter', ['test', tempTestFile.path]);
        final stdoutBuffer = StringBuffer();
        bool write = false;

        await for (final line in testProcess.stdoutStream()) {
          if (line.isEmpty) continue;

          if (!write) {
            if (line == 'Timeline' || line == _header) {
              write = true;
            }
          }

          if (write) {
            stdoutBuffer.writeln(line);
          }
        }

        await testProcess.shouldExit(0);

        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }

        final stdout = stdoutBuffer.toString();

        // Does not start with 'Timeline', this only happens on error
        expect(stdout.startsWith('Timeline'), isFalse);

        _testTimeLineContent(
          output: stdout,
          drags: _passingDragAmount,
          totalExpectedOffset: _passingOffset,
          runInTestProcess: true,
        );

        final htmlLine = stdout
            .split('\n')
            .firstWhere((line) => line.startsWith('View time line here:'));

        expect(
          htmlLine.endsWith(
            'timeline-live-timeline-without-error-prints-html.html',
          ),
          isTrue,
        );
      });
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
  required Offset totalExpectedOffset,
  required int drags,
  bool runInTestProcess = false,
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
      RegExp('Caller: at ${runInTestProcess ? 'main' : '_testBody'}')
          .allMatches(output)
          .length,
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
