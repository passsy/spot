// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('Catch early when spotSingle matches multiple widgets', () {
    testWidgets('case 1', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            child: Row(
              children: [
                Container(),
                Container(
                  child: Text('Hello'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(Container),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );

      spotSingle<Text>(parents: [spot<Container>()]).existsOnce();

      expect(
        () => spotSingle<Text>(parents: [spotSingle<Container>()]).existsOnce(),
        throwsSpotErrorContaining([
          "Found 3 elements matching Container in widget tree, expected at most 1",
        ]),
      );
    });

    testWidgets('case 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text('Test'),
              actions: [
                Text('Option'),
              ],
            ),
            body: Column(
              children: [
                AppBar(title: Text('Test')),
              ],
            ),
          ),
        ),
      );

      final appBar = spotSingle<AppBar>();
      expect(
        () => appBar.spotSingle<Text>().existsOnce(),
        throwsSpotErrorContaining([
          "Found 2 elements matching AppBar in widget tree, expected at most 1",
        ]),
      );
    });
  });
}
