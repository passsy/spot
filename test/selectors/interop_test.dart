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
          .hasDiagnosticProp<String>('data', (it) => it.equals('a'));
    });

    testWidgets('readable error messages when ancestor could not be found',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text('foo'),
        ),
      );

      expect(
        () => find
            .ancestor(
              of: find.byType(Directionality),
              matching: find.text('nope'),
            )
            .spot()
            .existsOnce(),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            anyOf(
              // Flutter 3.10, Flutter 3.13,
              contains(
                'Could not find text "nope" which is an ancestor of type "Directionality" in widget tree, expected exactly 1',
              ),
              // Flutter 3.15, Flutter 3.16
              contains(
                'Could not find widgets with text "nope" that are ancestors of widgets with type "Directionality" in widget tree, expected exactly 1',
              ),
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

      final text = spot<MaterialApp>().spot<Text>()..existsOnce().hasText('a');
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

    testWidgets('spotFinder has readable error messages', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text('foo'),
        ),
      );

      expect(
        () => spot<Directionality>().spotFinder(find.text('nope')).existsOnce(),
        throwsA(
          isA<TestFailure>().having(
            (e) => e.message,
            'message',
            contains(
              'Could not find Directionality > text "nope" in widget tree',
            ),
          ),
        ),
      );
    });
  });
}
