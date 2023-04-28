// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('filter', (widgetTester) async {
    final verticalWrapSpot = spotSingle<Wrap>().withDirection(Axis.vertical);

    expect(
      verticalWrapSpot.toString(),
      allOf([
        contains('prop "direction"'),
        contains('<Axis.vertical>'),
      ]),
    );

    final horizontalWrapSpot = spotSingle<Wrap>()
        .whereDirection((it) => it.equals(Axis.horizontal));

    expect(
      horizontalWrapSpot.toString(),
      allOf([
        contains('prop "direction"'),
        contains('<Axis.horizontal>'),
      ]),
    );
  });
}
