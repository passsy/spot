import 'package:flutter/material.dart';

class DragUntilVisibleTestWidget extends StatelessWidget {
  const DragUntilVisibleTestWidget({super.key});

  Color getRandomColor(int index) {
    return index.isEven ? Colors.red : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (index) => Container(
        height: 100,
        color: index.isEven ? Colors.red : Colors.blue,
        child: Center(child: Text('Item at index: $index')),
      ),
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scrollable Test'),
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
