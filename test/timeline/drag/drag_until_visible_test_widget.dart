import 'package:flutter/material.dart';

class DragUntilVisibleSingleDirectionTestWidget extends StatelessWidget {
  const DragUntilVisibleSingleDirectionTestWidget({
    super.key,
    required this.axis,
    this.ignorePointerAtIndices = const [0, 0],
  });

  Color getRandomColor(int index) {
    return index.isEven ? Colors.red : Colors.blue;
  }

  final Axis axis;
  final List<int> ignorePointerAtIndices;

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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scrollable Test with axis: $axis'),
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
                child: ListView.builder(
                  scrollDirection: axis,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return items[index];
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DragUntilVisibleMultiDirectionTestWidget extends StatelessWidget {
  const DragUntilVisibleMultiDirectionTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Grid View Drag Test'),
        ),
        body: Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 4, // Total 4 items
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  width: 100,
                  color: index.isEven ? Colors.red : Colors.blue,
                  child: Center(
                    child: Text(
                      'Item at index: ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
