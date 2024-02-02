// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  testWidgets('doesNotExist() checks for non-existence', (tester) async {
    await tester.pumpWidget(MaterialApp());
    spot<Placeholder>().doesNotExist();
  });

  testWidgets('negate child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(),
        ),
      ),
    );
    spot<Scaffold>().existsOnce();
    spot<Scaffold>().withChild(spot<ListView>()).existsOnce();

    // check that Scaffold does not have a child of type ListView
    spot<Scaffold>().withChild(spot<ListView>().atMost(0)).doesNotExist();

    // check that Scaffold does not have a child of type Placeholder
    spot<Scaffold>().withChild(spot<Placeholder>().atMost(0)).existsOnce();
  });

  testWidgets('fail due to negate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(),
        ),
      ),
    );

    expect(
      () => spot<Scaffold>().withChild(spot<ListView>().atMost(0)).existsOnce(),
      throwsSpotErrorContaining(
        [
          'Could not find Scaffold with child ListView (amount: 0) in widget tree, expected exactly 1',
        ],
      ),
    );
    expect(
      () =>
          spot<Scaffold>().withChild(spot<ListView>().atMost(0)).doesNotExist(),
      returnsNormally,
    );
  });
}
