import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class DragUntilVisibleSingleDirectionTestWidget extends StatelessWidget {
  const DragUntilVisibleSingleDirectionTestWidget({
    super.key,
    required this.axis,
    this.ignorePointerAtIndices = const [0, 0],
    this.useColumnOrRow = false,
  });

  final Axis axis;
  final List<int> ignorePointerAtIndices;
  final bool useColumnOrRow;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (index) {
        return IgnorePointer(
          ignoring: ignorePointerAtIndices.contains(index),
          child: Container(
            key: ValueKey('item-$index'),
            height: 100,
            color: index.isEven ? Colors.red : Colors.blue,
            child: Center(child: Text('Item at index: $index')),
          ),
        );
      },
    );

    final child = () {
      if (useColumnOrRow) {
        return SingleChildScrollView(
          scrollDirection: axis,
          child: Flex(
            mainAxisSize: MainAxisSize.min,
            direction: axis,
            children: items,
          ),
        );
      }
      return ListView.builder(
        scrollDirection: axis,
        itemCount: items.length,
        itemBuilder: (_, index) => items[index],
      );
    }();

    final direction = axis == Axis.vertical ? 'Vertical' : 'Horizontal';
    final childType = useColumnOrRow
        ? axis == Axis.vertical
            ? 'Column'
            : 'Row'
        : 'ListView';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('$direction Scrollable ($childType)'),
        ),
        body: Center(
          child: SizedBox(
            height: 800,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 450,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NestedScrollDragUntilVisibleTestWidget extends StatelessWidget {
  const NestedScrollDragUntilVisibleTestWidget({
    super.key,
    this.axis = Axis.vertical,
  });

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    List<Widget> createChildren(int parentIndex) {
      return List.generate(
        5,
        (index) {
          return Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(),
              color: index.isEven ? Colors.blueGrey : Colors.white38,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('ParentIndex: $parentIndex, Item at index: $index'),
            ),
          );
        },
      );
    }

    final parents = List.generate(
      3,
      (index) {
        return ColoredBox(
          color: index.isEven ? Colors.blueAccent : Colors.greenAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Parent Index: $index'),
              SingleChildScrollView(
                scrollDirection: axis,
                child: Flex(
                  direction: axis,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: createChildren(index),
                ),
              ),
            ],
          ),
        );
      },
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nested Scroll in ${axis == Axis.vertical ? 'Column' : 'Row'}',
          ),
        ),
        body: SizedBox(
          height: 800,
          child: SingleChildScrollView(
            scrollDirection: axis,
            child: Flex(
              direction: axis,
              mainAxisSize: MainAxisSize.min,
              children: parents.mapIndexed((index, child) {
                return child;
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrollable list where every item registers tap callbacks. Used to verify
/// that [act.dragUntilVisible] never produces an accidental tap, even when the
/// final adjustment drag is shorter than [kDragSlopDefault].
class DragUntilVisibleTappableTestWidget extends StatelessWidget {
  const DragUntilVisibleTappableTestWidget({
    super.key,
    required this.axis,
    required this.onItemTap,
    this.itemCount = 30,
    this.mainAxisItemSize = 100,
  });

  final Axis axis;
  final void Function(int index) onItemTap;
  final int itemCount;
  final double mainAxisItemSize;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      itemCount,
      (index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onItemTap(index),
          child: Container(
            width: axis == Axis.horizontal ? mainAxisItemSize : null,
            height: axis == Axis.vertical ? mainAxisItemSize : null,
            color: index.isEven ? Colors.red : Colors.blue,
            child: Center(child: Text('Item at index: $index')),
          ),
        );
      },
    );

    final direction = axis == Axis.vertical ? 'Vertical' : 'Horizontal';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('$direction Tappable Scrollable')),
        body: Center(
          child: SizedBox(
            height: 800,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 450,
                ),
                child: ListView.builder(
                  scrollDirection: axis,
                  itemCount: items.length,
                  itemBuilder: (_, index) => items[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrollable with optional fixed banners covering the top and/or bottom
/// of the scrollable content (simulating a fixed header / footer that
/// overlaps the scrollable). Each banner registers its own `onTap` so tests
/// can assert it was never tapped during a drag. A [Listener] wraps the
/// entire tree so tests can observe every pointer-down event globally.
class DragInObscuredAreaTestWidget extends StatelessWidget {
  const DragInObscuredAreaTestWidget({
    super.key,
    required this.onPointerDown,
    this.onTopBannerTap,
    this.onBottomBannerTap,
    this.scrollableHeight = 500,
    this.topBannerHeight = 0,
    this.bottomBannerHeight = 0,
    this.itemHeight = 100,
    this.itemCount = 30,
  });

  final void Function(PointerDownEvent event) onPointerDown;

  /// Tapped when the top banner receives a recognized tap. Null = no banner.
  final VoidCallback? onTopBannerTap;

  /// Tapped when the bottom banner receives a recognized tap. Null = no banner.
  final VoidCallback? onBottomBannerTap;

  final double scrollableHeight;
  final double topBannerHeight;
  final double bottomBannerHeight;
  final double itemHeight;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(itemCount, (index) {
      return Container(
        key: ValueKey('item-$index'),
        height: itemHeight,
        color: index.isEven ? Colors.red : Colors.blue,
        child: Center(child: Text('Item at index: $index')),
      );
    });

    Widget banner({required VoidCallback? onTap, required String label}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ColoredBox(
          color: const Color(0xCC008800),
          child: Center(child: Text(label)),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onPointerDown,
          child: Center(
            child: SizedBox(
              width: 500,
              height: scrollableHeight,
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) => items[index],
                  ),
                  if (topBannerHeight > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topBannerHeight,
                      child: banner(
                        onTap: onTopBannerTap,
                        label: 'TOP BANNER',
                      ),
                    ),
                  if (bottomBannerHeight > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: bottomBannerHeight,
                      child: banner(
                        onTap: onBottomBannerTap,
                        label: 'BOTTOM BANNER',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrollable nested in another scrollable on the perpendicular axis. Used
/// to verify that [act.dragUntilVisible] never accidentally scrolls the outer
/// scrollable on the cross axis.
class CrossAxisNestedScrollableTestWidget extends StatefulWidget {
  const CrossAxisNestedScrollableTestWidget({
    super.key,
    required this.innerAxis,
  });

  /// The axis of the inner scrollable. The outer one is the perpendicular axis.
  final Axis innerAxis;

  @override
  State<CrossAxisNestedScrollableTestWidget> createState() =>
      CrossAxisNestedScrollableTestWidgetState();
}

class CrossAxisNestedScrollableTestWidgetState
    extends State<CrossAxisNestedScrollableTestWidget> {
  /// Controller for the OUTER scrollable; used by tests to assert it didn't
  /// scroll on the cross axis.
  final ScrollController outerController = ScrollController();

  @override
  void dispose() {
    outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerAxis =
        widget.innerAxis == Axis.vertical ? Axis.horizontal : Axis.vertical;

    final innerItems = List.generate(
      30,
      (index) => Container(
        width: widget.innerAxis == Axis.horizontal ? 100 : 200,
        height: widget.innerAxis == Axis.vertical ? 100 : 200,
        color: index.isEven ? Colors.red : Colors.blue,
        child: Center(child: Text('Item at index: $index')),
      ),
    );

    final innerScrollable = SizedBox(
      width: widget.innerAxis == Axis.horizontal ? 400 : 200,
      height: widget.innerAxis == Axis.vertical ? 400 : 200,
      child: ListView.builder(
        scrollDirection: widget.innerAxis,
        itemCount: innerItems.length,
        itemBuilder: (_, index) => innerItems[index],
      ),
    );

    // Outer is overflowed on its scroll axis (via a spacer after the inner
    // scrollable) to give it room to scroll, while keeping the inner
    // scrollable at offset 0 so its first items are fully on-screen at
    // startup. We use Row/Column so the inner SizedBox isn't forced to stretch
    // by tight parent constraints.
    final Widget outerChild = outerAxis == Axis.horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              innerScrollable,
              const SizedBox(width: 1300),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              innerScrollable,
              const SizedBox(height: 1100),
            ],
          );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Cross-axis nested')),
        body: SingleChildScrollView(
          controller: outerController,
          scrollDirection: outerAxis,
          child: outerChild,
        ),
      ),
    );
  }
}
