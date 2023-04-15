// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existsOnce() plain', (tester) async {
    await tester.pumpWidget(SizedBox());
    spot.byType<SizedBox>().snapshot().existsOnce();
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
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
                "Could not find 'Material with parents: ['SizedBox']' in widget tree"),
          ),
        ),
      );
    });

    testWidgets('error shows alternative item', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );

      expect(
        () => spot.byType<Center>(
          children: [spot.byType<SizedBox>()],
          parents: [spot.byType<Material>()], // <-- does not exist
        ).existsOnce(),
        throwsA(
          isA<TestFailure>()
              .having(
                (e) => e.message,
                'message',
                contains("but found 1 matches when searching for "
                    "'Center"),
              )
              .having(
                (e) => e.message,
                'alternative',
                contains(
                  "Possible match #1: Center(alignment: Alignment.center)",
                ),
              ),
        ),
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
        home: Scaffold(
          appBar: AppBar(
            title: Text('Hello World'),
          ),
          body: Center(
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

    // TODO return selector with single result
    final textWrappedWithGestureDetector = spot.byType<Text>(
      propsFn: (text) {
        text.hasText('Hello');
        text.hasMaxLines(null);
      },
      propsList: [
        // hasColor(Colors.green),
        hasText('Hello'),
      ],
    );

    // TODO make this playground a real test again
    // Create a Text selector with querying the text value

    // v1
    spot.byType<Text>(propsList: [hasText('Hello')]).existsAtLeastOnce();
    // v2
    spot
        .byType<Text>(propsFn: (text) => text.hasText('Hello'))
        .existsAtLeastOnce();
    // v3
    // spot.byType<Text>().hasText('Hello').existsOnce();

    // final WidgetSelector<Text> t = spot.byType<Text>();
    // final WidgetSelector<Text> c = t.copyWith();
    // final WidgetSelector<Text> w = t.whereWidget((widget) => false, description: 'never');
    spot
        .byType<AppBar>()
        .byType<Text>()
        .containsText('Hello World')
        .existsOnce()
        .hasTextSize(20);

    // spot.byType<Text>().containsText('Counter').existsOnce().endsWith('World');

    // spot.byType<Text>().all((widget) => widget.hasText('Hello'));
    spot.byType<Text>().any((widget) => widget.hasText('Hello'));

    // expect(find.byType(Text), findsNWidgets(2));
    textWrappedWithGestureDetector
        .existsAtLeastOnce()
        .hasText('Hello')
        .hasMaxLines(null);

    final snapshot = textWrappedWithGestureDetector.snapshot();

    // final textWrappedWithGestureDetector2 = spot.byType<Text>();
    // textWrappedWithGestureDetector2.snapshot().existsOnce();

    // expect(snapshot.matchingElements.length, 1);

    // final WidgetSelector<Text> t2 = t1.hasText('Hello');
    // final WidgetSelector<Text> t3 = t2.existsOnce();

    // .existsOnce()
    // .matchProps([textWidget.hasText('Hello')]);

    // spot
    //     .byType<Text>()
    //     .whereWidget((widget) => widget.data == 'Hello')
    //     .existsOnce();

    // expect(t3.element, isNotNull);
    // expect(t3.elements.length, 1);
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

    final textSnapshot = spot.byType<Text>().snapshot();
    expect(textSnapshot.matchingElements.length, 2);

    final wrap = spot.byType<Wrap>()..snapshot().existsOnce();
    // only find the single sizedBox below Wrap
    wrap.byType<SizedBox>().existsOnce();

    final multipleSpotter = spot.byType<Text>();
    expect(snapshot(multipleSpotter).discovered.length, 2);

    snapshot(spot.byType<Text>()).existsAtLeastOnce();

    multipleSpotter.copyWith(
      parents: [
        // only finds the single SizedBox in Wrap, not the SizedBox below Center
        wrap.byType<SizedBox>(),
      ],
    );
  });
}
