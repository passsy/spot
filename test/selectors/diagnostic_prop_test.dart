// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('diagnostic prop', () {
    testWidgets('getDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      final maxLines =
          spot<Text>().existsOnce().getDiagnosticProp<int>('maxLines');
      expect(maxLines, 4);
    });

    testWidgets('generated getDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      final maxLines2 = spot<Text>().existsOnce().getMaxLines();
      expect(maxLines2, 4);
    });

    testWidgets('hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .existsOnce()
          .hasDiagnosticProp<int>('maxLines', (it) => it.equals(4));

      expect(
        () => spot<Text>()
            .existsOnce()
            .hasDiagnosticProp<int>('maxLines', (it) => it.equals(2)),
        throwsSpotErrorContaining([
          'Text with property maxLines',
          'equals <2>, actual: <4>',
        ]),
      );
    });

    testWidgets('generated hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .existsOnce()
          .hasMaxLines(4)
          .hasMaxLinesWhere((it) => it.equals(4));

      expect(
        () => spot<Text>().existsOnce().hasMaxLines(2),
        throwsSpotErrorContaining([
          'Text with property maxLines',
          'equals <2>, actual: <4>',
        ]),
      );
    });

    testWidgets('withDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .withDiagnosticProp<int>('maxLines', (it) => it.equals(4))
          .existsOnce();

      expect(
        () => spot<Text>()
            .withDiagnosticProp<int>('maxLines', (it) => it.equals(2))
            .existsOnce(),
        throwsSpotErrorContaining([
          'Could not find Text > with prop "maxLines" equals <2> in widget tree',
          'A less specific search (Text) discovered 1 matches!',
          'Text("a", maxLines: 4,',
        ]),
      );
    });

    testWidgets('generated withDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>().withMaxLines(4).existsOnce();
      spot<Text>().whereMaxLines((it) => it.equals(4)).existsOnce();

      spot<Text>().withMaxLines(3).doesNotExist();
      spot<Text>().whereMaxLines((it) => it.equals(3)).doesNotExist();

      expect(
        () => spot<Text>().withMaxLines(2).existsOnce(),
        throwsSpotErrorContaining([
          'Could not find Text > with prop "maxLines" equals <2> in widget tree',
          'A less specific search (Text) discovered 1 matches!',
          'Text("a", maxLines: 4,',
        ]),
      );
    });
  });
}
