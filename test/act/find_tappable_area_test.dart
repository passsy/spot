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
          child: _TestButton(
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
          child: _TestButton(
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
            child: _TestButton(
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
  testWidgets('InkWell can be tapped', (tester) async {
    int tapps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: _InkWellAboveTextButton(
              text: 'Press Me',
              onTap: () {
                tapps++;
              },
            ),
          ),
        ),
      ),
    );
    final button = spot<_InkWellAboveTextButton>()..existsOnce();
    await act.tap(button);
    await tester.pump();
    expect(tapps, 1);

    final buttonWithText = spot<_InkWellAboveTextButton>()
        .withChild(spotText('Press Me'))
      ..existsOnce();
    await act.tap(buttonWithText);
    // Fails with:
    // Widget 'Widget with text contains text "Press Me"' is covered by 'Listener' and can't be tapped.
    expect(tapps, 2);

    final text = spotText('Press Me')..existsOnce();
    await act.tap(text);
    // Fails with:
    // Widget 'Widget with text contains text "Press Me"' is covered by 'Listener' and can't be tapped.
    expect(tapps, 3);
  });
}

class _InkWellAboveTextButton extends StatelessWidget {
  const _InkWellAboveTextButton({this.onTap, required this.text});

  final void Function()? onTap;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text),
        // Ripple effect on top of the text
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
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
