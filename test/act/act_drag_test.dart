import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  group('Drag Events', () {
    testWidgets('Finds widget after dragging', (tester) async {
      await tester.pumpWidget(
        const _ScrollableTestWidget(),
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
        const _ScrollableTestWidget(),
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

class _ScrollableTestWidget extends StatelessWidget {
  const _ScrollableTestWidget();

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
