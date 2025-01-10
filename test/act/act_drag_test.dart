import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../timeline/drag/drag_until_visible_test_widget.dart';

void main() {
  // Runs the tests as executed with `flutter test`
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding);
  group('Drag with AutomatedTestWidgetsFlutterBinding', dragTests);
}

void dragTests() {
  testWidgets(
    'Finds widget in vertical ListView after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(axis: Axis.vertical),
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
    },
  );

  testWidgets(
    'Finds widget in horizontal ListView after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(axis: Axis.horizontal),
      );

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 10', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
        moveStep: const Offset(-100, 0),
      );
      secondItem.existsOnce();
    },
  );

  testWidgets(
    'Finds widget in vertical ListView after dragging down and up',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(axis: Axis.vertical),
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
      firstItem.doesNotExist();
      await tester.pumpAndSettle();
      await act.dragUntilVisible(
        dragStart: secondItem,
        dragTarget: firstItem,
        moveStep: const Offset(0, 100),
      );
      await tester.pumpAndSettle();
      firstItem.existsOnce();
      secondItem.doesNotExist();
    },
  );

  testWidgets(
    'Finds widget in horizontal ListView after to the right back',
    (tester) async {
      await tester
          .pumpWidget(const DragUntilVisibleTestWidget(axis: Axis.horizontal));

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 10', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
        moveStep: const Offset(-100, 0),
      );
      secondItem.existsOnce();
      firstItem.doesNotExist();
      await tester.pumpAndSettle();
      await act.dragUntilVisible(
        dragStart: secondItem,
        dragTarget: firstItem,
        moveStep: const Offset(100, 0),
      );
      await tester.pumpAndSettle();
      firstItem.existsOnce();
      secondItem.doesNotExist();
    },
  );

  testWidgets(
    'Throws TestFailure if not found in vertical ListView',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(axis: Axis.vertical),
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
    },
  );

  testWidgets(
    'Throws TestFailure if not found in horizontal ListView',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleTestWidget(axis: Axis.horizontal),
      );

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 10', exact: true)
        ..doesNotExist();

      const expectedErrorMessage =
          'Widget with text with text "Item at index: 10" is not visible after dragging 10 times and a total dragged offset of Offset(-1000.0, 0.0).';

      await expectLater(
        () => act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 10,
          moveStep: const Offset(-100, 0),
        ),
        throwsA(
          isA<TestFailure>().having(
            (error) => error.message,
            'message',
            expectedErrorMessage,
          ),
        ),
      );
    },
  );
}
