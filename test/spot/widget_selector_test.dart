import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';

void main() {
  test('toString() Not child parent ambiguity', () {
    final selector1 =
        spot<Center>().withChild(spot<SizedBox>().withParent(spot<Row>()));

    final selector2 =
        spot<Center>().withChild(spot<SizedBox>()).withParent(spot<Row>());
    expect(
      selector1.toString(),
      'Center with child (SizedBox with parent Row)',
    );
    expect(
      selector2.toString(),
      'Center with child SizedBox ❯ with parent Row',
    );
  });

  test('toStringBreadcrumb() Not child parent ambiguity', () {
    final selector1 =
        spot<Center>().withChild(spot<SizedBox>().withParent(spot<Row>()));

    final selector2 =
        spot<Center>().withChild(spot<SizedBox>()).withParent(spot<Row>());
    expect(
      selector1.toStringBreadcrumb(),
      'Center with child (Row ᗕ SizedBox)',
    );
    expect(
      selector2.toStringBreadcrumb(),
      'Row ᗕ Center with child SizedBox',
    );
  });

  group('all', () {
    testWidgets('find all widgets', (tester) async {
      await tester.pumpWidget(const MaterialApp());
      final s = spotAllWidgets().snapshot();
      expect(s.discovered.length, greaterThan(10));
      spotAllWidgets().spot<MaterialApp>().existsOnce();
    });
  });

  group('lessSpecificSelectors()', () {
    test('no less specific ones', () {
      final selector = spot<Center>();
      final lessSpecificSelectors = selector.lessSpecificSelectors().toList();
      expect(lessSpecificSelectors.length, 0);
    });
    test('one level', () {
      final selector = spot<Center>().spot<Container>();
      final lessSpecificSelectors = selector.lessSpecificSelectors().toList();
      expect(lessSpecificSelectors.length, 2);
      expect(
        lessSpecificSelectors[0].toStringBreadcrumb(),
        spot<Container>().toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[1].toStringBreadcrumb(),
        spot().withParent(spot<Center>()).toStringBreadcrumb(),
      );
    });

    test('two levels', () {
      final selector =
          spot<Center>().spot<Container>().withAlignment(Alignment.topCenter);
      final lessSpecificSelectors = selector.lessSpecificSelectors().toList();
      expect(lessSpecificSelectors.length, 6);
      expect(
        lessSpecificSelectors[0].toStringBreadcrumb(),
        spot<Container>().withParent(spot<Center>()).toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[1].toStringBreadcrumb(),
        spot<Container>()
            .withAlignment(Alignment.topCenter)
            .toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[2].toStringBreadcrumb(),
        allCasted<Container>()
            .withParent(spot<Center>())
            .withAlignment(Alignment.topCenter)
            .toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[3].toStringBreadcrumb(),
        spot<Container>().toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[4].toStringBreadcrumb(),
        allCasted().withParent(spot<Center>()).toStringBreadcrumb(),
      );
      expect(
        lessSpecificSelectors[5].toStringBreadcrumb(),
        allCasted<Container>()
            .withAlignment(Alignment.topCenter)
            .toStringBreadcrumb(),
      );
    });

    test('spotKey has no less specific selectors', () {
      final selector = spotKey(const ValueKey('a'));
      final lessSpecificSelectors = selector.lessSpecificSelectors().toList();
      expect(lessSpecificSelectors.length, 1);
    });
  });
}

/// Returns a [WidgetSelector] matching all widgets but allows building further
/// selectors for the [Widget] type [T].
WidgetSelector<T> allCasted<T extends Widget>() {
  return WidgetSelector(stages: WidgetSelector.all.stages);
}
