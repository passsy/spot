// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('description', (widgetTester) async {
    await widgetTester.pumpWidget(MaterialApp(home: Wrap()));

    final verticalWrapSpot = spot<Wrap>().withDirection(Axis.vertical);
    final horizontalWrapSpot = spot<Wrap>().withDirection(Axis.horizontal);
    horizontalWrapSpot.existsOnce().hasDirection(Axis.horizontal);
    verticalWrapSpot.doesNotExist();
  });
}
