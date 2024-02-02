// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('.single keeps all information', (tester) async {
    final multiSelector = spot<Center>(
      parents: [spot<Column>()],
      children: [spot<SizedBox>()],
    ).withAlignment(Alignment.center);

    final singleSelector = multiSelector.single;

    // expect(multiSelector.parents, singleSelector.parents);
    // expect(multiSelector.children, singleSelector.children);
    // expect(multiSelector.props, singleSelector.props);
    expect(multiSelector.mapElementToWidget, singleSelector.mapElementToWidget);
    expect(singleSelector.expectedQuantity, ExpectedQuantity.single);
    expect(multiSelector.expectedQuantity, ExpectedQuantity.multi);
  });

  testWidgets('.multi keeps all information', (tester) async {
    final singleSelector = spotSingle<Center>(
      parents: [spot<Column>()],
      children: [spot<SizedBox>()],
    ).withAlignment(Alignment.center);

    final multiSelector = singleSelector.multi;

    // expect(multiSelector.parents, singleSelector.parents);
    // expect(multiSelector.children, singleSelector.children);
    // expect(multiSelector.props, singleSelector.props);
    expect(multiSelector.mapElementToWidget, singleSelector.mapElementToWidget);
    expect(multiSelector.quantityConstraint, QuantityConstraint.unconstrained);
    expect(singleSelector.quantityConstraint, QuantityConstraint.single);
    expect(multiSelector.expectedQuantity, ExpectedQuantity.multi);
    expect(singleSelector.expectedQuantity, ExpectedQuantity.single);

    await tester.pumpWidget(const Center());
    final centerElement = spotSingle<Center>().snapshot().element!;

    final multiMap = multiSelector.mapElementToWidget(centerElement);
    final singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });

  testWidgets('WidgetSelector API', (tester) async {
    await tester.pumpWidget(const Center());
    final WidgetSelector<Center> selector = spot<Center>();
    // final List<PredicateWithDescription> props = selector.props;
    // expect(props, isNotNull);
    // final List<WidgetSelector<Widget>> parents = selector.parents;
    // expect(parents, isNotNull);
    // final List<WidgetSelector<Widget>> children = selector.children;
    // expect(children, isNotNull);
    // final List<ElementFilter> filters = selector.elementFilters;
    // expect(filters, isNotNull);
    final Type type = selector.type;
    expect(type, isNotNull);
    final ExpectedQuantity expectedQuantity = selector.expectedQuantity;
    expect(expectedQuantity, isNotNull);
    final MultiWidgetSnapshot<Center> snapshot = selector.snapshot();
    expect(snapshot, isNotNull);
    final Center Function(Element element) mapElementToWidget =
        selector.mapElementToWidget;
    expect(mapElementToWidget, isNotNull);
    // final List<ElementFilter> createElementFilters =
    //     selector.createElementFilters();
    // expect(createElementFilters, isNotNull);
    // final String stringWithoutParents = selector.toStringWithoutParents();
    // expect(stringWithoutParents, isNotNull);
    final String stringBreadcrumb = selector.toStringBreadcrumb();
    expect(stringBreadcrumb, isNotNull);
    final WidgetSelector<Center> self = selector.self;
    expect(self, isNotNull);
    final WidgetSelector<Center> copyWith = selector.copyWith();
    expect(copyWith, isNotNull);
    final WidgetSelector<Center> withProp =
        selector.withProp(match: (it) => it, widgetSelector: (it) => it);
    expect(withProp, isNotNull);
    final WidgetSelector<Center> withDiagnosticProp =
        selector.withDiagnosticProp('a', (it) => it);
    expect(withDiagnosticProp, isNotNull);
  });

  testWidgets("don't lose mapElementToWidget", (tester) async {
    final singleSelector = spotText("home").single;
    final multiSelector = singleSelector.multi;

    await tester.pumpWidget(const MaterialApp(home: Text('home')));
    final centerElement = spotText('home').existsOnce().element;

    final AnyText multiMap = multiSelector.mapElementToWidget(centerElement);
    final AnyText singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });
}
