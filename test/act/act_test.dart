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

    final button = spotSingle<ElevatedButton>()..existsOnce();

    expect(i, 0);
    await act.tap(button);
    expect(i, 1);
    await act.tap(button);
    expect(i, 2);
  });

  testWidgets('tap throws if widget not in widget tree', (tester) async {
    await tester.pumpWidget(const MaterialApp());
    final button = spotSingle<ElevatedButton>()..doesNotExist();

    await expectLater(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Could not find 'ElevatedButton' in widget tree",
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

    final button = spotSingle<ElevatedButton>()..existsOnce();

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

    final button = spotSingle<ElevatedButton>()..existsOnce();
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

    final button = spotSingle<ElevatedButton>()..existsOnce();
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

    final button = spotSingle<ElevatedButton>()..existsOnce();
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
    final button = spotSingle<_NonCartesianWidget>()..existsOnce();
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
    final button = spotSingle<_NoRenderObjectWidget>()..existsOnce();
    await expectLater(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget '_NoRenderObjectWidget' has no associated RenderObject",
      ]),
    );
  });
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
