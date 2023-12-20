// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart';

void main() {
  group('match custom property', () {
    final checkedCheckbox = MaterialApp(
      home: Scaffold(
        body: Checkbox(
          value: true,
          onChanged: (_) {},
        ),
      ),
    );

    final uncheckedCheckbox = MaterialApp(
      home: Scaffold(
        body: Checkbox(
          value: false,
          onChanged: (_) {},
        ),
      ),
    );
    final checkbox = spotSingle<Checkbox>();

    testWidgets('hasProp selector', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasProp(
            // ignore: deprecated_member_use_from_same_package
            selector: (e) => e.context.nest(
              () => ['Checkbox', 'value'],
              (e) => Extracted.value((e.widget as Checkbox).value),
            ),
            match: (it) => it.equals(true),
          );

      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasProp(
            // ignore: deprecated_member_use_from_same_package
            selector: (e) => e.context.nest(
              () => ['Checkbox', 'value'],
              (e) => Extracted.value((e.widget as Checkbox).value),
            ),
            match: (it) => it.equals(false),
          );
    });

    testWidgets('hasProp elementSelector', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasProp(
            elementSelector: (e) => e.context.nest(
              () => ['Checkbox', 'value'],
              (e) => Extracted.value((e.widget as Checkbox).value),
            ),
            match: (it) => it.equals(true),
          );

      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasProp(
            elementSelector: (e) => e.context.nest(
              () => ['Checkbox', 'value'],
              (e) => Extracted.value((e.widget as Checkbox).value),
            ),
            match: (it) => it.equals(false),
          );
    });

    testWidgets('hasProp widgetSelector', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasProp(
            widgetSelector: (widget) => widget.context.nest(
              () => ['value'],
              (widget) => Extracted.value(widget.value),
            ),
            match: (it) => it.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasProp(
            widgetSelector: (widget) => widget.context.nest(
              () => ['value'],
              (widget) => Extracted.value(widget.value),
            ),
            match: (it) => it.equals(false),
          );
    });

    testWidgets('hasElementProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasElementProp(
            name: 'value',
            prop: (it) => (it.widget as Checkbox).value,
            match: (it) => it.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasElementProp(
            name: 'value',
            prop: (it) => (it.widget as Checkbox).value,
            match: (it) => it.equals(false),
          );
    });

    testWidgets('hasWidgetProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: (widget) => widget.value,
            name: 'value',
            match: (value) => value.equals(false),
          );

      final CheckBox$value = widgetProp<bool?, Checkbox, RenderObject, Element>(
        'value',
        (it) => it.value,
      );
      checkbox.existsOnce().hasProp2(
            prop: CheckBox$value,
            match: (it) => it.isNotNull(),
          );

      final NamedElementProp<bool, Widget, RenderObject, Element>
          Element$isMounted =
          elementCurry<Element>().prop('mounted', (it) => it.mounted);

      // TODO don't use generics unless we get `out T` in Dart
      checkbox.existsOnce().hasProp2(
            prop: Element$isMounted,
            match: (it) => it.isTrue(),
          );

      checkbox.existsOnce().hasProp2(
            prop: widgetProp('value', (it) => it.value),
            match: (it) => it.isNotNull(),
          );

      checkbox.existsOnce().hasProp2(
            prop: elementProp('mounted', (it) => it.mounted),
            match: (it) => it
              ..isNotNull()
              ..isTrue()
              ..equals(true),
          );

      checkbox.existsOnce().hasProp2(
            prop: renderObject<RenderProxyBox>()
                .prop('constraints', (it) => it.constraints),
            match: (it) => it.has((it) => it.minWidth, 'minWidth').equals(0.0),
          );

      checkbox.existsOnce().hasWidgetProp(
            name: 'value',
            prop: (widget) => widget.value,
            match: (value) => value
              ..equals(false)
              ..isNull(),
          );

      checkbox.existsOnce().hasProp2(
            prop: renderObject<RenderProxyBox>()
                .prop('constraints', (it) => it.constraints),
            match: (it) => it.has((it) => it.minWidth, 'minWidth').equals(0.0),
          );
      checkbox.existsOnce().hasProp2(
            prop:
                NamedRenderObjectProp<bool, Checkbox, RenderProxyBox, Element>(
                    name: 'hasSize', prop: (it) => it.hasSize),
            match: (it) => it.isTrue(),
          );

      await widgetTester.pumpWidget(uncheckedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: (widget) => widget.value,
            name: 'value',
            match: (value) => value.equals(false),
          );

      checkbox.existsOnce().hasElementProp(
            prop: (e) => e.mounted,
            name: 'isMounted',
            match: (value) => value.equals(false),
          );
    });

    testWidgets('whereWidget', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox
          .whereWidget((widget) => widget.value == true,
              description: 'isChecked')
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereWidget((widget) => widget.value == false,
              description: 'isChecked')
          .existsOnce();
    });

    testWidgets('extracted isChecked', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().isChecked(true);
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().isChecked(false);
    });

    testWidgets('extracted isCheckedWhere', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().isCheckedWhere((it) => it.isTrue());
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().isCheckedWhere((it) => it.isFalse());
    });
  });
}

extension on WidgetMatcher<Checkbox> {
  WidgetMatcher<Checkbox> isChecked(bool? checked) {
    return hasWidgetProp(
      name: 'checked',
      prop: (it) => it.value,
      match: (it) => it.equals(checked),
    );
  }

  WidgetMatcher<Checkbox> isCheckedWhere(MatchProp<bool> match) {
    return hasWidgetProp(
      name: 'checked',
      prop: (it) => it.value,
      match: match.hideNullability(),
    );
  }
}
