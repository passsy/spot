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

    testWidgets('hasWidgetProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: (widget) => widget.value,
            name: 'value',
            match: (value) => value.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: (widget) => widget.value,
            name: 'value',
            match: (value) => value.equals(false),
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

    testWidgets('whereWidget', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox
          .whereWidget(
            (widget) => widget.value == true,
            description: 'isChecked',
          )
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereWidget(
            (widget) => widget.value == false,
            description: 'isChecked',
          )
          .existsOnce();
    });

    testWidgets('whereElement', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox
          .whereElement(
            (el) => (el.widget as Checkbox).value == true,
            description: 'is checked',
          )
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereElement(
            (el) => (el.widget as Checkbox).value == false,
            description: 'is not checked',
          )
          .existsOnce();
    });

    testWidgets('extracted isChecked', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasCheckedValue(true);
      expect(checkbox.snapshotWidget().value, isTrue);
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasCheckedValue(false);
      expect(checkbox.snapshotWidget().value, isFalse);
    });

    testWidgets('extracted isCheckedWhere', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasCheckedValueWhere((it) => it.isTrue());
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasCheckedValueWhere((it) => it.isFalse());
    });
  });
}

extension on WidgetMatcher<Checkbox> {
  WidgetMatcher<Checkbox> hasCheckedValue(bool? checked) {
    return hasWidgetProp(
      name: 'checked',
      prop: (it) => it.value,
      match: (it) => it.equals(checked),
    );
  }

  WidgetMatcher<Checkbox> hasCheckedValueWhere(MatchProp<bool> match) {
    return hasWidgetProp(
      name: 'checked',
      prop: (it) => it.value,
      match: match.hideNullability(),
    );
  }
}
