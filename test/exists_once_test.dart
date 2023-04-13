// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existsOnce() plain', (tester) async {
    await tester.pumpWidget(SizedBox());
    spot.byType<SizedBox>().existsOnce();
    expect(
      () => spot.byType<Material>().existsOnce(),
      throwsA(isA<TestFailure>()),
    );
  });

  group('existsOnce() match parent', () {
    testWidgets('detects only one where parent matches', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );
      final sizedBox = spot.byType<SizedBox>(
        parents: [spot.byType<Center>()],
      );
      final snapshot = sizedBox.snapshot();
      expect(snapshot.matches.length, 1);
      expect(snapshot.discovered.length, 1);

      sizedBox.existsOnce();
    });

    testWidgets('error when parent does not exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );
      expect(
        () => spot.byType<SizedBox>(
          parents: [spot.byType<Material>()],
        ).existsOnce(),
        throwsA(isA<TestFailure>()),
      );
    });

    testWidgets('error when item does not exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );
      expect(
        () => spot.byType<Material>(
          parents: [spot.byType<SizedBox>()],
        ).existsOnce(),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('existsOnce() match child', () {
    testWidgets('detects only one where child matches', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            SizedBox(child: Center()),
            SizedBox(),
          ],
        ),
      );
      final sizedBox = spot.byType<SizedBox>(
        children: [spot.byType<Center>()],
      );
      final snapshot = sizedBox.snapshot();
      expect(snapshot.matchingElements.length, 1);

      sizedBox.existsOnce();
    });

    testWidgets('error when child does not exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            SizedBox(child: Center()),
            SizedBox(),
          ],
        ),
      );
      expect(
        () => spot.byType<SizedBox>(
          children: [spot.byType<Material>()],
        ).existsOnce(),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  testWidgets('existsOnce() finds widgets that only exist once in tree',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: Text('Hello', maxLines: 2),
                  ),
                ),
                Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(MaterialApp),
        matching: find.byType(Center),
      ),
      findsOneWidget,
    );

    expect(
      find.ancestor(
        of: find.byType(Center),
        matching: find.byType(MaterialApp),
      ),
      findsOneWidget,
    );

    spot.byType<MaterialApp>().childByType(Center).existsOnce();
    spot.byType<Center>(
      parents: [spot.byType<MaterialApp>()],
      children: [spot.byType<Padding>()],
    ).existsOnce();
    spot.byType<Padding>().existsOnce();
    spot.byType<Wrap>().existsOnce();
    spot.byType<Wrap>().childByType(Text).existsAtLeastOnce();
    spot.byType<GestureDetector>().existsOnce();
  });

  testWidgets('existsOnce() fails when multiple widgets exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: Text('Hello', maxLines: 2),
                  ),
                ),
                Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      () => spot.byType<Text>().existsOnce(),
      throwsA(
        isA<TestFailure>()
            .having((e) => e.message, 'message', contains('Found 2 elements'))
            .having((e) => e.message, 'candidate1', contains('Text("World"'))
            .having((e) => e.message, 'candidate2', contains('Text("Hello"')),
      ),
    );
  });
  testWidgets('existsOnce() finds the correct widget differentiating by props',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: Text('Hello', maxLines: 2),
                  ),
                ),
                Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );

    // TODO return selector with single result
    final WidgetSelector<Text> t1 = spot.byType<Text>(
      parents: [],
      children: [],
      props: [
        withText('Hello'),
        (w) => w.hasText('Hello'),
        (w) => w.containsText('Hello').hasText('Hello'),
      ],
    );
    final WidgetSelector<Text> t2 = t1.hasText('Hello');
    final WidgetSelector<Text> t3 = t2.existsOnce();

    // .existsOnce()
    // .matchProps([textWidget.hasText('Hello')]);

    // spot
    //     .byType<Text>()
    //     .whereWidget((widget) => widget.data == 'Hello')
    //     .existsOnce();

    expect(t3.element, isNotNull);
    expect(t3.elements.length, 1);
  });

  testWidgets('narrow down scope', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Wrap(
                children: [
                  SizedBox(
                    child: GestureDetector(
                      child: Text('Hello', maxLines: 2),
                    ),
                  ),
                  Text('World', maxLines: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final snapshot = spot.byType<Text>().snapshot();
    expect(snapshot.matchingElements.length, 2);

    final wrap = spot.byType<Wrap>().existsOnce();
    // only find the single sizedBox below Wrap
    wrap.byType<SizedBox>().existsOnce();

    final multipleSpotter = spot.byType<Text>().existsAtLeastOnce();
    expect(multipleSpotter.elements.length, 2);

    multipleSpotter.constrain(
      parents: [
        // only finds the single SizedBox in Wrap, not the SizedBox below Center
        wrap.byType<SizedBox>(),
      ],
    );
  });
}
