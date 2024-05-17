// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';

import '../util/assert_error.dart';

void main() {
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
    await takeScreenshot();
    spot<Center>(
      parents: [spot<MaterialApp>()],
      children: [spot<Padding>()],
    ).existsOnce();
    spot<Padding>().existsOnce();
    spot<Wrap>().existsOnce();
    spot<Wrap>().spot<Text>().existsAtLeastOnce();
    spot<Wrap>().spot<Text>().existsAtLeastOnce();
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
      throwsSpotErrorContaining(
        [
          'Found 2 elements',
          'expected exactly 1',
          '\nWrap(', // at the beginning of the line, common ancestor
          'Text("World"',
          'Text("Hello"',
        ],
        not: ['root'],
      ),
    );
    expect(
      () => spot<Text>().amount(1).existsOnce(),
      throwsSpotErrorContaining(
        [
          'Found 2 elements',
          'expected exactly 1',
          '\nWrap(', // at the beginning of the line, common ancestor
          'Text("World"',
          'Text("Hello"',
        ],
        not: ['root'],
      ),
    );
    expect(
      () => spot<Text>(parents: [spot<Wrap>()]).amount(1).existsOnce(),
      throwsSpotErrorContaining(
        [
          'Found 2 elements',
          "Wrap ᗕ Text",
          'expected exactly 1',
          '\nWrap(', // at the beginning of the line, common ancestor
          'Text("World"',
          'Text("Hello"',
        ],
        not: ['root'],
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
    spot<Wrap>().withDirection(Axis.horizontal).withDiagnosticProp<Axis>(
      'direction',
      (Subject<Axis> it) {
        it.equals(Axis.horizontal);
      },
    ).existsAtLeastOnce();

    spot<Wrap>().withDirection(Axis.horizontal).existsAtLeastOnce();

    // Error message can show the actual value of the direction
    spot<Wrap>()
        .existsAtLeastOnce()
        .any((wrap) => wrap.hasDirection(Axis.horizontal));
    spot<Wrap>().existsOnce().hasDirection(Axis.horizontal);

    final WidgetSelector<Text> selector =
        spot<Wrap>().spot<Text>().withMaxLines(2);
    selector.existsOnce().hasText('Hello');

    spot<Wrap>()
        .spot<Text>(parents: [spot<GestureDetector>()])
        .existsOnce()
        .hasText('Hello');

    final textSpot =
        spot<Wrap>().spot<Text>(parents: [spot<GestureDetector>()]);
    textSpot.existsOnce().hasText('Hello');

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
    expect(textSnapshot.discoveredElements.length, 2);

    final wrap = spot<Wrap>();
    // only find the single sizedBox below Wrap
    wrap.spot<SizedBox>().existsOnce();

    final multipleSpotter = spot<Text>();
    expect(snapshot(multipleSpotter).discovered.length, 2);

    snapshot(spot<Text>()).existsAtLeastOnce();

    // only finds the single SizedBox in Wrap, not the SizedBox below Center
    multipleSpotter.withParent(wrap.spot<SizedBox>()).existsOnce();
  });
}
