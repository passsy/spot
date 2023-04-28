// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('top-level', () {
    testWidgets('spotKey', (tester) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            key: const ValueKey('key'),
          ),
        ),
      );
      spotSingleKey(const ValueKey('key')).existsOnce();
    });

    testWidgets('spotKey errors', (tester) async {
      await tester.pumpWidget(Center());
      expect(
        () => spotSingleKey(const ValueKey('key')).existsOnce(),
        throwsSpotErrorContaining([
          "Could not find 'Widget with key: \"[<'key'>]\"' in widget tree",
        ]),
      );
    });
  });

  group('extension', () {
    testWidgets('spotKey', (tester) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            key: const ValueKey('key'),
          ),
        ),
      );
      spot<Center>().spotSingleKey(const ValueKey('key')).existsOnce();
    });

    testWidgets('spotKey errors', (tester) async {
      await tester.pumpWidget(Center(child: SizedBox()));
      expect(
        () => spot<Center>().spotSingleKey(const ValueKey('key')).existsOnce(),
        throwsSpotErrorContaining([
          "Could not find 'Widget with key: \"[<'key'>]\" with parents: ['Center']' in widget tree",
        ]),
      );
    });
  });

  group('spotKeys', () {
    testWidgets('spot multiple keys', (tester) async {
      const key1 = ValueKey(1);
      const key2 = ValueKey(2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Row(
                children: [
                  Text('a', key: key1),
                  Text('b', key: key2),
                ],
              ),
              Wrap(
                children: [
                  Text('x', key: key1),
                  Text('y', key: key2),
                ],
              )
            ],
          ),
        ),
      );
      spotKeys(key1).existsExactlyNTimes(2);
      spotKeys(key2).existsExactlyNTimes(2);
    });

    testWidgets(
      'error prints both elements with the same key',
      (tester) async {
        const key1 = ValueKey(1);
        const key2 = ValueKey(2);

        await tester.pumpWidget(
          const MaterialApp(
            home: Column(
              children: [
                Row(
                  children: [
                    Text('a', key: key1),
                    Text('b', key: key2),
                  ],
                ),
                Wrap(
                  children: [
                    Text('x', key: key1),
                    Text('y', key: key2),
                  ],
                )
              ],
            ),
          ),
        );
        expect(
          () => spotSingleKey(key1).existsOnce(),
          throwsSpotErrorContaining([
            "Found 2 elements matching 'Widget with key: \"[<1>]\"'",
            'Text-[<1>]("a"',
            'Text-[<1>]("x"',
          ]),
          skip: 'fix _findCommonAncestor()',
        );
      },
    );
  });
}
