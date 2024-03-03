// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

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

  testWidgets('select offstage widgets when use .overrideIncludeOffstage(true)',
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
    spotOffstage().spotText('c').existsOnce();
    spotOffstage().overrideIncludeOffstage(false).spotText('c').doesNotExist();

    spotText('c').doesNotExist();
    spotText('c').overrideIncludeOffstage(true).existsOnce();
    spotOffstage().spotText('c').existsOnce();
    spotText('c')
        .overrideIncludeOffstage(true)
        .overrideIncludeOffstage(false)
        .doesNotExist();
    spotText('c')
        .overrideIncludeOffstage(true)
        .overrideIncludeOffstage(false)
        .overrideIncludeOffstage(true)
        .existsOnce();

    spot<Text>().withText('c').doesNotExist();
    spot<Text>().withText('c').overrideIncludeOffstage(true).existsOnce();
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
}
