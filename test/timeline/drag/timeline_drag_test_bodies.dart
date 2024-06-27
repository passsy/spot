import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../../util/capture_console_output.dart';
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
