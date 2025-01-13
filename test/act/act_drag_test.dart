import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../timeline/drag/drag_until_visible_test_widget.dart';

void main() {
  // Runs the tests as executed with `flutter test`
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  globalTimelineMode = TimelineMode.always;
  assert(WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding);
  group('Drag with AutomatedTestWidgetsFlutterBinding', dragTests);
}

void dragTests() {
  testWidgets(
    'Finds widget in vertical ListView after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(
          axis: Axis.vertical,
          ignorePointerAtIndices: [0, 1, 2, 3, 4, 5, 6, 7, 8],
        ),
      );

      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
      );
      secondItem.existsOnce();
    },
  );

  testWidgets(
    'Finds widget in Column after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(
          useColumnOrRow: true,
          axis: Axis.vertical,
          ignorePointerAtIndices: [0, 1, 2, 3, 4, 5, 6, 7, 8],
        ),
      );

      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..existsOnce();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
      );
      secondItem.existsOnce();
      final position =
          secondItem.snapshotRenderBox().localToGlobal(Offset.zero);
      expect(position.toString(), const Offset(278.9, 443.0).toString());
    },
  );

  testWidgets(
    'Finds widget in horizontal ListView after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.horizontal),
      );

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 10', exact: true)
        ..doesNotExist();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
      );
      secondItem.existsOnce();
    },
  );

  testWidgets(
    'Finds widget in Row after dragging',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(
          useColumnOrRow: true,
          axis: Axis.horizontal,
        ),
      );

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 10', exact: true)
        ..existsOnce();
      await act.dragUntilVisible(
        dragStart: firstItem,
        dragTarget: secondItem,
        maxIteration: 30,
      );
      secondItem.existsOnce();
      final position =
          secondItem.snapshotRenderBox().localToGlobal(Offset.zero);
      expect(position.toString(), const Offset(606.0, 318.0).toString());
    },
  );

  testWidgets(
    'Finds widget in vertical ListView after dragging down and up',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
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
    'Finds widget in horizontal ListView after dragging to the right and back',
    (tester) async {
      await tester.pumpWidget(
        const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.horizontal),
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
        const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
      );

      final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 27', exact: true)
        ..doesNotExist();

      const expectedErrorMessage =
          'Widget with text with text "Item at index: 27" is not visible after dragging 10 times and a total dragged offset of Offset(0.0, -2250.0).';

      await expectLater(
        () => act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 10,
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
        const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.horizontal),
      );

      final firstItem = spotText('Item at index: 2', exact: true)..existsOnce();
      final secondItem = spotText('Item at index: 29', exact: true)
        ..doesNotExist();

      const expectedErrorMessage =
          'Widget with text with text "Item at index: 29" is not visible after dragging 10 times and a total dragged offset of Offset(-2500.0, 0.0).';

      await expectLater(
        () => act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 10,
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
