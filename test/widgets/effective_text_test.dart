// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart';

import '../util/assert_error.dart';

void main() {
  group('maxLines', () {
    testWidgets('effective maxLines success', (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Text(''),
              DefaultTextStyle(
                style: TextStyle(),
                maxLines: 2,
                child: Text(''),
              ),
            ],
          ),
        ),
      );

      // directly passed max lines
      spot<Text>()
          .withMaxLines(null)
          .existsExactlyNTimes(2)
          .all((m) => m.hasMaxLines(null));
      spot<Text>()
          .whereMaxLines((it) => it.isNull())
          .existsExactlyNTimes(2)
          .all((m) => m.hasMaxLinesWhere((it) => it.isNull()));

      // effective max lines
      spot<Text>()
          .withEffectiveMaxLines(2)
          .existsOnce()
          .hasEffectiveMaxLines(2);
      spot<Text>()
          .withEffectiveMaxLinesMatching(
            (it) => it.isNotNull().isGreaterThan(1),
          )
          .existsOnce()
          .hasEffectiveMaxLinesWhere((it) => it.isNotNull().isGreaterThan(1));

      spot<Text>()
          .withEffectiveMaxLines(null)
          .existsOnce()
          .hasEffectiveMaxLines(null);
      spot<Text>()
          .withEffectiveMaxLinesMatching((it) => it.isNull())
          .existsOnce()
          .hasEffectiveMaxLinesWhere((it) => it.isNull());
    });

    testWidgets('error shows actual maxLines count', (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: Text(''),
        ),
      );
      expect(
        () => spot<Text>().existsOnce().hasEffectiveMaxLines(5),
        throwsSpotErrorContaining([
          'has "maxLines" that: equals <5>, actual: <null>',
        ]),
      );
    });

    testWidgets('error shows null when no maxLines is set',
        (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: TextStyle(),
            maxLines: 2,
            child: Text(''),
          ),
        ),
      );

      expect(
        () => spot<Text>().existsOnce().hasEffectiveMaxLines(5),
        throwsSpotErrorContaining([
          'has "maxLines" that: equals <5>, actual: <2>',
        ]),
      );
    });
  });

  group('textStyle', () {
    testWidgets('match default TextStyle', (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          theme: ThemeData.dark(),
          home: Material(
            child: Text(''),
          ),
        ),
      );
      spot<Text>()
          .existsOnce()
          .hasEffectiveTextStyleWhere((style) => style.fontSize.equals(14))
          .hasEffectiveTextStyleWhere(
            (style) => style.fontStyle.equals(FontStyle.normal),
          )
          .hasEffectiveTextStyleWhere(
            (style) => style.fontWeight.equals(FontWeight.normal),
          );
    });

    testWidgets('Read values from DefaultTextStyle', (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            child: Text(''),
          ),
        ),
      );
      spot<Text>().existsOnce().hasEffectiveTextStyleWhere(
            (style) => style
              ..fontSize.equals(20)
              ..letterSpacing.equals(2)
              ..fontStyle.equals(FontStyle.italic)
              ..fontWeight.equals(FontWeight.bold),
          );
    });

    testWidgets('Errors show current values', (widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: TextStyle(),
            child: Text('A'),
          ),
        ),
      );

      expect(
        () => spot<Text>()
            .existsOnce()
            .hasEffectiveTextStyleWhere((style) => style..fontSize.equals(20)),
        throwsSpotErrorContaining([
          'has "textStyle" that: has fontSize that: equals <20.0>, actual: <14.0>',
        ]),
      );

      expect(
        () => spot<Text>().existsOnce().hasEffectiveTextStyleWhere(
              (style) => style..fontStyle.equals(FontStyle.italic),
            ),
        throwsSpotErrorContaining([
          'has "textStyle" that: has fontStyle that: equals <FontStyle.italic>, actual: <FontStyle.normal>',
        ]),
      );
      expect(
        () => spot<Text>().existsOnce().hasEffectiveTextStyleWhere(
              (style) => style..fontWeight.equals(FontWeight.bold),
            ),
        throwsSpotErrorContaining([
          'has "textStyle" that: has fontWeight that: equals <FontWeight.w700>, actual: <FontWeight.w400>',
        ]),
      );
    });

    testWidgets('Match against complete TextStyle', (widgetTester) async {
      final style = TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      );
      await widgetTester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: style,
            child: Text(''),
          ),
        ),
      );
      spot<Text>().existsOnce().hasEffectiveTextStyle(style);
    });

    testWidgets(
        'Failed matching against complete TextStyle shows current values',
        (widgetTester) async {
      final style = TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      );
      await widgetTester.pumpWidget(
        MaterialApp(
          home: DefaultTextStyle(
            style: style,
            child: Text(''),
          ),
        ),
      );

      expect(
        () => spot<Text>().existsOnce().hasEffectiveTextStyle(
              style.copyWith(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
        throwsSpotErrorContaining([
          'has "textStyle" that: equals <TextStyle(inherit: true, size: 16.0, weight: 400, style: normal, letterSpacing: 1.0)>, actual: <TextStyle(inherit: true, size: 20.0, weight: 700, style: italic, letterSpacing: 2.0)>',
        ]),
      );
    });
  });
}
