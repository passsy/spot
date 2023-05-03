// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
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
    spot<Text>().withEffectiveMaxLines(2).existsOnce().hasEffectiveMaxLines(2);
    spot<Text>()
        .withEffectiveMaxLinesMatching((it) => it.isNotNull().isGreaterThan(1))
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
        'with prop "maxLines" that: equals <5>, actual: <null>',
      ]),
    );
  });

  testWidgets('error shows null when no maxLines is set', (widgetTester) async {
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
        'with prop "maxLines" that: equals <5>, actual: <2>',
      ]),
    );
  });
}
