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
    spotSingle<Padding>()
        .spotSingle<SizedBox>()
        .spotSingleText('Hello')
        .existsOnce();
    spotSingle<Padding>()
        .spotSingle<SizedBox>()
        .spotSingleText('Hello')
        .existsAtLeastOnce();
    spotSingle<GestureDetector>().spotSingleText('World').doesNotExist();
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
    spotSingle<Text>(
      parents: [spotSingle<Wrap>(), spotSingle<GestureDetector>()],
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
    spotSingleText(
      'Hello',
      parents: [
        spotSingle<GestureDetector>(),
        spotSingle<_UnknownWidget>(),
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

    spotSingle<GestureDetector>(children: [spotSingleText('a')]).existsOnce();
  });
}

class _UnknownWidget extends StatelessWidget {
  const _UnknownWidget();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
