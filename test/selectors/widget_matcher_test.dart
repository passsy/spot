import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('WidgetMatcher public API', (tester) async {
    await tester.pumpWidget(const MaterialApp());
    final app = spot<MaterialApp>();
    final snapshot = app.snapshot();
    final WidgetMatcher<MaterialApp> matcher = snapshot.single;
    final MaterialApp widget = matcher.widget;
    expect(widget, isA<MaterialApp>());
    final Element element = matcher.element;
    expect(element, isA<Element>());
    final WidgetSelector<MaterialApp> selector = matcher.selector;
    expect(selector, isA<WidgetSelector<MaterialApp>>());
    final WidgetMatcher<MaterialApp> hasWidgetProp = matcher.hasWidgetProp(
      prop: widgetProp('null', _getNullWidgetProp),
      match: (it) => it
          .has((Widget widget) => widget.toStringDeep(), 'toStringDeep')
          .isNull(),
    );
    expect(hasWidgetProp, isA<WidgetMatcher<MaterialApp>>());

    final Widget? getWidgetProp =
        matcher.getWidgetProp(widgetProp('null', _getNullWidgetProp));
    expect(getWidgetProp, isNull);

    final WidgetMatcher<MaterialApp> hasElementProp = matcher.hasElementProp(
      prop: elementProp('null', _getNullWidgetProp),
      match: (it) => it
          .has((Widget widget) => widget.toStringDeep(), 'toStringDeep')
          .isNull(),
    );
    expect(hasElementProp, isA<WidgetMatcher<MaterialApp>>());

    final Widget? getElementProp =
        matcher.getElementProp(elementProp('null', _getNullWidgetProp));
    expect(getElementProp, isNull);

    final WidgetMatcher<MaterialApp> hasRenderObjectProp =
        matcher.hasRenderObjectProp(
      prop: renderObjectProp('null', _getNullWidgetProp),
      match: (it) => it
          .has((Widget widget) => widget.toStringDeep(), 'toStringDeep')
          .isNull(),
    );
    expect(hasRenderObjectProp, isA<WidgetMatcher<MaterialApp>>());

    final Widget? getRenderObjectProp = matcher
        .getRenderObjectProp(renderObjectProp('null', _getNullWidgetProp));
    expect(getRenderObjectProp, isNull);
  });

  testWidgets('MultiWidgetMatcher public API', (tester) async {
    await tester.pumpWidget(const MaterialApp());
    final app = spot<MaterialApp>();
    final snapshot = app.snapshot();
    final MultiWidgetMatcher<MaterialApp> matcher = snapshot.multi;

    final List<Widget> widgets = matcher.widgets;
    expect(widgets, isA<List<Widget>>());
    expect(widgets, hasLength(1));
    final List<Element> elements = matcher.elements;
    expect(elements, isA<List<Element>>());
    expect(elements, hasLength(1));
    final WidgetSelector<MaterialApp> selectors = matcher.selector;
    expect(selectors, isA<WidgetSelector<MaterialApp>>());
    final List<WidgetMatcher<MaterialApp>> discovered = matcher.discovered;
    expect(discovered, isA<List<WidgetMatcher<MaterialApp>>>());
    expect(discovered, hasLength(1));

    final MultiWidgetMatcher<MaterialApp> all =
        matcher.all((WidgetMatcher<MaterialApp> widget) {
      widget.hasWidgetProp(
        prop: widgetProp('null', _getNullWidgetProp),
        match: (it) => it
            .has((Widget widget) => widget.toStringDeep(), 'toStringDeep')
            .isNull(),
      );
    });
    expect(all, isA<MultiWidgetMatcher<MaterialApp>>());

    final MultiWidgetMatcher<MaterialApp> any =
        matcher.any((WidgetMatcher<MaterialApp> widget) {
      widget.hasWidgetProp(
        prop: widgetProp('null', _getNullWidgetProp),
        match: (it) => it
            .has((Widget widget) => widget.toStringDeep(), 'toStringDeep')
            .isNull(),
      );
    });
    expect(any, isA<MultiWidgetMatcher<MaterialApp>>());
  });
}

/// A function that returns a `Widget?` with the static value null
///
/// It is useful to test nullable support in the API
Widget? Function(Object?) _getNullWidgetProp = (any) => null;
