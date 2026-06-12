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

        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', whole: true)
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

        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', whole: true)
          ..existsOnce();
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 30,
        );
        secondItem.existsOnce();
        final position =
            secondItem.snapshotRenderBox().localToGlobal(Offset.zero);
        // Target lands at the top of the viewport (cross-axis x preserved).
        expect(
          position,
          within<Offset>(
            distance: 10,
            from: const Offset(278.9, 287.0),
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

        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', whole: true)
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
            spotText('ParentIndex: 0, Item at index: 3', whole: true);
        final secondItem =
            spotText('ParentIndex: 2, Item at index: 4', whole: true);
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

  group('Horizontal Drag', () {
    testWidgets(
      'Finds widget in horizontal ListView after dragging',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 10', whole: true)
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 10', whole: true)
          ..existsOnce();
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          maxIteration: 30,
        );
        secondItem.existsOnce();
        final position =
            secondItem.snapshotRenderBox().localToGlobal(Offset.zero);
        // Target lands at the left of the viewport (cross-axis y preserved).
        expect(
          position,
          within<Offset>(
            distance: 10,
            from: const Offset(150.0, 318.0),
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 10', whole: true)
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
            .spotText('ParentIndex: 0, Item at index: 3', whole: true);
        final secondItem =
            spotText('ParentIndex: 2, Item at index: 4', whole: true);
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

        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', whole: true)
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', whole: true)
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', whole: true)
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', whole: true)
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

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 29', whole: true)
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

  group('Padding parameter', () {
    testWidgets(
      'padding.top keeps target below padded area in vertical ListView',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
        );

        final firstItem = spotKey<Container>(const ValueKey('item-3'))
          ..existsOnce();
        // Use a mid-list target so the scrollable can reach the desired
        // alignment (later targets get clamped at max scroll).
        final secondItem = spotKey<Container>(const ValueKey('item-15'))
          ..doesNotExist();

        const paddingTop = 100.0;
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          padding: const EdgeInsets.only(top: paddingTop),
        );
        secondItem.existsOnce();

        final scrollable =
            spot<Scrollable>().withChild(secondItem).last().snapshotRenderBox();
        final viewportTop = scrollable.localToGlobal(Offset.zero).dy;
        final targetTop =
            secondItem.snapshotRenderBox().localToGlobal(Offset.zero).dy;
        // Target's top is at or below the padded edge (within 1px tolerance).
        expect(targetTop, greaterThanOrEqualTo(viewportTop + paddingTop - 1));
        // ...but not far below it - the drag aligns with the padded edge.
        expect(targetTop, lessThan(viewportTop + paddingTop + 5));
      },
    );

    testWidgets(
      'padding.left keeps target right of padded area in horizontal ListView',
      (tester) async {
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(
            axis: Axis.horizontal,
          ),
        );

        final firstItem = spotKey<Container>(const ValueKey('item-2'))
          ..existsOnce();
        final secondItem = spotKey<Container>(const ValueKey('item-12'))
          ..doesNotExist();

        const paddingLeft = 80.0;
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          padding: const EdgeInsets.only(left: paddingLeft),
        );
        secondItem.existsOnce();

        final scrollable =
            spot<Scrollable>().withChild(secondItem).last().snapshotRenderBox();
        final viewportLeft = scrollable.localToGlobal(Offset.zero).dx;
        final targetLeft =
            secondItem.snapshotRenderBox().localToGlobal(Offset.zero).dx;
        expect(
            targetLeft, greaterThanOrEqualTo(viewportLeft + paddingLeft - 1));
        expect(targetLeft, lessThan(viewportLeft + paddingLeft + 5));
      },
    );

    testWidgets(
      'padding still triggers a final scroll when target overlaps padded area',
      (tester) async {
        // Verifies that when the target's natural position would place it
        // inside the padded area, dragUntilVisible performs an additional
        // drag to move it out of the padding.
        await tester.pumpWidget(
          const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
        );

        final firstItem = spotKey<Container>(const ValueKey('item-3'));
        final secondItem = spotKey<Container>(const ValueKey('item-10'))
          ..doesNotExist();

        const paddingTop = 60.0;
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          padding: const EdgeInsets.only(top: paddingTop),
        );

        final scrollable =
            spot<Scrollable>().withChild(secondItem).last().snapshotRenderBox();
        final viewportTop = scrollable.localToGlobal(Offset.zero).dy;
        final targetTop =
            secondItem.snapshotRenderBox().localToGlobal(Offset.zero).dy;
        expect(targetTop, greaterThanOrEqualTo(viewportTop + paddingTop - 1));
      },
    );
  });

  group('Cross-axis fix', () {
    testWidgets(
      'avatar dragStart + tile target: outer cross-axis scrollable does not '
      'move (vertical inner)',
      (tester) async {
        // Reproduces the original use case for the cross-axis fix: the user
        // drags from a small AVATAR inside a list item and wants the whole
        // TILE visible. Avatar and tile sit at different cross-axis
        // positions; without locking the final drag to the scroll axis the
        // diagonal would scroll the outer (horizontal) scrollable.
        await tester.pumpWidget(
          const CrossAxisNestedScrollableTestWidget(innerAxis: Axis.vertical),
        );

        final outerState =
            tester.state<CrossAxisNestedScrollableTestWidgetState>(
          find.byType(CrossAxisNestedScrollableTestWidget),
        );

        final dragStart = spotKey<Container>(const ValueKey('avatar-3'))
          ..existsOnce();
        final target = spotKey<Container>(const ValueKey('tile-24'))
          ..doesNotExist();

        await act.dragUntilVisible(
          dragStart: dragStart,
          dragTarget: target,
        );
        target.existsOnce();

        expect(outerState.outerHasMoved, isFalse);
      },
    );

    testWidgets(
      'avatar dragStart + tile target: outer cross-axis scrollable does not '
      'move (horizontal inner)',
      (tester) async {
        await tester.pumpWidget(
          const CrossAxisNestedScrollableTestWidget(
            innerAxis: Axis.horizontal,
          ),
        );

        final outerState =
            tester.state<CrossAxisNestedScrollableTestWidgetState>(
          find.byType(CrossAxisNestedScrollableTestWidget),
        );

        final dragStart = spotKey<Container>(const ValueKey('avatar-2'))
          ..existsOnce();
        final target = spotKey<Container>(const ValueKey('tile-21'))
          ..doesNotExist();

        await act.dragUntilVisible(
          dragStart: dragStart,
          dragTarget: target,
        );
        target.existsOnce();

        // Outer (vertical) scrollable must not have moved.
        expect(outerState.outerHasMoved, isFalse);
      },
    );
  });

  group('Final adjustment drag never registers as tap', () {
    testWidgets(
      'tappable items are never tapped during dragUntilVisible (vertical)',
      (tester) async {
        final taps = <int, int>{};
        await tester.pumpWidget(
          DragUntilVisibleTappableTestWidget(
            axis: Axis.vertical,
            onItemTap: (index) {
              taps[index] = (taps[index] ?? 0) + 1;
            },
          ),
        );

        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 27', whole: true)
          ..doesNotExist();

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
        );
        secondItem.existsOnce();

        expect(taps, isEmpty);
      },
    );

    testWidgets(
      'tappable items are never tapped during dragUntilVisible (horizontal)',
      (tester) async {
        final taps = <int, int>{};
        await tester.pumpWidget(
          DragUntilVisibleTappableTestWidget(
            axis: Axis.horizontal,
            onItemTap: (index) {
              taps[index] = (taps[index] ?? 0) + 1;
            },
          ),
        );

        final firstItem = spotText('Item at index: 2', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 20', whole: true)
          ..doesNotExist();

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
        );
        secondItem.existsOnce();

        expect(taps, isEmpty);
      },
    );

    testWidgets(
      'engineered small final adjustment does not register as tap',
      (tester) async {
        // Engineer a final adjustment smaller than kDragSlopDefault (20):
        // moveStep is tuned so step 1 stops with the target's top just a few
        // pixels above the viewport top, leaving < 20 px of final alignment.
        // Without the overshoot/return fix this would register as a tap on
        // whichever item happens to lie under dragBeginPosition.
        final taps = <int, int>{};
        await tester.pumpWidget(
          DragUntilVisibleTappableTestWidget(
            axis: Axis.vertical,
            onItemTap: (index) {
              taps[index] = (taps[index] ?? 0) + 1;
            },
          ),
        );

        // Items are 100 tall. Default cacheExtent is 250. Target item 8 sits
        // at content y=800 (outside initial cache [-250, 700]). A single drag
        // of -810 puts scroll past the target by 10 px — small final drag.
        final firstItem = spotText('Item at index: 3', whole: true)
          ..existsOnce();
        final secondItem = spotText('Item at index: 8', whole: true);

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          moveStep: const Offset(0, -810),
        );
        secondItem.existsOnce();

        expect(taps, isEmpty);
      },
    );
  });

  group('No pointer-down inside padded/obscured area', () {
    testWidgets(
      'top banner covers 90% of scrollable - no pointer down lands on banner',
      (tester) async {
        // A top banner covers the top 90% of the scrollable, simulating a
        // fixed header that overlaps the content. With padding.top matching
        // the banner height, dragUntilVisible must keep its touch points
        // below the banner, otherwise it would tap it.
        final pointerDowns = <Offset>[];
        int bannerTaps = 0;

        const topBannerHeight = 450.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) => pointerDowns.add(event.position),
            onTopBannerTap: () => bannerTaps++,
            topBannerHeight: topBannerHeight,
          ),
        );

        // dragStart must have a visible portion below the banner.
        // With banner covering top 450 px and items 100 px tall, item 4
        // (content y 400-500) has its bottom 50 px visible at startup.
        final firstItem = spotKey<Container>(const ValueKey('item-4'));
        final secondItem = spotKey<Container>(const ValueKey('item-15'));

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          padding: const EdgeInsets.only(top: topBannerHeight),
        );

        final obscuredRect = _topBannerRect(secondItem, topBannerHeight);
        for (final pos in pointerDowns) {
          expect(
            obscuredRect.contains(pos),
            isFalse,
            reason:
                'Pointer down at $pos lands inside top banner $obscuredRect.',
          );
        }
        expect(
          bannerTaps,
          0,
          reason: 'The top banner registered $bannerTaps tap(s) during drag.',
        );
      },
    );

    testWidgets(
      'overshoot path (downward) keeps every pointer down outside top banner',
      (tester) async {
        // Engineer a final adjustment smaller than kDragSlopDefault so the
        // overshoot/return path runs. The overshoot starts a SECOND gesture
        // at dragBeginPosition + overshootOffset. Verify that gesture's
        // pointer down still lands below the banner.
        final pointerDowns = <Offset>[];
        int bannerTaps = 0;

        const topBannerHeight = 450.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) => pointerDowns.add(event.position),
            onTopBannerTap: () => bannerTaps++,
            topBannerHeight: topBannerHeight,
          ),
        );

        // Items 100 tall, target item 15 (content y=1500). Drag of -1060
        // overshoots the desired alignment (target.top = padding.top = 450)
        // by ~10 px, so distanceToEnd.dy is +10 (downward) → overshoot path.
        final firstItem = spotKey<Container>(const ValueKey('item-4'));
        final secondItem = spotKey<Container>(const ValueKey('item-15'));

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          moveStep: const Offset(0, -1060),
          padding: const EdgeInsets.only(top: topBannerHeight),
        );

        final obscuredRect = _topBannerRect(secondItem, topBannerHeight);
        for (final pos in pointerDowns) {
          expect(
            obscuredRect.contains(pos),
            isFalse,
            reason:
                'Pointer down at $pos lands inside top banner $obscuredRect.',
          );
        }
        expect(bannerTaps, 0);
      },
    );

    testWidgets(
      'overshoot path with smaller items keeps every pointer down outside '
      'top banner',
      (tester) async {
        // TODO remove
        timeline.mode = TimelineMode.always;
        // Smaller items shrink the visible band's hittable area, pushing
        // dragBeginPosition closer to the banner edge. With overshoot of
        // kDragSlopDefault + 1 (= 21), the SECOND gesture can land inside
        // the banner if dragBeginPosition is < 21 px below it.
        final pointerDowns = <Offset>[];
        int bannerTaps = 0;

        const topBannerHeight = 450.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) {
              pointerDowns.add(event.position);
              timeline.addEvent(
                  details: 'Tap at ${event.position.dy}',
                  eventType: 'tap down');
            },
            onTopBannerTap: () => bannerTaps++,
            topBannerHeight: topBannerHeight,
            itemHeight: 60,
          ),
        );

        // Items 60 tall, count 30. Item 7 (content y=420-480) is partially
        // visible just below the banner; item 25 (content y=1500) is the
        // target. moveStep -1040 leaves target 10 px BELOW the desired
        // alignment so the overshoot path runs upward.
        final firstItem = spotKey<Container>(const ValueKey('item-7'));
        final secondItem = spotKey<Container>(const ValueKey('item-25'));

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          moveStep: const Offset(0, -1040),
          padding: const EdgeInsets.only(top: topBannerHeight),
        );

        final obscuredRect = _topBannerRect(secondItem, topBannerHeight);
        for (final pos in pointerDowns) {
          expect(
            obscuredRect.contains(pos),
            isFalse,
            reason:
                'Pointer down at $pos lands inside top banner $obscuredRect.',
          );
        }
        expect(bannerTaps, 0);
      },
    );

    testWidgets(
      'overshoot path (upward) keeps every pointer down outside top banner',
      (tester) async {
        // Engineer an UPWARD small final adjustment: target lands just below
        // the desired position so distanceToEnd.dy is negative. The
        // overshoot/return path then offsets the SECOND gesture by
        // overshootOffset (upward), pushing its pointer-down position closer
        // to the banner. Verify that down still lands below it.
        final pointerDowns = <Offset>[];
        int bannerTaps = 0;

        const topBannerHeight = 450.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) => pointerDowns.add(event.position),
            onTopBannerTap: () => bannerTaps++,
            topBannerHeight: topBannerHeight,
          ),
        );

        // Items 100 tall, target item 15 (content y=1500). Drag of -1040
        // leaves the target ~10 px BELOW the desired alignment, so
        // distanceToEnd.dy is -10 (upward) → overshoot path going upward.
        final firstItem = spotKey<Container>(const ValueKey('item-4'));
        final secondItem = spotKey<Container>(const ValueKey('item-15'));

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          moveStep: const Offset(0, -1040),
          padding: const EdgeInsets.only(top: topBannerHeight),
        );

        final obscuredRect = _topBannerRect(secondItem, topBannerHeight);
        for (final pos in pointerDowns) {
          expect(
            obscuredRect.contains(pos),
            isFalse,
            reason:
                'Pointer down at $pos lands inside top banner $obscuredRect.',
          );
        }
        expect(bannerTaps, 0);
      },
    );

    testWidgets(
      'bottom banner: no pointer down lands on banner during drag toStart',
      (tester) async {
        // Bottom banner simulates a fixed footer. Use toStart=true so the
        // drag traverses the scrollable in the opposite direction; padding
        // .bottom matches the banner height.
        final pointerDowns = <Offset>[];
        int bannerTaps = 0;

        const bottomBannerHeight = 450.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) => pointerDowns.add(event.position),
            onBottomBannerTap: () => bannerTaps++,
            bottomBannerHeight: bottomBannerHeight,
          ),
        );

        // Initially we need the dragStart visible at the top (above the
        // bottom banner). Item 0 (content y=0..100) is fully above any
        // bottom banner < 400 px tall — its top 50 px (0..50) is above the
        // banner when it covers the bottom 450 px.
        final firstItem = spotKey<Container>(const ValueKey('item-0'));
        // Scroll to a target near the start; with toStart we drag from end
        // to start. First scroll forward to expose a target far in the list.
        final farItem = spotKey<Container>(const ValueKey('item-15'));
        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: farItem,
          padding: const EdgeInsets.only(bottom: bottomBannerHeight),
        );

        // Now drag back toStart to bring item 0 back into view, with
        // padding.bottom set so target lands above the bottom banner.
        pointerDowns.clear();
        bannerTaps = 0;
        await act.dragUntilVisible(
          dragStart: farItem,
          dragTarget: firstItem,
          toStart: true,
          padding: const EdgeInsets.only(bottom: bottomBannerHeight),
        );

        final scrollableBox =
            spot<Scrollable>().withChild(firstItem).last().snapshotRenderBox();
        final topLeft = scrollableBox.localToGlobal(Offset.zero);
        final obscuredRect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy + scrollableBox.size.height - bottomBannerHeight,
          scrollableBox.size.width,
          bottomBannerHeight,
        );
        for (final pos in pointerDowns) {
          expect(
            obscuredRect.contains(pos),
            isFalse,
            reason: 'Pointer down at $pos lands inside bottom banner '
                '$obscuredRect.',
          );
        }
        expect(bannerTaps, 0);
      },
    );

    testWidgets(
      'thin visible band between two banners triggers second-origin search',
      (tester) async {
        // Visible band of 30 px is narrower than 2 * overshoot (= 42 px), so
        // BOTH the natural and reversed second-gesture origins land inside a
        // banner. This is the case the line + grid search in
        // _findPokablePosition handles. Verify no banner registers a tap and
        // no pointer down lands inside either banner.
        final pointerDowns = <Offset>[];
        var topTaps = 0;
        var bottomTaps = 0;

        const scrollableHeight = 500.0;
        const topBannerHeight = 235.0;
        const bottomBannerHeight = 235.0;

        await tester.pumpWidget(
          DragInObscuredAreaTestWidget(
            onPointerDown: (event) => pointerDowns.add(event.position),
            onTopBannerTap: () => topTaps++,
            onBottomBannerTap: () => bottomTaps++,
            topBannerHeight: topBannerHeight,
            bottomBannerHeight: bottomBannerHeight,
            itemHeight: 24,
            itemCount: 60,
          ),
        );

        // Item 10 at content y=240 sits inside the 30 px visible band
        // [235, 265] at scroll=0. dragBeginPosition picks (centerX, +248)
        // (closest grid point to dragStart's center). Target item 35 at
        // content y=840 leaves the target 10 px below the desired alignment
        // after a -595 step, so the overshoot path runs upward. Both
        // natural origin (+227) and reversed origin (+269) fall outside the
        // visible band [235, 265) — line + grid search must pick a safe
        // position.
        final firstItem = spotKey<Container>(const ValueKey('item-10'));
        final secondItem = spotKey<Container>(const ValueKey('item-35'));

        await act.dragUntilVisible(
          dragStart: firstItem,
          dragTarget: secondItem,
          moveStep: const Offset(0, -595),
          padding: const EdgeInsets.symmetric(vertical: topBannerHeight),
        );

        final scrollableBox =
            spot<Scrollable>().withChild(secondItem).last().snapshotRenderBox();
        final topLeft = scrollableBox.localToGlobal(Offset.zero);
        final topBanner = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          scrollableBox.size.width,
          topBannerHeight,
        );
        final bottomBanner = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy + scrollableHeight - bottomBannerHeight,
          scrollableBox.size.width,
          bottomBannerHeight,
        );

        for (final pos in pointerDowns) {
          expect(
            topBanner.contains(pos),
            isFalse,
            reason: 'Pointer down at $pos lands inside top banner.',
          );
          expect(
            bottomBanner.contains(pos),
            isFalse,
            reason: 'Pointer down at $pos lands inside bottom banner.',
          );
        }
        expect(topTaps, 0);
        expect(bottomTaps, 0);
      },
    );
  });
}

Rect _topBannerRect(WidgetSelector<Widget> child, double bannerHeight) {
  final scrollableBox =
      spot<Scrollable>().withChild(child).last().snapshotRenderBox();
  final topLeft = scrollableBox.localToGlobal(Offset.zero);
  return Rect.fromLTWH(
    topLeft.dx,
    topLeft.dy,
    scrollableBox.size.width,
    bannerHeight,
  );
}
