import 'package:flutter/material.dart';

class DragUntilVisibleTestWidget extends StatelessWidget {
  const DragUntilVisibleTestWidget({super.key});

  Color getRandomColor(int index) {
    // ignore: deprecated_member_use
    return Colors.black.withOpacity(1 / (index + 1));
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (index) => Container(
        decoration: BoxDecoration(
          border: Border.all(),
          color: getRandomColor(index),
        ),
        height: 100,
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
