// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('direction', () {
    testWidgets('filter', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(home: Wrap()));

      final verticalWrapSpot = spot<Wrap>().withDirection(Axis.vertical);
      verticalWrapSpot.doesNotExist();

      final horizontalWrapSpot = spot<Wrap>().withDirection(Axis.horizontal);
      horizontalWrapSpot.existsOnce();
    });

    testWidgets('filter with subject', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(home: Wrap()));

      final verticalWrapSpot =
          spot<Wrap>().whereDirection((it) => it.equals(Axis.vertical));
      verticalWrapSpot.doesNotExist();

      final horizontalWrapSpot =
          spot<Wrap>().whereDirection((it) => it.equals(Axis.horizontal));
      horizontalWrapSpot.existsOnce();
    });

    testWidgets('assert', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(home: Wrap()));
      final wrap = spot<Wrap>().existsOnce();
      wrap.hasDirection(Axis.horizontal);
      expect(
        () => wrap.hasDirection(Axis.vertical),
        throwsSpotErrorContaining([
          'Failed to match widget',
          'Wrap with property direction',
          'equals <Axis.vertical>',
          'actual: <Axis.horizontal>',
        ]),
      );
    });
  });
}
