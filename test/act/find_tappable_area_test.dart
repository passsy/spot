import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';
import '../util/capture_console_output.dart';
import '../widgets/poke_test_widget.dart';

void main() {
  testWidgets('Widget entirely covered, finds no tappable area.',
      (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          columns: 5,
          rows: 5,
          widgetToCover: _TestButton(
            onTap: () {
              tapped = !tapped;
            },
          ),
        ),
      ),
    );
    final WidgetSelector button = spot<_TestButton>()..existsOnce();

    await expectLater(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget '_TestButton' is covered by 'ColoredBox'",
        "Stack(",
      ]),
    );

    expect(tapped, isFalse);
  });
  testWidgets('Widget partially covered, finds tappable area', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PokeTestWidget(
          columns: 5,
          rows: 5,
          pokableAtColumnIndex: 3,
          pokableAtRowIndex: 4,
          widgetToCover: _TestButton(
            onTap: () {
              tapped = !tapped;
            },
          ),
        ),
      ),
    );
    final WidgetSelector button = spot<_TestButton>()..existsOnce();

    await act.tap(button);

    expect(tapped, isTrue);
  });

  testWidgets('Warn about using and finding alternative tappable area.',
      (tester) async {
    bool tapped = false;
    final output = await captureConsoleOutput(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: PokeTestWidget(
            columns: 5,
            rows: 5,
            pokableAtColumnIndex: 4,
            pokableAtRowIndex: 4,
            widgetToCover: _TestButton(
              onTap: () {
                tapped = !tapped;
              },
            ),
          ),
        ),
      );
      final WidgetSelector button = spot<_TestButton>()..existsOnce();

      await act.tap(button);
    });

    expect(tapped, isTrue);

    final lines =
        (output.split('\n')..removeWhere((line) => line.isEmpty)).join('\n');
    expect(
      lines,
      "Warning: The '_TestButton' is partially not covered and not tappable. ~7% of the widget are still tappable, using Offset(457.0, 319.0).",
    );
  });

  testWidgets('Center of widget not tappable, finds alternative tappable area.',
      (tester) async {
    bool tapped = false;
    final output = await captureConsoleOutput(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned.fill(
                child: _TestButton(
                  onTap: () {
                    tapped = !tapped;
                  },
                ),
              ),
              Positioned.fill(
                // covers center of _TestButton,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(100, 0),
                    child: Container(
                      color: Colors.red.withOpacity(0.5),
                      width: 400,
                      height: 400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      final WidgetSelector button = spot<_TestButton>()..existsOnce();
      await act.tap(button);
    });

    expect(tapped, isTrue);
    final lines =
        (output.split('\n')..removeWhere((line) => line.isEmpty)).join('\n');
    expect(
      lines,
      contains(
        "Warning: The '_TestButton' is partially not covered and not tappable. ~67% of the widget are still tappable, using Offset(296.0, 296.0).",
      ),
    );
  });
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          'Press me',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
