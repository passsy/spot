import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import 'macros_test_widgets.dart';

void main() {
  testWidgets('macro text test', (tester) async {
    int i = 0;
    void onPressed() => i++;

    void printTest() => print('printed');

    void Function(bool) printOnTrue = (value) => print(value);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child:  MacroTextTestWidget(
              age: 12,
              color: Colors.red,
              name: 'name',
              username: 'username',
              onPressed: printTest,
              onLongPressed: printOnTrue, testEnum: TestEnum.test1,
            ),
          ),
        ),
      ),
    );
    // final WidgetSelector<MacroTextTestWidget> selector =
    //     spot<MacroTextTestWidget>().whereAge(12);
    // selector.existsOnce().hasAge(12);
    // selector.existsOnce().hasSecondEnum(null);
    // selector.whereSecondEnum(null).existsOnce();
    // selector.existsOnce().hasOnPressed(printTest);
    // selector.existsOnce().hasOnLongPressed(printOnTrue);
  });
}
