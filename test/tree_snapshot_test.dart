// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/tree_snapshot.dart';

void main() {
  testWidgets('allElements are returned depth-first', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        // 5
        child: Row(
          children: [
            // 6
            Center(
              child: SizedBox(), // 7
            ),
            Align(), // 8
          ],
        ),
      ),
    );
    final tree = widgetTreeSnapshot();
    final widgets = tree.allElements;
    expect(widgets, isNotEmpty);
    final center =
        widgets.firstWhere((element) => element.widget.runtimeType == Center);
    final indexOfCenter = widgets.indexOf(center);
    final align =
        widgets.firstWhere((element) => element.widget.runtimeType == Align);
    final indexOfAlign = widgets.indexOf(align);
    final sizedBox =
        widgets.firstWhere((element) => element.widget.runtimeType == SizedBox);
    final indexOfSizedBox = widgets.indexOf(sizedBox);

    expect(center.depth, align.depth);
    expect(sizedBox.depth, greaterThan(center.depth));
    expect(sizedBox.depth, greaterThan(align.depth));

    expect(indexOfCenter, lessThan(indexOfAlign));
    expect(indexOfCenter, lessThan(indexOfSizedBox));
    expect(indexOfAlign, greaterThan(indexOfSizedBox));
  });

  testWidgets('allElements matches flutter order', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Center(
              child: SizedBox(),
            ),
            Align(),
          ],
        ),
      ),
    );
    final tree = widgetTreeSnapshot();
    final widgets = tree.allElements;
    final flutterOrderWidgets =
        collectAllElementsFrom(tree.origin.element, skipOffstage: true)
            .toList();

    expect(widgets, flutterOrderWidgets);
  });

  testWidgets('scopes', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Center(
              child: SizedBox(),
            ),
            Align(),
          ],
        ),
      ),
    );
    final tree = widgetTreeSnapshot();
    final items = tree.allNodes;
    final row =
        items.firstWhere((node) => node.element.widget.runtimeType == Row);

    final center =
        items.firstWhere((node) => node.element.widget.runtimeType == Center);

    final one = tree.scope(row);
    final two = one.scope(center);

    final scopes = two.scopes;
    expect(scopes.length, 2);
    expect(scopes[1], tree);
    expect(scopes[0], one);
  });

  testWidgets('invalidate', (tester) async {
    await tester.pumpWidget(Center());
    final tree = widgetTreeSnapshot();
    expect(tree.isFromThisFrame, isTrue);
    await tester.pumpWidget(Center());
    expect(tree.isFromThisFrame, isFalse);
  });
}
