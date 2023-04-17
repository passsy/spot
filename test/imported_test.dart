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
    spot<Padding>().spot<SizedBox>().text('Hello').existsOnce();
    spot<Padding>().spot<SizedBox>().text('Hello').existsAtLeastOnce();
    spot.spot<GestureDetector>().text('World').doesNotExist();
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
    spot.spot<Text>(
      parents: [spot.spot<Wrap>(), spot.spot<GestureDetector>()],
    ).existsOnce();

    // spot.text(
    //   'Hello',
    //   parents: [spot.spotDescendant<Wrap>(), spot.spotDescendant<GestureDetector>()],
    // ).existsOnce();
    //
    // spot.text(
    //   'Hello',
    //   parents: [
    //     spot.spotDescendant<SizedBox>().childspotDescendant(GestureDetector),
    //     spot.spotDescendant<Center>()
    //   ],
    // ).existsOnce();
    //
    spot.text(
      'Hello',
      parents: [
        spot<GestureDetector>(),
        spot<_UnknownWidget>(),
      ],
    );
    //
    // spot.spotDescendant<SizedBox>().text(
    //   'Hello',
    //   parents: [spot.spotDescendant<Center>().childspotDescendant(Wrap)],
    // ).existsOnce();
    //
    // spot
    //     .spotDescendant<SizedBox>(parents: [spot.spotDescendant<Center>().childspotDescendant(Wrap)])
    //     .text('Hello')
    //     .existsOnce();

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

    spot<GestureDetector>(children: [spot.text('a')]).existsOnce();
  });
}

class _UnknownWidget extends StatelessWidget {
  const _UnknownWidget();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
