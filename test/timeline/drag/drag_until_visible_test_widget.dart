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
