import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import 'macros_test_widgets.dart';

void main() {
  testWidgets('macro text test', (tester) async {
    int i = 0;
    void onPressed() => i++;

    void printOnPress() => debugPrint('printed');

    void printOnLongPress(bool value) => debugPrint("$value");

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child: MacroTextTestWidget(
              age: 12,
              color: Colors.red,
              name: 'name',
              username: 'username',
              onPressed: printOnPress,
              onLongPressed: printOnLongPress,
              testEnum: TestEnum.test1,
            ),
          ),
        ),
      ),
    );

    // final WidgetSelector<MacroTextTestWidget> selector =
    //     spot<MacroTextTestWidget>();
    //
    // selector.whereAge(12).existsOnce().hasAge(12);
    // selector.whereColor(Colors.red).existsOnce().hasColor(Colors.red);
    // selector.whereName('name').existsOnce().hasName('name');
    // selector
    //     .whereTestEnum(TestEnum.test1)
    //     .existsOnce()
    //     .hasTestEnum(TestEnum.test1);
    // selector.whereSecondEnum(null).existsOnce().hasSecondEnum(null);
    // selector
    //     .whereOnPressed(printOnPress)
    //     .existsOnce()
    //     .hasOnPressed(printOnPress);
    // selector
    //     .whereOnLongPressed(printOnLongPress)
    //     .existsOnce()
    //     .hasOnLongPressed(printOnLongPress);
  });
}
