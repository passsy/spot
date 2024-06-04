import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'macros_test_widgets.dart';

void main() {
  testWidgets('macro text test', (tester) async {
    int i = 0;
    void onPressed() => i++;

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
              onPressed: (){},
              onLongPressed: (value){}, testEnum: TestEnum.test1,
            ),
          ),
        ),
      ),
    );
    // final WidgetSelector<MacroTextTestWidget> selector =
    //     spot<MacroTextTestWidget>().whereAge(age: 12);
    // selector.existsOnce().hasAge(age: 12);
  });
}
