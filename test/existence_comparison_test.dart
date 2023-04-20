// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

final throwsTestFailure = throwsA(isA<TestFailure>());

Matcher throwsTestFailureWith({dynamic message}) {
  var matcher = isA<TestFailure>();

  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return throwsA(matcher);
}

void main() {
  group('plain', () {
    testWidgets('no match', (tester) async {
      await tester.pumpWidget(Placeholder());

      final spotter = spot<SizedBox>();

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsTestFailure);
      expect(() => spotter.existsAtLeastOnce(), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });

    testWidgets('1 match', (tester) async {
      await tester.pumpWidget(SizedBox());

      final spotter = spot<SizedBox>();

      expect(() => spotter.doesNotExist(), throwsTestFailure);
      expect(() => spotter.existsOnce(), returnsNormally);
      expect(() => spotter.existsAtLeastOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });

    testWidgets('2 matches ', (tester) async {
      await tester.pumpWidget(Column(children: [SizedBox(), SizedBox()]));

      final spotter = spot<SizedBox>();

      expect(() => spotter.doesNotExist(), throwsTestFailure);
      expect(() => spotter.existsOnce(), throwsTestFailure);
      expect(() => spotter.existsAtLeastOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(2), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(1), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(2), returnsNormally);
    });
  });

  group('match parent', () {
    testWidgets('parent and item exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<SizedBox>(parents: [spot<Center>()]);

      expect(spotter.snapshot().matchingElements.length, 1);

      expect(() => spotter.doesNotExist(), throwsTestFailure);
      expect(() => spotter.existsOnce(), returnsNormally);
      expect(() => spotter.existsAtLeastOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });

    testWidgets('parent does not exist, item exists', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<SizedBox>(parents: [spot<Material>()]);

      expect(spotter.snapshot().matchingElements.length, 0);

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsTestFailure);
      expect(() => spotter.existsAtLeastOnce(), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });

    testWidgets('parent exists, item does not exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<Material>(parents: [spot<SizedBox>()]);

      final throwsFailureWithMessage = throwsTestFailureWith(
        message: contains(
            "Could not find 'Material with parents: ['SizedBox']' in widget tree"),
      );

      expect(spotter.snapshot().matchingElements.length, 0);

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastOnce(), throwsFailureWithMessage);
      expect(() => spotter.existsExactlyNTimes(1), throwsFailureWithMessage);
      expect(() => spotter.existsExactlyNTimes(2), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastNTimes(1), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastNTimes(2), throwsFailureWithMessage);
    });

    testWidgets('error shows alternative item', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            Center(child: SizedBox()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<Center>(
        children: [spot<SizedBox>()],
        parents: [spot<Material>()], // <-- does not exist
      );

      expect(spotter.snapshot().matchingElements.length, 0);

      final throwsFailureWithMessage = throwsTestFailureWith(
        message: allOf(
          contains("but found 1 matches when searching for "
              "'Center"),
          contains(
            "Possible match #1: Center(alignment: Alignment.center)",
          ),
        ),
      );

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastOnce(), throwsFailureWithMessage);
      expect(() => spotter.existsExactlyNTimes(1), throwsFailureWithMessage);
      expect(() => spotter.existsExactlyNTimes(2), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastNTimes(1), throwsFailureWithMessage);
      expect(() => spotter.existsAtLeastNTimes(2), throwsFailureWithMessage);
    });
  });

  group('match child', () {
    testWidgets('item and child exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            SizedBox(child: Center()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<SizedBox>(children: [spot<Center>()]);

      expect(spotter.snapshot().matchingElements.length, 1);

      expect(() => spotter.doesNotExist(), throwsTestFailure);
      expect(() => spotter.existsOnce(), returnsNormally);
      expect(() => spotter.existsAtLeastOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });

    testWidgets('item exists, child does not exist', (tester) async {
      await tester.pumpWidget(
        Column(
          children: [
            SizedBox(child: Center()),
            SizedBox(),
          ],
        ),
      );

      final spotter = spot<SizedBox>(children: [spot<Material>()]);

      expect(spotter.snapshot().matchingElements.length, 0);

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsTestFailure);
      expect(() => spotter.existsAtLeastOnce(), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
    });
  });

  group('better error messages', () {
    testWidgets('not enough widgets with all criteria found', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Text('a'),
              SizedBox(child: Text('b')),
              Row(
                children: [Text('c')],
              ),
            ],
          ),
        ),
      );
      expect(
        () => spotAll<Text>(parents: [spot<Row>()]).existsAtLeastNTimes(2),
        throwsTestFailureWith(
          message: allOf(
            contains(
                "Could not find at least 2 matches for Row > Text in widget "
                "tree, but found 3 matches when searching for 'Text'"),
            contains(
                "Please check the 3 matches for Text and adjust the constraints "
                "of the selector 'Text with parents: ['Row']' accordingly"),
            contains('Possible match #1: Text("a")'),
            contains('Possible match #2: Text("b")'),
            contains('Possible match #3: Text("c")'),
          ),
        ),
      );
    });

    testWidgets('too many widgets with all criteria found', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Text('aa'),
              Text('ab'),
              SizedBox(child: Text('ac')),
              Row(
                children: [Text('ad')],
              ),
            ],
          ),
        ),
      );

      expect(
        () => spotAll<Text>()
            .whereText(
              (text) => text?.startsWith('a') ?? false,
              description: 'should start with "a"',
            )
            .existsExactlyNTimes(3),
        throwsTestFailureWith(
          message: allOf(
            contains(
              "Found 4 elements matching 'Text should start with \"a\"' in widget tree, "
              'expected at most 3',
            ),
            contains('Text("aa")'),
            contains('Text("ab")'),
            contains('Text("ac")'),
            contains('Text("ad")'),
          ),
        ),
      );
    });
  });
}
