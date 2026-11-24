// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart' show SelectorToSnapshot, spot;
import 'package:spot/src/spot/tree_snapshot.dart';

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
    final tree = currentWidgetTreeSnapshot();
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
    final tree = currentWidgetTreeSnapshot();
    final widgets = tree.allElements;
    final flutterOrderWidgets =
        collectAllElementsFrom(tree.origin.element, skipOffstage: true)
            .toList();

    expect(widgets, flutterOrderWidgets);
  });

  testWidgets('snapshot visits onstage children once for a wide parent',
      (tester) async {
    final keys = List.generate(32, ValueKey.new);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: _CountingRow(
          children: [for (final key in keys) SizedBox(key: key)],
        ),
      ),
    );
    final row = tester.element<_CountingRowElement>(find.byType(_CountingRow));
    row.onstageVisits = 0;

    final snapshot = createWidgetTreeSnapshot();
    final node = snapshot.allNodes.singleWhere((node) => node.element == row);

    expect(node.children.map((child) => child.element.widget.key), keys);
    expect(row.onstageVisits, 1);
  });

  testWidgets('captured nodes reject children after traversal is cached',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [SizedBox()]),
      ),
    );
    final result = spot<Row>().snapshot();
    final row = result.discovered.single;
    final leaf = row.children.single;
    final traversal = result.scope.allNodes;
    expect(traversal, containsAll([row, leaf]));

    for (final node in [row, leaf]) {
      final children = node.children;
      final added = WidgetTreeNode(
        element: leaf.element,
        parent: node,
        isOffstage: false,
      );

      expect(() => node.addChild(added), throwsStateError);
      expect(node.children, same(children));
      expect(result.scope.allNodes, same(traversal));
    }

    final manual = WidgetTreeNode(
      element: row.element,
      parent: null,
      isOffstage: false,
    );
    final child = WidgetTreeNode(
      element: leaf.element,
      parent: manual,
      isOffstage: false,
    );
    manual.addChild(child);
    expect(manual.children, [child]);
    expect(() => manual.children.clear(), throwsUnsupportedError);
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
    final tree = currentWidgetTreeSnapshot();
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
    final tree = currentWidgetTreeSnapshot();
    expect(tree.isFromThisFrame, isTrue);
    await tester.pumpWidget(Center());
    expect(tree.isFromThisFrame, isFalse);
  });
}

class _CountingRow extends Row {
  const _CountingRow({required super.children});

  @override
  _CountingRowElement createElement() => _CountingRowElement(this);
}

class _CountingRowElement extends MultiChildRenderObjectElement {
  _CountingRowElement(_CountingRow super.widget);

  int onstageVisits = 0;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    onstageVisits++;
    super.debugVisitOnstageChildren(visitor);
  }
}
