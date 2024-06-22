import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../widgets/poke_test_widget.dart';

void main() {
  testWidgets('Partially covered, finds tappable area', (tester) async {
    bool gotTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          setup: const PokeTestSetup(
            columns: 5,
            rows: 5,
            pokableAtColumnIndex: 3,
            pokableAtRowIndex: 2,
          ),
          child: ElevatedButton(
            onPressed: () {
              gotTapped = !gotTapped;
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all<Size>(const Size(150, 50)),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            child: const Text('Click Me'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final WidgetSelector button = spot<ElevatedButton>()..existsOnce();
    await takeScreenshot();
    await act.tap(button);
    // expect(gotTapped, isTrue);
    await takeScreenshot();
  });
}
