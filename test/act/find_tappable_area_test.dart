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
        "Selector '_TestButton' can not be tapped directly, because another widget (ColoredBox) inside Center is completely covering it and consumes all tap events.",
        "Try tapping the Center which contains '_TestButton' instead.",
        "Example:",
        "(Cover - Received tap event)",
        "(Target for tap, below Cover)",
        "Stack (file:/",
        "Center (file:/",
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
      "Warning: The '_TestButton' is partially covered.\n"
      "~7% of the widget are still tappable.\n"
      "Using Offset(457.0, 319.0).",
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
        "Warning: The '_TestButton' is partially covered.\n"
        "~67% of the widget are still tappable.\n"
        "Using Offset(296.0, 296.0).",
      ),
    );
  });
  testWidgets('Custom button with InkWell can be tapped', (tester) async {
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
    await expectLater(
      () => act.tap(text),
      throwsSpotErrorContaining([
        "Selector 'Widget with text contains text \"Press Me\"' can not be tapped directly, because another widget (Listener) inside Padding",
        "spot<ElevatedButton>().spotText('Tap me');",
        "spot<ElevatedButton>().withChild(spotText('Tap me'));",
        " │ ┌──", // diagram
        "Stack (file:/", // Link to common ancestor
        "Padding (file:/", // first useful parent in user code
      ]),
    );
  });

  testWidgets('Size(0,0) Text in NavigationRailDestination can not be tapped',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
            selectedIndex: 0,
          ),
        ),
      ),
    );
    spotIcon(Icons.search).existsOnce();
    spotText('Search').existsOnce();

    // This is interesting because the text is hidden but still in the widget tree for semantic reasons
    await expectLater(
      () => act.tap(spotText('Search')),
      throwsSpotErrorContaining([
        "RichText can't be tapped because it has size Size(0.0, 0.0)",
        "SizedBox.shrink forces RichText to have the size Size(0.0, 0.0)",
        "material/navigation_rail.dart:",
      ]),
    );
  });
}

class _InkWellAboveTextButton extends StatelessWidget {
  const _InkWellAboveTextButton({this.onTap, required this.text});

  final void Function()? onTap;

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
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
      ),
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
