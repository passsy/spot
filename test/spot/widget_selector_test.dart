import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  group('toString()', () {
    test('Not child parent ambiguity', () {
      final selector1 =
          spot<Center>().withChild(spot<SizedBox>().withParent(spot<Row>()));

      final selector2 =
          spot<Center>().withChild(spot<SizedBox>()).withParent(spot<Row>());
      expect(
        selector1.toString(),
        'Center with child SizedBox with parent Row',
      );
      expect(
        selector2.toString(),
        'Center with child SizedBox > with parent Row',
      );
    });
  });

  group('toStringBreadcrumb()', () {
    test('Not child parent ambiguity', () {
      final selector1 =
          spot<Center>().withChild(spot<SizedBox>().withParent(spot<Row>()));

      final selector2 =
          spot<Center>().withChild(spot<SizedBox>()).withParent(spot<Row>());
      expect(
        selector1.toStringBreadcrumb(),
        'Center with child SizedBox with parent Row',
      );
      expect(
        selector2.toStringBreadcrumb(),
        'Center with child SizedBox > with parent Row',
      );
    });
  });
}
