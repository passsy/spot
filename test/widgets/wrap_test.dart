// ignore_for_file: prefer_const_constructors

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('direction', () {
    testWidgets('filter', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(home: Wrap()));

      final verticalWrapSpot =
          spotSingle<Wrap>().withDirection((it) => it.equals(Axis.vertical));
      verticalWrapSpot.doesNotExist();

      final horizontalWrapSpot =
          spotSingle<Wrap>().withDirection((it) => it.equals(Axis.horizontal));
      horizontalWrapSpot.existsOnce();
    });

    testWidgets('assert', (widgetTester) async {
      await widgetTester.pumpWidget(MaterialApp(home: Wrap()));
      final wrap = spot<Wrap>().existsOnce();
      wrap.hasDirection((it) => it.equals(Axis.horizontal));
      expect(
        () => wrap.hasDirection((it) => it.equals(Axis.vertical)),
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
