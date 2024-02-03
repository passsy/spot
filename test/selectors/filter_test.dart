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
}
