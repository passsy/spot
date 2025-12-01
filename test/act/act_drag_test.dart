import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  group('Vertical Drag', () {
    testWidgets(
      'Finds widget in vertical ListView after dragging',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.vertical,
            ignorePointerAtIndices: [0, 1, 2, 3, 4, 5, 6, 7, 8],
          ),
        );

        final firstItem = spotText('Item at index: 3', exact: true)
          ..existsOnce();
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

        final firstItem = spotText('Item at index: 3', exact: true)
          ..existsOnce();
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
        expect(
          position,
          within<Offset>(
            distance: 10,
            from: const Offset(278.9, 443.0),
          ),
        );
      },
    );

    testWidgets(
      'Finds widget in vertical ListView after dragging down and up',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
        );

        final firstItem = spotText('Item at index: 3', exact: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', exact: true)
          ..doesNotExist();
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 30,
        );
        secondItem.existsOnce();
        firstItem.doesNotExist();
        await tester.pumpAndSettle();
        await act.dragUntilVisible(
          dragStart: secondItem,
          dragTarget: firstItem,
          toStart: true,
        );
        await tester.pumpAndSettle();
        firstItem.existsOnce();
        secondItem.doesNotExist();
      },
    );

    testWidgets(
      'Finds, drags to and taps target in nested Column',
      (tester) async {
        await tester.pumpWidget(const NestedScrollDragUntilVisibleTestWidget());

        final firstItem =
            spotText('ParentIndex: 0, Item at index: 3', exact: true);
        final secondItem =
            spotText('ParentIndex: 2, Item at index: 4', exact: true);
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        await act.tap(secondItem);
      },
    );

    testWidgets(
      'Finds widget in vertical ListView after dragging when dragStart is a Scrollable',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.vertical,
            ignorePointerAtIndices: [0, 1, 2, 3, 4, 5, 6, 7, 8],
          ),
        );

        final firstItem = spot<DragUntilVisibleSingleDirectionTestWidget>()
            .spot<Scrollable>()
            .last()
          ..existsOnce();
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
  });

  group('Horizontal Drag', () {
    testWidgets(
      'Finds widget in horizontal ListView after dragging',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
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

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
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
        expect(
          position,
          within<Offset>(
            distance: 10,
            from: const Offset(606.0, 318.0),
          ),
        );
      },
    );

    testWidgets(
      'Finds widget in horizontal ListView after dragging to the right and back',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 10', exact: true)
          ..doesNotExist();
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 30,
        );
        secondItem.existsOnce();
        firstItem.doesNotExist();
        await tester.pumpAndSettle();
        await act.dragUntilVisible(
          dragStart: secondItem,
          dragTarget: firstItem,
          toStart: true,
        );
        await tester.pumpAndSettle();
        firstItem.existsOnce();
        secondItem.doesNotExist();
      },
    );

    testWidgets(
      'Finds, drags to and taps target in nested Row',
      (tester) async {
        await tester.pumpWidget(
          const NestedScrollDragUntilVisibleTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spot<Container>()
            .spotText('ParentIndex: 0, Item at index: 3', exact: true);
        final secondItem =
            spotText('ParentIndex: 2, Item at index: 4', exact: true);
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        await act.tap(secondItem);
      },
    );
  });

  group('Errors', () {
    testWidgets(
      'Throws TestFailure if not found in vertical ListView',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
        );

        final firstItem = spotText('Item at index: 3', exact: true)
          ..existsOnce();
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
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
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

    testWidgets(
      'Providing both `moveStep` and `toStart = true` should throw AssertionError',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', exact: true)
          ..doesNotExist();

        await expectLater(
          () => act.dragUntilVisible(
            dragStart: firstItem,
            dragTarget: secondItem,
            moveStep: const Offset(1, 0),
            toStart: true,
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.toString(),
              'description',
              contains(
                'You can either provide `moveStep`, or set `toStart` to true, or neither, '
                'but not both.',
              ),
            ),
          ),
        );
      },
    );

    testWidgets(
      'Providing a zero Offset(0, 0) should throw AssertionError',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', exact: true)
          ..doesNotExist();

        await expectLater(
          () => act.dragUntilVisible(
            dragStart: firstItem,
            dragTarget: secondItem,
            moveStep: Offset.zero,
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.toString(),
              'description',
              contains(
                'If `moveStep` is provided, one of dx or dy must be non-zero. '
                'Both dx and dy being 0 results in no dragging. '
                'Both being non-zero implicates diagonal dragging, which is not supported.',
              ),
            ),
          ),
        );
      },
    );

    testWidgets(
      'Providing a diagonal offset (e.g., Offset(1, 1)) should throw AssertionError',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', exact: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', exact: true)
          ..doesNotExist();

        await expectLater(
          () => act.dragUntilVisible(
            dragStart: firstItem,
            dragTarget: secondItem,
            moveStep: const Offset(1, 1),
          ),
          throwsA(
            isA<AssertionError>().having(
              (error) => error.toString(),
              'description',
              contains(
                'If `moveStep` is provided, one of dx or dy must be non-zero. '
                'Both dx and dy being 0 results in no dragging. '
                'Both being non-zero implicates diagonal dragging, which is not supported.',
              ),
            ),
          ),
        );
      },
    );
  });
}
