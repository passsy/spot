import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

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
            child: const MacroTextTestWidget(
              age: 12,
              name: 'name',
              username: 'username',
            ),
          ),
        ),
      ),
    );

    final WidgetSelector<MacroTextTestWidget> selector =
        spot<MacroTextTestWidget>().whereAge(age: 12);
    selector.existsOnce().hasAge(age: 12);
  });
}
