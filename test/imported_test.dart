import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('narrow down search down the tree', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('Hello', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    spot.byType(Padding).childByType(SizedBox).text('Hello').existsOnce();
    spot
        .byType(Padding)
        .childByType(SizedBox)
        .text('Hello')
        .existsAtLeastOnce();
    spot.byType(GestureDetector).text('World').doesNotExist();
  });

  testWidgets('narrow results by checking parents', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('Hello', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    spot.text(
      'Hello',
      parents: [spot.byType(Wrap), spot.byType(GestureDetector)],
    ).existsOnce();

    spot.text(
      'Hello',
      parents: [
        spot.byType(SizedBox).childByType(GestureDetector),
        spot.byType(Center)
      ],
    ).existsOnce();

    spot.text(
      'Hello',
      parents: [
        spot.byType(GestureDetector),
        spot.byType(_UnknownWidget),
      ],
    ).doesNotExist();

    spot.byType(SizedBox).text(
      'Hello',
      parents: [spot.byType(Center).childByType(Wrap)],
    ).existsOnce();

    spot
        .byType(SizedBox, parents: [spot.byType(Center).childByType(Wrap)])
        .text('Hello')
        .existsOnce();

    // TODO what if we want multiple results to be returned?
  });

  testWidgets('narrow results by checking children', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [
            SizedBox(
              child: GestureDetector(
                child: const Text('a', maxLines: 2),
              ),
            ),
            GestureDetector(
              child: const Text('b', maxLines: 1),
            ),
            GestureDetector(
              child: const Text('c', maxLines: 1),
            ),
          ],
        ),
      ),
    );

    spot.byType(GestureDetector, children: [spot.text('a')]).existsOnce();

    // TODO what if we want multiple results to be returned?
  });
}

class _UnknownWidget extends StatelessWidget {
  const _UnknownWidget();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
