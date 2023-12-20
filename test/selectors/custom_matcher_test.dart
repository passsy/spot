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

    testWidgets('hasWidgetProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: widgetProp('value', (widget) => widget.value),
            match: (value) => value.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: widgetProp('value', (widget) => widget.value),
            match: (value) => value.equals(false),
          );
    });

    testWidgets('hasElementProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasElementProp(
            prop: elementProp('value', (e) => (e.widget as Checkbox).value),
            match: (it) => it.equals(true),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasElementProp(
            prop: elementProp('value', (e) => (e.widget as Checkbox).value),
            match: (it) => it.equals(false),
          );
    });

    testWidgets('hasRenderObjectProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      final isComplexProp = renderObjectProp<bool, RenderCustomPaint>(
        'isComplex',
        (r) => r.isComplex,
      );
      checkbox.spot<CustomPaint>().existsOnce().hasRenderObjectProp(
            prop: isComplexProp,
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

    testWidgets('whereWidgetProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox
          .whereWidgetProp(
            prop: widgetProp('isChecked', (widget) => widget.value),
            match: (value) => value == true,
          )
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereWidgetProp(
            prop: widgetProp('isChecked', (widget) => widget.value),
            match: (value) => value == false,
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

    testWidgets('extracted hasCheckedValue', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox.existsOnce().hasCheckedValue(true);
      expect(checkbox.snapshotWidget().value, isTrue);
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox.existsOnce().hasCheckedValue(false);
      expect(checkbox.snapshotWidget().value, isFalse);
    });

    testWidgets('extracted hasCheckedValueWhere', (widgetTester) async {
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
      prop: widgetProp('value', (w) => w.value),
      match: (it) => it.equals(checked),
    );
  }

  WidgetMatcher<Checkbox> hasCheckedValueWhere(MatchProp<bool> match) {
    return hasWidgetProp(
      prop: widgetProp('value', (w) => w.value),
      match: match.hideNullability(),
    );
  }
}
