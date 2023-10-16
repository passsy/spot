// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('match custom property', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Checkbox(
            value: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final checkbox = spotSingle<Checkbox>();

    checkbox
        .existsOnce()
        .hasProp(
          elementSelector: (e) => e.context.nest(
            () => ['Checkbox', 'value'],
            (e) => Extracted.value((e.widget as Checkbox).value),
          ),
          match: (it) => it.equals(true),
        )
        .hasProp(
          widgetSelector: (widget) => widget.context.nest(
            () => ['value'],
            (widget) => Extracted.value(widget.value),
          ),
          match: (it) => it.equals(true),
        )
        .hasElementProp(
          name: 'value',
          prop: (it) => (it.widget as Checkbox).value,
          match: (it) => it.equals(true),
        )
        .hasWidgetProp(
          name: 'value',
          prop: (it) => it.value,
          match: (it) => it.equals(false),
        );
    //     .hasProp(
    //   prop: ('value', (it) => it.value),
    //   match: (it) => it.equals(false),
    // );
  });
}
