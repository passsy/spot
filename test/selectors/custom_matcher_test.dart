// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';

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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (_) {},
        ),
      ),
    );

    final undecidedCheckbox = MaterialApp(
      home: Scaffold(
        body: Checkbox(
          value: null,
          tristate: true,
          onChanged: (_) {},
        ),
      ),
    );

    final uncheckedPaddedCheckbox = MaterialApp(
      home: Scaffold(
        body: Checkbox(
          value: false,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onChanged: (_) {},
        ),
      ),
    );
    final checkbox = spot<Checkbox>();

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
            match: (value) => value.isTrue(),
          );
      checkbox.existsOnce().hasWidgetProp(
            prop: widgetProp('value', (widget) => widget.value),
            match: (value) => value.isTrue(),
          );
      await widgetTester.pumpWidget(uncheckedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: widgetProp('value', (widget) => widget.value),
            match: (value) => value.isFalse(),
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
            match: (it) => it.isFalse(),
          );
    });

    testWidgets('hasRenderObjectProp', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);
      final isComplexProp = renderObjectProp<bool?, RenderCustomPaint>(
        'isComplex',
        (r) => r.isComplex,
      );
      checkbox.spot<CustomPaint>().existsOnce().hasRenderObjectProp(
            prop: isComplexProp,
            match: (it) => it.isFalse(),
          );
    });

    testWidgets('whereRenderObjectProp', (widgetTester) async {
      await widgetTester.pumpWidget(uncheckedCheckbox);
      final height =
          renderObjectProp<double, RenderBox>('height', (r) => r.size.height);
      checkbox
          .whereRenderObjectProp(height, (value) => value == 40.0)
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedPaddedCheckbox);
      checkbox
          .whereRenderObjectProp(height, (value) => value == 48.0)
          .existsOnce();
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
            widgetProp('isChecked', (widget) => widget.value),
            (value) => value == true,
          )
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereWidgetProp(
            widgetProp('isChecked', (widget) => widget.value),
            (value) => value == false,
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

    testWidgets('whereElementProp', (widgetTester) async {
      final isChecked =
          elementProp('isChecked', (e) => (e.widget as Checkbox).value);
      await widgetTester.pumpWidget(checkedCheckbox);
      checkbox
          .whereElementProp(isChecked, (checked) => checked == true)
          .existsOnce();
      await widgetTester.pumpWidget(uncheckedCheckbox);
      checkbox
          .whereElementProp(isChecked, (checked) => checked == false)
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
      await widgetTester.pumpWidget(undecidedCheckbox);
      checkbox.existsOnce().hasCheckedValueWhere((it) => it.isNull());
    });

    testWidgets('hasWidgetProp prints error to timeline', (widgetTester) async {
      await widgetTester.pumpWidget(checkedCheckbox);

      checkbox.existsOnce().hasWidgetProp(
            prop: widgetProp('value', (widget) => widget.value),
            match: (value) => value.isTrue(),
          );

      final successEvent = timeline.events.last;
      expect(successEvent.eventType.label, 'Assertion');
      expect(
        successEvent.details,
        contains("Expected: Checkbox with prop 'value' that: is true"),
      );

      expect(
        () => checkbox.existsOnce().hasWidgetProp(
              prop: widgetProp('value', (widget) => widget.value),
              match: (value) => value.isFalse(),
            ),
        throwsA(isA<PropertyCheckFailure>()),
      );
      final failureEvent = timeline.events.last;
      expect(failureEvent.eventType.label, 'PropertyCheckFailure');
      expect(failureEvent.eventType.color, Colors.red);
      expect(
        failureEvent.details,
        "Failed to match widget: Checkbox with prop 'value' that: is false, actual: <true>",
      );
    });
  });
}

extension on WidgetMatcher<Checkbox> {
  WidgetMatcher<Checkbox> hasCheckedValue(bool? checked) {
    return hasWidgetProp(
      prop: widgetProp('value', (w) => w.value),
      match: (it) => it.revealNullability().equals(checked),
    );
  }

  WidgetMatcher<Checkbox> hasCheckedValueWhere(MatchProp<bool> match) {
    return hasWidgetProp(
      prop: widgetProp('value', (w) => w.value),
      match: match.hideNullability(),
    );
  }
}
