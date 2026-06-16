import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  // Runs the tests as executed with `flutter test`
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding);
  group('AutomatedTestWidgetsFlutterBinding', actTests);
}

/// All tests for [act]
void actTests() {
  group('tap', () {
    testWidgets('tap', (tester) async {
      int i = 0;
      void onPressed() => i++;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(
              onPressed: onPressed,
              child: null,
            ),
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();

      expect(i, 0);
      await act.tap(button);
      expect(i, 1);
      await act.tap(button);
      expect(i, 2);
    });

    testWidgets('tap pumps a new frame', (tester) async {
      await tester.pumpWidget(const ColorToggleApp());

      final app = spot<MaterialApp>();
      app.existsOnce().hasWidgetProp(
            prop: widgetProp('color', (w) => w.color),
            match: (it) => it.equals(Colors.blue),
          );
      final button = spot<ElevatedButton>();

      await act.tap(button);
      // without the automatic pump() inside tap(), the color would not have change
      app.existsOnce().hasWidgetProp(
            prop: widgetProp('color', (w) => w.color),
            match: (it) => it.equals(Colors.red),
          );
    });

    testWidgets('tap must be awaited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Home'),
            ),
          ),
        ),
      );
      final future = act.tap(spot<ElevatedButton>());

      try {
        TestAsyncUtils.guardSync();
        fail('Expected to throw');
      } catch (e) {
        if (kIsWeb) {
          check(e).isA<FlutterError>().has((it) => it.message, 'message')
            ..contains(
              'Guarded function conflict.',
            )
            ..contains(
              'You must use "await" with all Future-returning test APIs.',
            );
        } else {
          check(e).isA<FlutterError>().has((it) => it.message, 'message')
            ..contains(
              'You must use "await" with all Future-returning test APIs.',
            )
            ..contains(
              'The guarded method "tap" from class Act was called from',
            )
            ..contains('act_test.dart');
        }
      }
      await future;
    });

    testWidgets('tap throws if widget not in widget tree', (tester) async {
      await tester.pumpWidget(const MaterialApp());
      final button = spot<ElevatedButton>()..doesNotExist();

      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Could not find ElevatedButton in widget tree",
        ]),
      );
    });

    testWidgets('tap throws when selector matches multiple widgets',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: null,
              ),
              ElevatedButton(
                onPressed: () {},
                child: null,
              ),
            ],
          ),
        ),
      );
      final button = spot<ElevatedButton>()..existsExactlyNTimes(2);
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Found 2 elements matching ElevatedButton in widget tree",
        ]),
      );
    });

    testWidgets('tap throws if widget not in viewport', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned(
                top: -1000,
                child: ElevatedButton(
                  onPressed: () {},
                  child: null,
                ),
              ),
            ],
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();

      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget 'ElevatedButton' is located outside the viewport",
          "-1000",
        ]),
      );
    });

    testWidgets('tap throws if widget is obstructed by another widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: null,
                  ),
                ),
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget 'ElevatedButton' can not be interacted with directly, because another widget (ColoredBox) inside Padding is completely covering it and consumes all pointer events.",
          "ColoredBox", // cover
          "ElevatedButton", // target
          if (kIsWeb) "Stack (org-dartlang-app" else "Stack (file:/",
          if (kIsWeb) "Padding (org-dartlang-app" else "Padding (file:/",
        ]),
      );
    });

    testWidgets('tap throws when widget is wrapped in AbsorbPointer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AbsorbPointer(
              child: ElevatedButton(
                onPressed: () {},
                child: null,
              ),
            ),
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget 'ElevatedButton' is wrapped in AbsorbPointer and doesn't receive pointer events.",
          "AbsorbPointer is created at",
          if (!kIsWeb) "act_test.dart:",
          "The closest widget reacting to the touch event is:",
          "Center(",
        ]),
      );
    });

    testWidgets('tap throws when widget is wrapped in IgnorePointer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IgnorePointer(
              child: ElevatedButton(
                onPressed: () {},
                child: null,
              ),
            ),
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget 'ElevatedButton' is wrapped in IgnorePointer and doesn't receive pointer events",
          "The IgnorePointer is located at",
          "act_test.dart:",
        ]),
      );
    });

    group('Visibility', () {
      testWidgets(
          'tap throws when widget is hidden with Visibility (not found)',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: Visibility(
                visible: false,
                child: ElevatedButton(
                  onPressed: () {},
                  child: null,
                ),
              ),
            ),
          ),
        );

        final button = spot<ElevatedButton>()..doesNotExist();
        await expectLater(
          () => act.tap(button),
          throwsSpotErrorContaining([
            "Could not find ElevatedButton in widget tree",
          ]),
        );
      });

      testWidgets('tap throws when Visibility is not interactive',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: Visibility(
                visible: false,
                // ignore: avoid_redundant_argument_values
                maintainInteractivity: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainSemantics: true,
                maintainState: true,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Click me'),
                ),
              ),
            ),
          ),
        );

        final button = spot<ElevatedButton>()..existsOnce();
        await expectLater(
          () => act.tap(button),
          throwsSpotErrorContaining([
            "Widget 'ElevatedButton' is wrapped in IgnorePointer and doesn't receive pointer events",
            "The IgnorePointer is located at",
            // On Flutter master, Visibility is implemented via IndexedStack,
            // so the IgnorePointer's debugWidgetLocation points to
            // indexed_stack.dart instead of visibility.dart.
            RegExp(r'widgets/(visibility|indexed_stack)\.dart:'),
          ]),
        );
      });

      testWidgets('Visibility allows tapping on hidden widgets',
          (tester) async {
        int tapped = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: Visibility.maintain(
                visible: false,
                child: ElevatedButton(
                  onPressed: () {
                    tapped++;
                  },
                  child: const Text('Click me'),
                ),
              ),
            ),
          ),
        );

        final button = spot<ElevatedButton>()..existsOnce();
        await act.tap(button);
        expect(tapped, 1);
      });
    });

    testWidgets('tap throws when widget is wrapped in SizedBox.shrink',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.shrink(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Click me'),
                ),
              ),
            ),
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "ElevatedButton can't be interacted with because it has size Size(0.0, 0.0).",
          "SizedBox.shrink forces ElevatedButton to have the size Size(0.0, 0.0)",
          "act_test.dart:",
        ]),
      );
    });

    testWidgets('tapping throws for non cartesian widgets', (tester) async {
      await tester.pumpWidget(_NonCartesianWidget());
      final button = spot<_NonCartesianWidget>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget '_NonCartesianWidget' is associated to _CustomRenderObject",
          "which is not a RenderObject",
          "RenderBox",
        ]),
      );
    });

    testWidgets('tapping throws for widgets without a RenderObject',
        (tester) async {
      await tester.pumpWidget(_NoRenderObjectWidget());
      final button = spot<_NoRenderObjectWidget>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget '_NoRenderObjectWidget' has no associated RenderObject",
        ]),
      );
    });
  });

  group('tapAt', () {
    testWidgets('tapAt', (tester) async {
      Offset? tapPosition;
      await tester.pumpWidget(
        MaterialApp(
          home: GestureDetector(
            onTapDown: (details) => tapPosition = details.globalPosition,
            child: const ColoredBox(color: Colors.blue),
          ),
        ),
      );
      await act.tapAt(const Offset(100, 100));
      expect(tapPosition, const Offset(100, 100));
    });

    testWidgets('tapAt pumps a new frame', (tester) async {
      await tester.pumpWidget(const ColorToggleApp());

      final app = spot<MaterialApp>();
      app.existsOnce().hasWidgetProp(
            prop: widgetProp('color', (w) => w.color),
            match: (it) => it.equals(Colors.blue),
          );
      final button = spot<ElevatedButton>();

      // Get the RenderBox of the button
      final renderBox = button.snapshotRenderBox();

      // Calculate the center of the button
      final center = renderBox.localToGlobal(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2),
      );
      await act.tapAt(center);
      app.existsOnce().hasWidgetProp(
            prop: widgetProp('color', (w) => w.color),
            match: (it) => it.equals(Colors.red),
          );
    });

    testWidgets('tapAt must be awaited', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Home'),
            ),
          ),
        ),
      );
      final future = act.tapAt(Offset.zero);

      try {
        TestAsyncUtils.guardSync();
        fail('Expected to throw');
      } catch (e) {
        if (kIsWeb) {
        } else {
          if (kIsWeb) {
            check(e).isA<FlutterError>().has((it) => it.message, 'message')
              ..contains(
                'Guarded function conflict.',
              )
              ..contains(
                'You must use "await" with all Future-returning test APIs.',
              );
          } else {
            check(e).isA<FlutterError>().has((it) => it.message, 'message')
              ..contains(
                'You must use "await" with all Future-returning test APIs.',
              )
              ..contains(
                'The guarded method "tapAt" from class Act was called from',
              )
              ..contains('act_test.dart');
          }
        }
      }
      await future;
    });
    testWidgets('tapAt shows items in the timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.blue, key: ValueKey(1)),
              ColoredBox(color: Colors.red, key: ValueKey(2)),
              ColoredBox(color: Colors.green, key: ValueKey(3)),
            ],
          ),
        ),
      );
      // tap
      await act.tapAt(const Offset(100, 100));
      final event = timeline.events.last;
      expect(event.eventType.label, 'TapAt Event');
      expect(
        event.details,
        stringContainsInOrder([
          'Relevant widgets at position: ',
          'ColoredBox-[<3>]',
          'Stack',
          'Widgets at position:',
          'ColoredBox-[<3>]',
          'Stack',
          '_Theater',
        ]),
      );
      expect(event.details, isNot(contains('ColoredBox-[<1>]')));
      expect(event.details, isNot(contains('ColoredBox-[<2>]')));
    });

    testWidgets('tapAt throws if position not in view (lower bounds)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp());
      await expectLater(
        () => act.tapAt(const Offset(-100, -100)),
        throwsSpotErrorContaining([
          "Point of interaction (${-100.0}, ${-100.0}) is outside the viewport (${800.0}, ${600.0}).",
          "Humans can not interact with this point.",
        ]),
      );
    });
    testWidgets('tapAt throws if position not in view (upper bounds)',
        (tester) async {
      await tester.pumpWidget(const MaterialApp());

      // ignore: deprecated_member_use
      final viewSize = tester.binding.renderView.size;
      final outOutside = viewSize.bottomRight(const Offset(100, 100));
      await expectLater(
        () => act.tapAt(outOutside),
        throwsSpotErrorContaining([
          "Point of interaction (${outOutside.dx}, ${outOutside.dy}) is outside the viewport (${800.0}, ${600.0}).",
          "Humans can not interact with this point.",
        ]),
      );
    });
  });

  group('enter text', () {
    testWidgets('enter text in text form field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Material(child: Form(child: TextFormField()))),
      );
      await act.enterText(spot<TextFormField>(), 'hello');
      spotText('hello').existsOnce();
    });

    testWidgets('enter text in text field', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Material(child: TextField())));
      await act.enterText(spot<TextField>(), 'hello');
      spotText('hello').existsOnce();
    });

    testWidgets('spot a non existing widget throws an error', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Text("any text"),
        ),
      );
      await expectLater(
        () => act.enterText(spot<TextField>(), 'hello'),
        throwsSpotErrorContaining([
          "Could not find TextField in widget tree",
        ]),
      );
    });

    testWidgets('spot a non editable text throws an error', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Text("any text"),
        ),
      );
      await expectLater(
        () => act.enterText(spot<Text>(), 'hello'),
        throwsSpotErrorContaining([
          "Widget 'Text' is not a descendant of EditableText.",
        ]),
      );
    });
  });

  group('enter text into an unreachable field', () {
    // By default enterText taps the field first, which goes through hit testing
    // and fails because the field is completely covered by the (fake) on-screen
    // keyboard - exactly as it should in a real app.
    testWidgets('enterText throws when the field is covered', (tester) async {
      await tester.pumpWidget(const _KeyboardCoveredTextFieldApp());

      await expectLater(
        () => act.enterText(spot<TextField>(), 'hello'),
        throwsSpotErrorContaining([
          'can not be interacted with directly',
          'ColoredBox', // the fake keyboard covering the field
          'completely covering it',
        ]),
      );

      // Nothing was entered because the tap never reached the field.
      spotText('hello').doesNotExist();
    });

    // bypassHitTest: true reaches into the widget tree and force-focuses the
    // field, filling it even though a real user could never reach it. This is
    // the explicit escape hatch for seeding state.
    testWidgets('enterText with bypassHitTest fills a covered field',
        (tester) async {
      await tester.pumpWidget(const _KeyboardCoveredTextFieldApp());

      await act.enterText(spot<TextField>(), 'hello', bypassHitTest: true);
      spotText('hello').existsOnce();
    });

    // A real user does not always tap to focus a field - it can be focused via
    // the keyboard or autofocus. When the field is already focused, enterText
    // types into it without tapping, so it succeeds even though the field is
    // covered and could not be tapped.
    testWidgets('enters text into an already-focused field without tapping',
        (tester) async {
      await tester.pumpWidget(
        const _KeyboardCoveredTextFieldApp(autofocus: true),
      );
      // Let autofocus take effect.
      await tester.pump();

      await act.enterText(spot<TextField>(), 'hello');
      spotText('hello').existsOnce();
    });
  });

  group('enter text into a disabled field', () {
    // A disabled TextField builds a read-only EditableText, which can never
    // receive input. Both paths throw a dedicated error rather than silently
    // doing nothing.
    for (final bypassHitTest in [false, true]) {
      testWidgets(
        'throws a dedicated error on a disabled field '
        '(bypassHitTest: $bypassHitTest)',
        (tester) async {
          final controller = TextEditingController(text: 'original');
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: TextField(controller: controller, enabled: false),
              ),
            ),
          );

          await expectLater(
            () => act.enterText(
              spot<TextField>(),
              'new',
              bypassHitTest: bypassHitTest,
            ),
            throwsSpotErrorContaining([
              'is read-only and can not receive text input',
              'TextEditingController',
            ]),
          );
          expect(controller.text, 'original');
        },
      );
    }
  });
}

