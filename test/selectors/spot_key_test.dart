// ignore_for_file: prefer_const_constructors

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
      spotKey(const ValueKey('key')).existsOnce();
    });

    testWidgets('spotKey errors', (tester) async {
      await tester.pumpWidget(Center());
      expect(
        () => spotKey(const ValueKey('key')).existsOnce(),
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
      spot<Center>().spotKey(const ValueKey('key')).existsOnce();
    });

    testWidgets('spotKey errors', (tester) async {
      await tester.pumpWidget(Center(child: SizedBox()));
      expect(
        () => spot<Center>().spotKey(const ValueKey('key')).existsOnce(),
        throwsSpotErrorContaining([
          "Could not find 'Widget with key: \"[<'key'>]\" with parents: ['Center']' in widget tree",
        ]),
      );
    });
  });
}
