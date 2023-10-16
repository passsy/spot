// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
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
            name: 'value',
            prop: (it) => it.value,
            match: (it) => it.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasWidgetProp(
            name: 'value',
            prop: (it) => it.value,
            match: (it) => it.equals(false),
          );
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