class ColorToggleApp extends StatefulWidget {
  const ColorToggleApp({super.key});

  @override
  State<ColorToggleApp> createState() => _ColorToggleAppState();
}

class _ColorToggleAppState extends State<ColorToggleApp> {
  bool _red = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: _red ? Colors.red : Colors.blue,
      home: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _red = !_red;
            });
          },
          child: null,
        ),
      ),
    );
  }
}

/// A text field that is completely hidden behind a fake on-screen keyboard.
///
/// The [ColoredBox] fills the whole screen and consumes all pointer events, so
/// the [TextField] underneath can never be tapped by a real user - but its
/// controller can still be filled directly via [Act.enterText].
class _KeyboardCoveredTextFieldApp extends StatelessWidget {
  const _KeyboardCoveredTextFieldApp({this.autofocus = false});

  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 200,
                  child: TextField(autofocus: autofocus),
                ),
              ),
            ),
            // Fake on-screen keyboard covering the entire screen, including the
            // text field above.
            const Positioned.fill(
              child: ColoredBox(color: Color(0xFF00FF00)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NonCartesianWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  _StatelessElementWithoutRenderObject createElement() {
    return _StatelessElementWithoutRenderObject(this);
  }
}

class _StatelessElementWithoutRenderObject extends StatelessElement {
  _StatelessElementWithoutRenderObject(super.widget);

  @override
  RenderObject? get renderObject => _CustomRenderObject();
}

class _CustomRenderObject extends RenderObject {
  @override
  void performLayout() {}

  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  Rect get paintBounds => Rect.zero;

  @override
  void performResize() {}

  @override
  Rect get semanticBounds => Rect.zero;
}

class _NoRenderObjectWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  _NoRenderObjectElement createElement() {
    return _NoRenderObjectElement(this);
  }
}

class _NoRenderObjectElement extends StatelessElement {
  _NoRenderObjectElement(super.widget);

  @override
  RenderObject? get renderObject => null;
}
