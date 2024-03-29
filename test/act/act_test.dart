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
        check(e).isA<FlutterError>().has((it) => it.message, 'message')
          ..contains(
            'You must use "await" with all Future-returning test APIs.',
          )
          ..contains('The guarded method "tap" from class Act was called from')
          ..contains('act_test.dart');
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
          home: Stack(
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
      );

      final button = spot<ElevatedButton>()..existsOnce();
      await expectLater(
        () => act.tap(button),
        throwsSpotErrorContaining([
          "Widget 'ElevatedButton' is covered by 'ColoredBox'",
          "Stack(",
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
          "Widget 'ElevatedButton' is wrapped in AbsorbPointer and doesn't receive taps.",
          "AbsorbPointer is created at",
          "act_test.dart:",
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
          "Widget 'ElevatedButton' is wrapped in IgnorePointer and doesn't receive taps",
          "The IgnorePointer is located at",
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
