import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';
import '../util/capture_console_output.dart';
import '../widgets/poke_test_widget.dart';

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
          widgetToCover: _TestButton(
            onTap: () {
              gotTapped = !gotTapped;
            },
          ),
        ),
      ),
    );
    // Allow MeasureSize in PokeTestWidget calculate the cover
    await tester.pump();
    final WidgetSelector button = spot<_TestButton>()..existsOnce();

    await expectLater(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget '_TestButton' is covered by 'ColoredBox'",
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
          widgetToCover: _TestButton(
            onTap: () {
              gotTapped = !gotTapped;
            },
          ),
        ),
      ),
    );
    // Allow MeasureSize in PokeTestWidget calculate the cover
    await tester.pump();
    final WidgetSelector button = spot<_TestButton>()..existsOnce();
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
            widgetToCover: _TestButton(
              onTap: () {
                gotTapped = !gotTapped;
              },
            ),
          ),
        ),
      );
      // Allow MeasureSize in PokeTestWidget calculate the cover
      await tester.pump();
      final WidgetSelector button = spot<_TestButton>()..existsOnce();
      await act.tap(button);
    });
    expect(gotTapped, isTrue);
    final lines = outPut.split('\n')..removeWhere((line) => line.isEmpty);

    final warning = _replaceOffsetWithDxDy(lines.first);
    expect(
      warning,
      "WARNING: Hit test at the center of _TestButton, located at Offset(dx,dy), failed. Attempting to identify and use an interactable area within the boundaries of _TestButton.",
    );
    final success = _replaceOffsetWithDxDy(lines.last);
    expect(
      success,
      "Found interactable area of _TestButton at Offset(dx,dy).",
    );
  });
}

String _replaceOffsetWithDxDy(String originalString) {
  final RegExp offsetPattern = RegExp(r'Offset\([^)]*\)');
  return originalString.replaceAll(offsetPattern, 'Offset(dx,dy)');
}

class _TestButton extends StatelessWidget {
  const _TestButton({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Press Me'),
      ),
    );
  }
}
