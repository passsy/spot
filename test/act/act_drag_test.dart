import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../timeline/drag/drag_until_visible_test_widget.dart';

void main() {
  group('Drag Events', () {
    testWidgets('Finds widget after dragging', (tester) async {
      recordLiveTimeline();
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(),
      );

      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
        moveStep: const Offset(0, -100),
      );
      secondItem.existsOnce();
    });

    testWidgets('Throws TestFailure if not found', (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(),
      );

      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();

      const expectedErrorMessage =
          'Widget with text with text "Item at index: 27" is not visible after dragging 10 times and a total dragged offset of Offset(0.0, -1000.0).';

      await expectLater(
        () => act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 10,
          moveStep: const Offset(0, -100),
        ),
        throwsA(
          isA<TestFailure>().having(
            (error) => error.message,
            'message',
            expectedErrorMessage,
          ),
        ),
      );
    });
  });
}
