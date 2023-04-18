// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existsOnce() plain', (tester) async {
    await tester.pumpWidget(SizedBox());
    spot<SizedBox>().snapshot().existsOnce();
    expect(
      () => spot<Material>().existsOnce(),
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
      final sizedBox = spot<SizedBox>(
        parents: [spot<Center>()],
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
        () => spot<SizedBox>(
          parents: [spot<Material>()],
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
        () => spot<Material>(
          parents: [spot<SizedBox>()],
        ).existsOnce(),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
              "Could not find 'Material with parents: ['SizedBox']' in widget tree",
            ),
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
        () => spot<Center>(
          children: [spot<SizedBox>()],
          parents: [spot<Material>()], // <-- does not exist
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
      final sizedBox = spot<SizedBox>(
        children: [spot<Center>()],
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
        () => spot<SizedBox>(
          children: [spot<Material>()],
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

    spot<MaterialApp>().spot<Center>().existsOnce();
    spot<Center>(
      parents: [spot<MaterialApp>()],
      children: [spot<Padding>()],
    ).existsOnce();
    spot<Padding>().existsOnce();
    spot<Wrap>().existsOnce();
    // spot<Wrap>().spot<Text>().existsAtLeastOnce();
    spot<Wrap>().spotAll<Text>().existsAtLeastOnce();
    // spot<Wrap>().spot<Text>().locateAtLeastOnce();
    spot<Wrap>().spotAll<Text>().locateAtLeastOnce();
    spot<GestureDetector>().existsOnce();
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
      () => spot<Text>().existsOnce(),
      throwsA(
        isA<TestFailure>()
            .having((e) => e.message, 'message', contains('Found 2 elements'))
            .having((e) => e.message, 'candidate1', contains('Text("World"'))
            .having((e) => e.message, 'candidate2', contains('Text("Hello"')),
      ),
    );
    expect(
      () => spot<Text>(parents: [spot<Wrap>()]).existsOnce(),
      throwsA(
        isA<TestFailure>()
            .having((e) => e.message, 'parents', contains("parents: ['Wrap']"))
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
            title: Text('App Title', maxLines: 2),
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
    final appBar = spot<AppBar>();
    appBar.spot<Text>().existsOnce().hasText('App Title').hasMaxLines(2);

    // Error message only show that it could not be found
    spot<Wrap>().withProp2<Axis>(
      'direction',
      (Subject<Axis> it) {
        it.equals(Axis.horizontal);
      },
    )
        // .withDirection(Axis.horizontal)
        .locateMulti();

    spot<Wrap>().withDirection(Axis.horizontal).existsAtLeastOnce();

    // Error message can show the actual value of the direction
    spotAll<Wrap>()
        .locateMulti()
        .any((wrap) => wrap.hasDirection(Axis.horizontal));
    spot<Wrap>().locate().hasDirection(Axis.horizontal);

    final WidgetSelector<Text> selector =
        spot<Wrap>().spot<Text>().withMaxLines(2);
    selector.existsOnce().hasText('Hello');

    spot<Wrap>()
        .spot<Text>(parents: [spot<GestureDetector>()])
        .locate()
        .hasText('Hello');

    final textSpot =
        spot<Wrap>().spot<Text>(parents: [spot<GestureDetector>()]);
    textSpot.locate().hasText('Hello');

    spot<Text>(parents: [spot<Wrap>()])
        .withMaxLines(2)
        .existsOnce()
        .hasText('Hello');
    selector.existsOnce().hasText('Hello');

    spot<Wrap>().spot<Text>().withMaxLines(1).existsOnce().hasText('World');
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

    final textSnapshot = spot<Text>().snapshot();
    expect(textSnapshot.matchingElements.length, 2);

    final wrap = spot<Wrap>()..snapshot().existsOnce();
    // only find the single sizedBox below Wrap
    wrap.spot<SizedBox>().existsOnce();

    final multipleSpotter = spot<Text>();
    expect(snapshot(multipleSpotter).discovered.length, 2);

    snapshot(spot<Text>()).existsAtLeastOnce();

    multipleSpotter.copyWith(
      parents: [
        // only finds the single SizedBox in Wrap, not the SizedBox below Center
        wrap.spot<SizedBox>(),
      ],
    );
  });
}
