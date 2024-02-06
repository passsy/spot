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

  testWidgets('negate parent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(),
        ),
      ),
    );
    spot<Scaffold>().existsOnce();
    spot<ListView>().withParent(spot<Scaffold>()).existsOnce();

    spot<ListView>().withParent(spot<Scaffold>().atMost(0)).doesNotExist();

    spot<ListView>().withParent(spot<Placeholder>().atMost(0)).existsOnce();
  });

  testWidgets('negate parent offstage test', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Placeholder()));

    final activeOffstages = spot<Offstage>().whereWidgetProp(
      widgetProp('isOffstage', (widget) {
        return widget.offstage;
      }),
      (value) => value == true,
    )..doesNotExist();

    spotAllWidgets().existsExactlyNTimes(133);
    // Could not find Offstage isOffstage (amount: 0) ᗕ any Widget in widget tree, expected at least 1
    final onstage = spotAllWidgets().withParent(activeOffstages.amount(0));
    onstage.existsAtLeastOnce();

    onstage.spotText('foo').existsOnce();
    onstage.spotText('foobar').existsOnce();
  });
}
