// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

final throwsTestFailure = throwsA(isA<TestFailure>());

void main() {
  group('plain', () {
    testWidgets('no match', (tester) async {
      await tester.pumpWidget(Placeholder());

      final sizedBox = spot<SizedBox>();

      expect(() => sizedBox.doesNotExist(), returnsNormally);
      expect(() => sizedBox.existsOnce(), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastOnce(), throwsTestFailure);
      sizedBox.existsAtMostOnce();
      expect(() => sizedBox.existsAtMostOnce(), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtMostNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtMostNTimes(2), returnsNormally);
    });

    testWidgets('1 match', (tester) async {
      await tester.pumpWidget(SizedBox());

      final sizedBox = spot<SizedBox>();

      expect(() => sizedBox.doesNotExist(), throwsTestFailure);
      expect(() => sizedBox.existsOnce(), returnsNormally);
      expect(() => sizedBox.existsAtLeastOnce(), returnsNormally);
      expect(() => sizedBox.existsAtMostOnce(), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(1), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtMostNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtMostNTimes(2), returnsNormally);
    });

    testWidgets('2 matches ', (tester) async {
      await tester.pumpWidget(Column(children: [SizedBox(), SizedBox()]));

      final sizedBox = spot<SizedBox>();

      expect(() => sizedBox.doesNotExist(), throwsTestFailure);
      expect(() => sizedBox.existsOnce(), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastOnce(), returnsNormally);
      expect(() => sizedBox.existsAtMostOnce(), throwsTestFailure);
      expect(() => sizedBox.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsExactlyNTimes(2), returnsNormally);
      expect(() => sizedBox.existsAtLeastNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtLeastNTimes(2), returnsNormally);
      expect(() => sizedBox.existsAtMostNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsAtMostNTimes(2), returnsNormally);
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

      final sizedBox = spot<SizedBox>(parents: [spot<Center>()]);

      expect(sizedBox.snapshot().discovered, isNotNull);

      expect(() => sizedBox.doesNotExist(), throwsTestFailure);
      expect(() => sizedBox.existsOnce(), returnsNormally);
      expect(() => sizedBox.existsAtLeastOnce(), returnsNormally);
      expect(() => sizedBox.existsAtMostOnce(), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(1), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtMostNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtMostNTimes(2), returnsNormally);
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

      final sizedBox = spot<SizedBox>(parents: [spot<Material>()]);

      expect(sizedBox.snapshot().discovered, isEmpty);

      expect(() => sizedBox.doesNotExist(), returnsNormally);
      expect(() => sizedBox.existsOnce(), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastOnce(), throwsTestFailure);
      expect(() => sizedBox.existsAtMostOnce(), returnsNormally);
      expect(() => sizedBox.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => sizedBox.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => sizedBox.existsAtMostNTimes(1), returnsNormally);
      expect(() => sizedBox.existsAtMostNTimes(2), returnsNormally);
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

      final material = spot<Material>(parents: [spot<SizedBox>()]);

      final throwsFailureWithMessage = throwsSpotErrorContaining(
        ["Could not find SizedBox ᗕ Material in widget tree"],
      );

      expect(material.snapshot().discovered, isEmpty);

      expect(() => material.doesNotExist(), returnsNormally);
      expect(() => material.existsOnce(), throwsFailureWithMessage);
      expect(() => material.existsAtLeastOnce(), throwsFailureWithMessage);
      expect(() => material.existsAtMostOnce(), returnsNormally);
      expect(() => material.existsExactlyNTimes(1), throwsFailureWithMessage);
      expect(() => material.existsExactlyNTimes(2), throwsFailureWithMessage);
      expect(() => material.existsAtLeastNTimes(1), throwsFailureWithMessage);
      expect(() => material.existsAtLeastNTimes(2), throwsFailureWithMessage);
      expect(() => material.existsAtMostNTimes(1), returnsNormally);
      expect(() => material.existsAtMostNTimes(2), returnsNormally);
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

      final selector = spot<Center>(
        children: [spot<SizedBox>()],
        parents: [spot<Material>()], // <-- does not exist
      );

      expect(selector.snapshot().discovered, isEmpty);

      final throwsFailureWithMessage = throwsSpotErrorContaining([
        "Could not find Material ᗕ Center with child SizedBox in widget tree, expected",
        RegExp(r"(?:exactly|at most|at least) \d+"),
        RegExp(
          r"A less specific search \(Center with child SizedBox\) discovered \d+ matches",
        ),
        "Possible match #1:\nCenter(alignment: Alignment.center",
      ]);

      expect(() => selector.doesNotExist(), returnsNormally);
      expect(() => selector.existsOnce(), throwsFailureWithMessage);
      expect(() => selector.existsAtLeastOnce(), throwsFailureWithMessage);
      expect(() => selector.existsAtMostOnce(), returnsNormally);
      expect(() => selector.existsExactlyNTimes(1), throwsFailureWithMessage);
      expect(() => selector.existsExactlyNTimes(2), throwsFailureWithMessage);
      expect(() => selector.existsAtLeastNTimes(1), throwsFailureWithMessage);
      expect(() => selector.existsAtLeastNTimes(2), throwsFailureWithMessage);
      expect(() => selector.existsAtMostNTimes(1), returnsNormally);
      expect(() => selector.existsAtMostNTimes(2), returnsNormally);
    });
  });

  testWidgets('error shows alternative widgets when found less',
      (tester) async {
    await tester.pumpWidget(
      Column(
        children: [
          Center(child: SizedBox()),
          SizedBox(),
        ],
      ),
    );

    final selector = spot<SizedBox>()
        // does not exist
        .withParent(spot<Scaffold>());
    final snapshot = selector.snapshot();
    expect(snapshot.discovered, isEmpty);

    expect(
      () => snapshot.existsOnce(),
      throwsSpotErrorContaining([
        "Could not find Scaffold ᗕ SizedBox in widget tree, expected exactly 1",
        "A less specific search (SizedBox) discovered 2 matches!",
        "Maybe you have to adjust your WidgetSelector (SizedBox with parent Scaffold) to cover those missing elements.",
        "Possible match #1:",
        "SizedBox(renderObject:",
        "Possible match #2:",
        "SizedBox(renderObject:",
        "See the timeline at the very bottom for the full widget tree",
      ]),
    );
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

      expect(spotter.snapshot().discovered, isNotNull);

      expect(() => spotter.doesNotExist(), throwsTestFailure);
      expect(() => spotter.existsOnce(), returnsNormally);
      expect(() => spotter.existsAtLeastOnce(), returnsNormally);
      expect(() => spotter.existsAtMostOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), returnsNormally);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtMostNTimes(1), returnsNormally);
      expect(() => spotter.existsAtMostNTimes(2), returnsNormally);
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

      expect(spotter.snapshot().discovered, isEmpty);

      expect(() => spotter.doesNotExist(), returnsNormally);
      expect(() => spotter.existsOnce(), throwsTestFailure);
      expect(() => spotter.existsAtLeastOnce(), throwsTestFailure);
      expect(() => spotter.existsAtMostOnce(), returnsNormally);
      expect(() => spotter.existsExactlyNTimes(1), throwsTestFailure);
      expect(() => spotter.existsExactlyNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(1), throwsTestFailure);
      expect(() => spotter.existsAtLeastNTimes(2), throwsTestFailure);
      expect(() => spotter.existsAtMostNTimes(1), returnsNormally);
      expect(() => spotter.existsAtMostNTimes(2), returnsNormally);
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
        () => spot<Text>(parents: [spot<Row>()]).existsAtLeastNTimes(2),
        throwsSpotErrorContaining(
          [
            "Found 1 elements matching Row ᗕ Text in widget tree, expected at least 2",
            "A less specific search (Text) discovered 3 matches!",
            "Maybe you have to adjust your WidgetSelector (Text with parent Row) to cover those missing elements.",
            'Possible match #1:\nText("a"',
            'Possible match #2:\nText("b"',
            'Possible match #3:\nText("c"',
          ],
          not: ['#4'],
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
        () => spot<Text>()
            .whereText((text) => text.startsWith('a'))
            .existsExactlyNTimes(3),
        throwsSpotErrorContaining([
          'Found 4 elements matching Text with prop "data" starts with \'a\' in widget tree, expected exactly 3.',
          'Check the timeline at the very bottom for more information.',
        ]),
      );
      expect(
        timeline.events.last.details,
        stringContainsInOrder([
          'Text("aa"',
          'Text("ab"',
          'Text("ac"',
          'Text("ad"',
        ]),
      );
    });
  });
}
