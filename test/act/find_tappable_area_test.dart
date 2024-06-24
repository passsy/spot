import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';
import '../util/capture_console_output.dart';
import '../widgets/poke_test_widget.dart';

final _buttonStyle = ButtonStyle(
  minimumSize: WidgetStateProperty.all<Size>(const Size(150, 50)),
  backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
);

void main() {
  testWidgets('Widget entirely covered, finds no tappable area.',
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
            style: _buttonStyle,
            child: const Center(child: Text('Click Me')),
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
  testWidgets('Widget partially covered, finds tappable area', (tester) async {
    bool gotTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          setup: const PokeTestWidgetSetup(
            columns: 5,
            rows: 5,
            pokableAtColumnIndex: 3,
            pokableAtRowIndex: 4,
          ),
          child: ElevatedButton(
            onPressed: () {
              gotTapped = !gotTapped;
            },
            style: _buttonStyle,
            child: const Center(
              child: Text('Click me!'),
            ),
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

  testWidgets('Warn about using and finding alternative tappable area.',
      (tester) async {
    bool gotTapped = false;

    final outPut = await captureConsoleOutput(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: PokeTestWidget(
            setup: const PokeTestWidgetSetup(
              columns: 5,
              rows: 5,
              pokableAtColumnIndex: 3,
              pokableAtRowIndex: 4,
            ),
            child: ElevatedButton(
              onPressed: () {
                gotTapped = !gotTapped;
              },
              style: _buttonStyle,
              child: const Center(
                child: Text('Click me!'),
              ),
            ),
          ),
        ),
      );
      // Allow MeasureSize in PokeTestWidget calculate the cover
      await tester.pump();
      final WidgetSelector button = spot<ElevatedButton>()..existsOnce();
      await act.tap(button);
    });
    expect(gotTapped, isTrue);
    final lines = outPut.split('\n')..removeWhere((line) => line.isEmpty);

    final warning = _replaceOffsetWithDxDy(lines.first);
    expect(
      warning,
      "WARNING: Hit test at the center of ElevatedButton, located at Offset(dx,dy), failed. Attempting to identify and use an interactable area within the boundaries of ElevatedButton.",
    );
    final success = _replaceOffsetWithDxDy(lines.last);
    expect(
      success,
      "Found interactable area of ElevatedButton at Offset(dx,dy).",
    );
  });
}

String _replaceOffsetWithDxDy(String originalString) {
  final RegExp offsetPattern = RegExp(r'Offset\([^)]*\)');
  return originalString.replaceAll(offsetPattern, 'Offset(dx,dy)');
}
