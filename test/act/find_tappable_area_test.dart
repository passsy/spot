import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';
import '../widgets/poke_test_widget.dart';

void main() {
  testWidgets('Poke test widget throws without defined tappable spots',
      (tester) async {
    bool gotTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          setup: const PokeTestWidgetSetup(
            columns: 5,
            rows: 5,
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
    // Allow MeasureSize in PokeTestWidget calculate the cover
    await tester.pump();
    final WidgetSelector button = spot<ElevatedButton>()..existsOnce();

    await expectLater(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget 'ElevatedButton' is covered by 'ColoredBox'",
        "Stack(",
      ]),
    );
    expect(gotTapped, isFalse);
  });
  testWidgets('Partially covered, finds tappable area', (tester) async {
    bool gotTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          setup: const PokeTestWidgetSetup(
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
    // Allow MeasureSize in PokeTestWidget calculate the cover
    await tester.pump();
    final WidgetSelector button = spot<ElevatedButton>()..existsOnce();
    await act.tap(button);
    expect(gotTapped, isTrue);
  });
}
