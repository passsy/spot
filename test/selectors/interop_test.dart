// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  group('finder to spot', () {
    testWidgets('spot with concrete type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a'),
        ),
      );

      find.byType(Text).spot<Text>().existsOnce().hasText('a');
    });

    testWidgets('spot with any type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a'),
        ),
      );

      find
          .byType(Text)
          .spot() // not using <Type>
          .existsOnce()
          .hasProp<String>('data', (it) => it.equals('a'));
    });

    testWidgets('readable error message', (tester) async {
      await tester.pumpWidget(Placeholder());

      expect(
        () => find
            .ancestor(of: find.byType(MaterialApp), matching: find.text('nope'))
            .spot()
            .existsOnce(),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
              'Could not find widget with text "nope" '
              'which is an ancestor of type "MaterialApp" in widget tree',
            ),
          ),
        ),
      );
    });
  });

  group('spot to finder', () {
    testWidgets('multi layer spot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a'),
        ),
      );

      final text = spot<MaterialApp>().spotSingle<Text>()
        ..existsOnce().hasText('a');
      expect(text.finder, findsOneWidget);
    });
  });

  group('.spotFinder()', () {
    testWidgets('with any type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a'),
        ),
      );

      spot<MaterialApp>().spotFinder(find.text('a')).existsOnce();
    });

    testWidgets('with generic type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a'),
        ),
      );

      spot<MaterialApp>()
          .spotFinder<Text>(find.text('a'))
          .existsOnce()
          .hasText('a');
    });
  });
}
