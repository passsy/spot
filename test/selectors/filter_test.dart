// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/widget_selector.dart';

void main() {
  group('first', () {
    testWidgets('first sibling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Text('c'),
            ],
          ),
        ),
      );
      spot<Text>().first().existsOnce().hasText('a');
    });

    testWidgets('first child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Row(
              children: [
                Text('a'),
                Text('b'),
                Center(child: Text('c')),
              ],
            ),
          ),
        ),
      );
      // TODO find better way assert children
      final topMostCenter = spot<Center>().first();
      topMostCenter.spot<Row>().existsOnce();
    });

    testWidgets('first().copyWith() returns a single item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Text('c'),
            ],
          ),
        ),
      );
      final first = spot<Text>().first();
      first.existsOnce().hasText('a');
      final copy = first.copyWith();
      copy.existsOnce().hasText('a');
    });
  });

  group('last', () {
    testWidgets('last sibling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Text('c'),
            ],
          ),
        ),
      );
      spot<Text>().last().existsOnce().hasText('c');
    });

    testWidgets('last child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Row(
              children: [
                Text('a'),
                Text('b'),
                Center(child: Text('c')),
              ],
            ),
          ),
        ),
      );
      final bottomCenter = spot<Center>().last();
      bottomCenter.spot<Text>().existsOnce().hasText('c');
    });
  });

  testWidgets('atIndex', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Text('a'),
            Text('b'),
            Text('c'),
          ],
        ),
      ),
    );

    spot<Text>().atIndex(1).withText('b').existsOnce();
    spot<Text>().atIndex(1).existsOnce().hasText('b');
  });

  testWidgets('atIndex does not throw any RangeError', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Text('a'),
            Text('b'),
            Text('c'),
          ],
        ),
      ),
    );

    // just report nothing found
    spot<Text>().atIndex(4).doesNotExist();
  });

  group('offstage', () {
    testWidgets('do not select offstage widgets by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Offstage(child: Text('c')),
            ],
          ),
        ),
      );

      spot<Text>().atMost(2);
      spotText('c').doesNotExist();
    });

    testWidgets('do not select onstage widgets when spot offstage',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Offstage(child: Text('c')),
            ],
          ),
        ),
      );

      spot<Text>().atMost(2);
      spotText('a').existsExactlyNTimes(1);
      spotText('c').doesNotExist();

      spotOffstage().spot<Text>().atMost(1);
      spotOffstage().spotText('a').doesNotExist();
      spotOffstage().spotText('c').existsOnce();
    });

    testWidgets(
        'select offstage widgets when use .overrideVisibilityMode(VisibilityMode.offstage)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Offstage(child: Text('c')),
            ],
          ),
        ),
      );

      spotOffstage().spot<Text>().atMost(3);
      spotOffstage().spotText('a').doesNotExist();
      spotOffstage().spotText('c').existsOnce();
      spotOffstage()
          .overrideVisibilityMode(VisibilityMode.onstage)
          .spotText('a')
          .existsOnce();
      spotOffstage()
          .overrideVisibilityMode(VisibilityMode.onstage)
          .spotText('c')
          .doesNotExist();

      spotText('a').existsOnce();
      spotText('c').doesNotExist();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .doesNotExist();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .existsOnce();

      spotOffstage().spotText('a').doesNotExist();
      spotOffstage().spotText('c').existsOnce();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.onstage)
          .existsOnce();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.onstage)
          .doesNotExist();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.onstage)
          .overrideVisibilityMode(VisibilityMode.offstage)
          .doesNotExist();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.onstage)
          .overrideVisibilityMode(VisibilityMode.offstage)
          .existsOnce();

      spot<Text>().withText('a').existsOnce();
      spot<Text>().withText('c').doesNotExist();
      spot<Text>()
          .withText('a')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .doesNotExist();
      spot<Text>()
          .withText('c')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .existsOnce();
    });

    testWidgets(
        'select offstage widgets when use .overrideVisibilityMode(VisibilityMode.combined)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Text('a'),
              Text('b'),
              Offstage(child: Text('c')),
            ],
          ),
        ),
      );

      spotAllWidgets().spot<Text>().atMost(3);
      spotAllWidgets().spotText('a').existsOnce();
      spotAllWidgets().spotText('c').existsOnce();
      spotAllWidgets()
          .overrideVisibilityMode(VisibilityMode.onstage)
          .spotText('a')
          .existsOnce();
      spotAllWidgets()
          .overrideVisibilityMode(VisibilityMode.onstage)
          .spotText('c')
          .doesNotExist();

      spotText('a').existsOnce();
      spotText('c').doesNotExist();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();

      spotAllWidgets().spotText('a').existsOnce();
      spotAllWidgets().spotText('c').existsOnce();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.offstage)
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
      spotText('a')
          .overrideVisibilityMode(VisibilityMode.onstage)
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
      spotText('c')
          .overrideVisibilityMode(VisibilityMode.onstage)
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();

      spot<Text>().withText('a').existsOnce();
      spot<Text>().withText('c').doesNotExist();
      spot<Text>()
          .withText('a')
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
      spot<Text>()
          .withText('c')
          .overrideVisibilityMode(VisibilityMode.combined)
          .existsOnce();
    });

    testWidgets('filter offstage in subtree of parent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Expanded(
                child: Offstage(
                  child: Scaffold(
                    body: Column(
                      children: [
                        Text('a'),
                        Text('b'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(
                  body: Column(
                    children: [
                      Text('a'),
                      Offstage(child: Text('b')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      spotText('a').existsExactlyNTimes(1);
      spotText('b').existsExactlyNTimes(0);

      spotOffstage().spotText('a').existsExactlyNTimes(1);
      spotOffstage().spotText('b').existsExactlyNTimes(2);

      // ignores offstage Scaffold
      spot<Scaffold>().spotText('a').existsExactlyNTimes(1);

      // only search the offstage scaffold
      spotOffstage().spotText('b').existsExactlyNTimes(2);

      spotOffstage().spot<Scaffold>().existsExactlyNTimes(1);
      spotOffstage().spotText('b').existsExactlyNTimes(2);
      spotOffstage().spot<Scaffold>().spotText('a').existsExactlyNTimes(1);

      // only search for widgets within the onstage Scaffold
      spot<Scaffold>().spotText('a').existsExactlyNTimes(1);

      // find offstage widgets within the onstage Scaffold only!
      spot<Scaffold>().spotOffstage().spotText('a').existsExactlyNTimes(0);
      spot<Scaffold>().spotOffstage().spotText('b').existsExactlyNTimes(1);
    });

    testWidgets('filter offstage in subtree of child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Expanded(
                child: Scaffold(
                  body: Column(
                    children: [
                      Text('a'),
                      Text('b'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(
                  body: Column(
                    children: [
                      Text('a'),
                      Offstage(child: Text('b')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      spot<Expanded>().existsExactlyNTimes(2);

      spot<Expanded>().withChild(spotText('a')).existsExactlyNTimes(2);
      spot<Expanded>().withChild(spotText('b')).existsOnce();

      // find onstage Expanded, with offstage Text b
      spot<Expanded>().withChild(spotOffstage().spotText('b')).existsOnce();
      spot<Expanded>().withChild(spotOffstage().spotText('a')).doesNotExist();
    });

    testWidgets('fullscreenDialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(
              onPressed: () {
                final navigator =
                    Navigator.of(tester.element(find.byType(ElevatedButton)));
                navigator.push(
                  MaterialPageRoute(
                    // fullscreenDialog: true,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('dialog content'),
                      );
                    },
                  ),
                );
              },
              child: Text('open dialog'),
            ),
          ),
        ),
      );

      spotText('open dialog').existsOnce();
      spotText('dialog content').doesNotExist();
      spotOffstage().spotText('dialog content').doesNotExist();

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      spot<AlertDialog>().existsOnce();
      spotText('dialog content').existsOnce();

      spotText('open dialog').doesNotExist();
      spotOffstage().spotText('open dialog').existsOnce();
    });
  });
}
