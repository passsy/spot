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

    testWidgets('tap throws when the AbsorbPointer is not below the hit target',
        (tester) async {
      // The widget below the hit target is _AbsorbingButtonWrapper, the
      // AbsorbPointer sits one level further down. Detection has to walk up
      // from the target, walking down from the hit target finds nothing.
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: _AbsorbingButtonWrapper(),
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

    testWidgets('tap throws a TapFailure that carries the inspection',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ),
              const Positioned.fill(
                child: ColoredBox(color: Colors.green),
              ),
            ],
          ),
        ),
      );

      final button = spot<ElevatedButton>()..existsOnce();

      await expectLater(
        () => act.tap(button),
        throwsA(
          isA<TapFailure>()
              .having((it) => it.inspection.canTap, 'canTap', isFalse)
              .having(
                (it) => it.inspection.tapFailure?.reason,
                'reason',
                isA<TapCoveredReason>().having(
                  (it) => it.primaryCover?.widget,
                  'primaryCover',
                  isA<ColoredBox>(),
                ),
              )
              .having(
                (it) => it.message,
                'message',
                contains('can not be interacted with directly'),
              ),
        ),
      );

      // Still a TestFailure, so the test runner reports a failed assertion
      // instead of a crashed test, and existing expectations keep matching.
      await expectLater(() => act.tap(button), throwsA(isA<TestFailure>()));
    });

    testWidgets('tap throws a TapFailure for a widget outside the viewport',
        (tester) async {
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
        throwsA(
          isA<TapFailure>().having(
            (it) => it.inspection.tapFailure?.reason,
            'reason',
            isA<TapOutsideViewportReason>(),
          ),
        ),
      );
    });
  });

  // Every reason [act.inspectTap] can report gets one test here, written the
  // way an external consumer would assert "this widget is not tappable because
  // of X". Each test checks the whole [TapInspection] envelope plus every
  // property of the reason it carries.
  group('inspectTap', () {
    testWidgets('reports a tappable widget with sampled hit tests',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Save'),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());

      expect(inspection.canTap, isTrue);
      expect(inspection.selectorDescription, 'ElevatedButton');
      expect(inspection.tapFailure, isNull);
      expect(inspection.message, isNull);

      final target = inspection.target!;
      expect(target.widget, isA<ElevatedButton>());
      expect(target.element.widget, same(target.widget));
      expect(target.widgetName, 'ElevatedButton');
      expect(target.renderObject, isA<RenderBox>());
      expect(target.globalRect, isNotNull);
      if (!kIsWeb) {
        expect(target.sourceLocation, contains('act_test.dart:'));
        expect(target.isUserCode, isTrue);
      }

      final samples = inspection.samples!;
      expect(samples.searchArea, target.globalRect);
      expect(samples.hittable, isNotEmpty);
      expect(samples.blocked, isEmpty);
      expect(samples.hittablePercent, 100);
      expect(samples.blockers, isEmpty);
      expect(inspection.tapPosition, isNotNull);
      expect(target.globalRect!.contains(inspection.tapPosition!), isTrue);

      final sample = samples.hittable.first;
      expect(sample.hitsTarget, isTrue);
      expect(
        sample.globalPosition,
        target.globalRect!.topLeft + sample.localPosition,
      );
      expect(sample.hitTest.position, sample.globalPosition);
      expect(sample.hitTest.path, isNotEmpty);
      expect(sample.hitTest.receiver, same(sample.hitTest.path.first));
    });

    testWidgets('warns about partial coverage but stays tappable',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: const SizedBox.expand(),
                  ),
                  const Positioned(
                    left: 50,
                    top: 0,
                    bottom: 0,
                    width: 50,
                    child: ColoredBox(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<GestureDetector>());

      expect(inspection.canTap, isTrue);
      expect(inspection.tapFailure, isNull);
      expect(inspection.message, isNull);
      expect(inspection.tapPosition, isNotNull);

      // Tappable, but not everywhere. The limitation is in the samples.
      final samples = inspection.samples!;
      expect(samples.hittablePercent, closeTo(54, 1));
      expect(samples.hittable, isNotEmpty);
      expect(samples.blocked, isNotEmpty);
      expect(samples.hittable.map((it) => it.globalPosition), isNotEmpty);
      expect(samples.blocked.map((it) => it.globalPosition), isNotEmpty);
      expect(samples.hittablePercent, greaterThan(0));
      expect(samples.hittablePercent, lessThan(100));

      // Names what is in the way and how much of the target it takes, without
      // the caller having to group 169 samples by hit-test receiver.
      expect(samples.blockers, hasLength(1));
      final blocker = samples.blockers.single;
      expect(blocker.receiver.widget, isA<ColoredBox>());
      expect(blocker.sampleCount, samples.blocked.length);
      expect(blocker.percent, closeTo(46, 1));
      expect(blocker.toString(), 'ColoredBox (46%)');
      expect(samples.blocked.first.blockedBy, isNotNull);
      expect(samples.hittable.first.blockedBy, isNull);

      // The right half is covered, so every reachable point is on the left.
      expect(
        samples.hittable
            .map((it) => it.globalPosition)
            .every((it) => it.dx < samples.searchArea.center.dx),
        isTrue,
      );
      expect(
        inspection.tapPosition!.dx,
        lessThan(samples.searchArea.center.dx),
      );
    });

    testWidgets('reports a not-found reason when nothing matches',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('Save')));

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapNotFoundReason;

      expect(inspection.canTap, isFalse);
      expect(inspection.selectorDescription, 'ElevatedButton');
      expect(
        inspection.tapFailure!.toString(),
        'TapNotFoundReason: Could not find ElevatedButton in widget tree',
      );
      expect(
        inspection.message,
        'Could not find ElevatedButton in widget tree',
      );
      // Nothing was found, so there is nothing to describe or search.
      expect(inspection.target, isNull);
      expect(inspection.samples, isNull);
      expect(inspection.tapPosition, isNull);

      expect(reason.selectorDescription, inspection.selectorDescription);
    });

    testWidgets(
        'reports a multiple-widgets reason when the selector is ambiguous',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('first'),
              Text('second'),
            ],
          ),
        ),
      );

      final inspection = act.inspectTap(spot<Text>());
      final reason = inspection.tapFailure!.tapMultipleWidgetsFoundReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        'Found 2 elements matching Text in widget tree',
      );
      expect(inspection.target, isNull);
      expect(inspection.samples, isNull);
      expect(inspection.tapPosition, isNull);

      expect(reason.selectorDescription, 'Text');
      expect(reason.matches, hasLength(2));
      expect(
        reason.matches.map((it) => (it.widget as Text).data),
        ['first', 'second'],
      );
      expect(reason.matches.every((it) => it.globalRect != null), isTrue);
    });

    testWidgets('reports a no-render-object reason', (tester) async {
      await tester.pumpWidget(_NoRenderObjectWidget());

      final inspection = act.inspectTap(spot<_NoRenderObjectWidget>());

      expect(inspection.canTap, isFalse);
      expect(inspection.tapFailure!.reason, isA<TapNoRenderObjectReason>());
      expect(
        inspection.tapFailure!.tapNoRenderObjectReason,
        same(inspection.tapFailure!.reason),
      );
      expect(
        inspection.message,
        contains(
          "Widget '_NoRenderObjectWidget' has no associated RenderObject",
        ),
      );
      expect(inspection.samples, isNull);
      expect(inspection.tapPosition, isNull);

      // The widget itself is known, only its render object is missing.
      final target = inspection.target!;
      expect(target.widget, isA<_NoRenderObjectWidget>());
      expect(target.renderObject, isNull);
      expect(target.globalRect, isNull);
    });

    testWidgets('reports a non-render-box reason', (tester) async {
      await tester.pumpWidget(_NonCartesianWidget());

      final inspection = act.inspectTap(spot<_NonCartesianWidget>());
      final reason = inspection.tapFailure!.tapNonRenderBoxReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains('is not a RenderObject in the 2D Cartesian coordinate system'),
      );
      expect(inspection.samples, isNull);
      expect(inspection.tapPosition, isNull);

      final target = inspection.target!;
      expect(target.widget, isA<_NonCartesianWidget>());
      // A RenderObject exists, it is just not positionable in 2D.
      expect(target.renderObject, isNotNull);
      expect(target.renderObject, isNot(isA<RenderBox>()));
      expect(target.globalRect, isNull);

      expect(reason.renderObject, isA<_CustomRenderObject>());
      expect(reason.renderObject, isNot(isA<RenderBox>()));
    });

    testWidgets('reports an outside-viewport reason', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 1000,
                top: 20,
                width: 50,
                height: 30,
                child: GestureDetector(
                  onTap: () {},
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      );

      final inspection = act.inspectTap(spot<GestureDetector>());
      final reason = inspection.tapFailure!.tapOutsideViewportReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        "Widget 'GestureDetector' is located outside the viewport "
        '(Rect.fromLTRB(1000.0, 20.0, 1050.0, 50.0)).',
      );
      // Sampling is skipped, nothing inside the viewport could be hit.
      expect(inspection.samples, isNull);
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.widget, isA<GestureDetector>());

      expect(reason.viewport, const Rect.fromLTRB(0, 0, 800, 600));
      expect(reason.targetRect, const Rect.fromLTRB(1000, 20, 1050, 50));
      expect(reason.targetRect, inspection.target?.globalRect);
      // Derived from the intersection, not hardcoded. Empty here because the
      // target is fully off-screen.
      expect(reason.visibleRect, Rect.zero);
      expect(reason.visibleFraction, 0);
    });

    testWidgets('reports an absorbed reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AbsorbPointer(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapAbsorbedReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains(
          "Widget 'ElevatedButton' is wrapped in AbsorbPointer and doesn't "
          'receive pointer events.',
        ),
      );
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.widget, isA<ElevatedButton>());
      // Sampling ran and found no hittable point, that is why the inspection
      // looked for a cause in the first place.
      expect(inspection.samples?.hittable, isEmpty);

      expect(reason.absorbPointer.widget, isA<AbsorbPointer>());
      expect(reason.absorbPointer.globalRect, inspection.target?.globalRect);
      if (!kIsWeb) {
        expect(reason.absorbPointer.sourceLocation, contains('act_test.dart:'));
      }
      // The AbsorbPointer swallows the event, something behind it answers.
      expect(reason.hitTest.receiver, isNotNull);
      expect(reason.hitTest.receiver!.widget, isNot(isA<ElevatedButton>()));
      expect(reason.hitTest.path, isNotEmpty);
      expect(reason.hitTest.receiver, same(reason.hitTest.path.first));
      expect(reason.hitTest.position, inspection.target?.globalRect?.center);
    });

    testWidgets('reports the AbsorbPointer above the target, not below the hit',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: _AbsorbingButtonWrapper(),
          ),
        ),
      );

      final absorbElement = find
          .descendant(
            of: find.byType(_AbsorbingButtonWrapper),
            matching: find.byType(AbsorbPointer),
          )
          .evaluate()
          .single;
      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapAbsorbedReason;

      expect(inspection.canTap, isFalse);
      expect(inspection.target?.widget, isA<ElevatedButton>());
      // Pins the reported widget to the AbsorbPointer itself. The message
      // renders the source location of this element, so reporting the
      // _AbsorbingButtonWrapper that created it would point at the wrong line.
      expect(reason.absorbPointer.element, same(absorbElement));
      expect(reason.absorbPointer.widget, isA<AbsorbPointer>());
      // The hit stops above the wrapper, which is why walking down from the
      // receiver cannot find the AbsorbPointer.
      expect(reason.hitTest.receiver?.widget, isNot(isA<AbsorbPointer>()));
      expect(reason.hitTest.path, isNotEmpty);
    });

    testWidgets('reports an ignored reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IgnorePointer(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapIgnoredReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains(
          "Widget 'ElevatedButton' is wrapped in IgnorePointer and doesn't "
          'receive pointer events.',
        ),
      );
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.widget, isA<ElevatedButton>());
      expect(inspection.samples?.hittable, isEmpty);

      expect(reason.ignorePointer.widget, isA<IgnorePointer>());
      expect(reason.ignorePointer.globalRect, inspection.target?.globalRect);
      if (!kIsWeb) {
        expect(reason.ignorePointer.sourceLocation, contains('act_test.dart:'));
      }
      // The IgnorePointer is written inline here, so the closest user-code
      // ancestor is the widget that wraps it.
      expect(reason.introducedBy?.widget, isA<Center>());
      expect(reason.hitTest.receiver, isNotNull);
      expect(reason.hitTest.receiver!.widget, isNot(isA<ElevatedButton>()));
      expect(reason.hitTest.path, isNotEmpty);
      expect(reason.hitTest.receiver, same(reason.hitTest.path.first));
      expect(reason.hitTest.position, inspection.target?.globalRect?.center);
    });

    testWidgets('names the widget that introduced the IgnorePointer',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: _IgnoredButtonWrapper(),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<_IgnoredButtonWrapper>());
      final reason = inspection.tapFailure!.tapIgnoredReason;

      expect(inspection.tapFailure!.reason, isA<TapIgnoredReason>());
      expect(
        () => inspection.tapFailure!.tapUnknownReason,
        throwsA(isA<TestFailure>()),
      );
      expect(reason.ignorePointer.widget, isA<IgnorePointer>());
      expect(reason.ignorePointer.globalRect, isNotNull);
      // The IgnorePointer is created inside _IgnoredButtonWrapper.build, which
      // is the widget a test author has to change to make the button tappable.
      expect(reason.introducedBy?.widget, isA<_IgnoredButtonWrapper>());
    });

    testWidgets('reports a zero-size reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.shrink(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapZeroSizeReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains(
          "ElevatedButton can't be interacted with because it has size "
          'Size(0.0, 0.0)',
        ),
      );
      expect(
        inspection.message,
        contains('SizedBox.shrink forces ElevatedButton'),
      );
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.globalRect?.size, Size.zero);

      // The outermost ancestor that is already zero-sized, changing anything
      // below it cannot give the target a size.
      expect(reason.shrinker.widget, isA<SizedBox>());
      expect(reason.shrinker.widgetName, 'SizedBox.shrink');
      expect(reason.shrinker.globalRect?.size, Size.zero);
      if (!kIsWeb) {
        expect(reason.shrinker.sourceLocation, contains('act_test.dart:'));
      }
      // Walks from the target up to, but excluding, the shrinker. Despite the
      // name the chain starts at the target itself.
      expect(
        reason.shrinkChain.map((it) => it.widgetName),
        ['ElevatedButton', 'Padding'],
      );
      expect(
        reason.shrinkChain.where((it) => it.globalRect?.size != Size.zero),
        isEmpty,
      );
    });

    testWidgets('reports a covered reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save'),
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

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapCoveredReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains('can not be interacted with directly'),
      );
      // The full diagnostics, prefixed with the reason that produced them.
      expect(
        inspection.tapFailure!.toString(),
        'TapCoveredReason: ${inspection.message!.split('\n').first}',
      );
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.widget, isA<ElevatedButton>());
      expect(inspection.samples?.hittable, isEmpty);

      // Everything from the covering widget up to the common ancestor.
      expect(
        reason.coverChain.map((it) => it.widgetName),
        ['ColoredBox', 'Positioned'],
      );
      expect(
        reason.relevantCoveringWidgets.map((it) => it.widgetName),
        ['ColoredBox', 'Positioned'],
      );
      expect(reason.primaryCover?.widget, isA<ColoredBox>());
      expect(reason.primaryCover, same(reason.relevantCoveringWidgets.first));
      // The Stack renders both branches, it is where they start to diverge.
      expect(reason.commonAncestor.widget, isA<Stack>());
      expect(reason.userRelevantAncestor?.widget, isA<MaterialApp>());
      expect(
        reason.targetChain.map((it) => it.widgetName),
        ['ElevatedButton', 'Center'],
      );
      expect(reason.hitTest.path, isNotEmpty);
      expect(reason.hitTest.receiver?.widget, isA<ColoredBox>());
      expect(reason.hitTest.position, inspection.target?.globalRect?.center);

      // The whole surface is blocked by the same widget.
      final samples = inspection.samples!;
      expect(samples.hittable.map((it) => it.globalPosition), isEmpty);
      expect(samples.blockers, hasLength(1));
      expect(samples.blockers.single.receiver.widget, isA<ColoredBox>());
      expect(samples.blockers.single.percent, 100);
    });

    testWidgets('reports an unknown reason when nothing else explains it',
        (tester) async {
      // A sized widget that neither reacts to hit tests itself nor has an
      // ancestor that does. Nothing absorbs, ignores, shrinks or covers it.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<SizedBox>());
      final reason = inspection.tapFailure!.tapUnknownReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains(
          "The exact reason, why it doesn't receive hitTest events is unknown.",
        ),
      );
      expect(inspection.message, contains('https://github.com/passsy/spot'));
      expect(inspection.tapPosition, isNull);
      expect(inspection.target?.globalRect?.size, const Size(100, 100));

      expect(reason.position, inspection.target?.globalRect?.center);
      expect(reason.hitTest.position, reason.position);
      expect(reason.hitTest.path, isNotEmpty);
      expect(reason.hitTest.receiver?.widget, isNot(isA<SizedBox>()));

      final samples = inspection.samples!;
      expect(samples.searchArea, inspection.target?.globalRect);
      expect(samples.hittable, isEmpty);
      expect(samples.blocked, isNotEmpty);
      expect(samples.hittablePercent, 0);
      // Collected once and kept, so reading twice does not hit test twice.
      expect(inspection.samples, same(samples));
    });

    testWidgets('reports the outermost IgnorePointer, not the closest one',
        (tester) async {
      // Hit testing walks root to target and RenderIgnorePointer answers
      // without visiting its child, so the outer one is what stops the event.
      // Removing the inner one changes nothing, pointing a test author at it
      // would send them to the wrong line.
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: IgnorePointer(
              key: ValueKey('outer'),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: _IgnoredButtonWrapper(),
              ),
            ),
          ),
        ),
      );

      final outer = find.byKey(const ValueKey('outer')).evaluate().single;
      final inner = find
          .descendant(
            of: find.byType(_IgnoredButtonWrapper),
            matching: find.byType(IgnorePointer),
          )
          .evaluate()
          .single;
      expect(outer, isNot(same(inner)));

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapIgnoredReason;

      expect(reason.ignorePointer.element, same(outer));
    });

    testWidgets('reports the outermost AbsorbPointer, not the closest one',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: AbsorbPointer(
              key: ValueKey('outer'),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: _AbsorbingButtonWrapper(),
              ),
            ),
          ),
        ),
      );

      final outer = find.byKey(const ValueKey('outer')).evaluate().single;

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final reason = inspection.tapFailure!.tapAbsorbedReason;

      expect(reason.absorbPointer.element, same(outer));
    });

    testWidgets('reports an offstage reason', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Offstage(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      );

      // spot() skips offstage widgets, so the default selector cannot even see
      // it. spotOffstage() is what the docs point at, and it used to land in
      // TapUnknownReason.
      expect(
        act.inspectTap(spot<ElevatedButton>()).tapFailure!.reason,
        isA<TapNotFoundReason>(),
      );

      final inspection = act.inspectTap(
        spotOffstage().spot<ElevatedButton>().atMost(1),
      );
      final reason = inspection.tapFailure!.tapOffstageReason;

      expect(inspection.canTap, isFalse);
      expect(
        inspection.message,
        contains(
          "is wrapped in Offstage, which takes it out of the layout and out of "
          'hit testing.',
        ),
      );
      expect(inspection.tapPosition, isNull);

      expect(reason.offstage.widget, isA<Offstage>());
      if (!kIsWeb) {
        expect(reason.offstage.sourceLocation, contains('act_test.dart:'));
      }
      // The Offstage is written inline here, so the closest user-code ancestor
      // is the widget that wraps it.
      expect(reason.introducedBy?.widget, isA<Center>());
      expect(reason.hitTest.path, isNotEmpty);
    });

    testWidgets('reports the Visibility that introduced the Offstage',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Visibility(
              visible: false,
              // Keeps the child in the tree, which is the branch where
              // Visibility builds an Offstage.
              maintainState: true,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(
        spotOffstage().spot<ElevatedButton>().atMost(1),
      );
      final reason = inspection.tapFailure!.tapOffstageReason;

      expect(reason.introducedBy?.widget, isA<Visibility>());
    });

    testWidgets('samples are collected on read, not up front', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(onPressed: () {}, child: const Text('Save')),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());
      expect(inspection.canTap, isTrue);

      // The inspection describes the tree of the frame it was created in.
      // Sampling now would hit test a tree it never saw, so it refuses instead
      // of reporting something that did not happen.
      await tester.pump();

      expect(
        () => inspection.samples,
        throwsSpotErrorContaining([
          'TapInspection.samples was read after a new frame was pumped.',
          'Read inspection.samples before pumping',
        ]),
      );
    });

    testWidgets('samples read before a pump stay readable afterwards',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ElevatedButton(onPressed: () {}, child: const Text('Save')),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());
      final samples = inspection.samples!;
      await tester.pump();

      // Already collected, so it is a value like every other field, not a new
      // hit test against the current tree.
      expect(inspection.samples, same(samples));
    });

    testWidgets('typed reason getters fail when the reason changes',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: IgnorePointer(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      );

      final inspection = act.inspectTap(spot<ElevatedButton>());

      expect(
        () => inspection.tapFailure!.tapCoveredReason,
        throwsSpotErrorContaining([
          'Expected TapCoveredReason but tap failed with TapIgnoredReason.',
          "Widget 'ElevatedButton' is wrapped in IgnorePointer and doesn't receive pointer events.",
        ]),
      );
    });
  });

  // [TapInspection.canTap] is documented as "whether act.tap can tap the
  // selector", but act.tap computes that itself and never asks. Two code paths
  // answering the same question, so assert they agree on every tree the tests
  // above set up. Without this both suites can stay green while they disagree.
  group('inspectTap agrees with tap', () {
    final cases = <_TapParityCase>[
      _TapParityCase(
        name: 'tappable button',
        canTap: true,
        build: () => MaterialApp(
          home: Center(child: ElevatedButton(onPressed: () {}, child: null)),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'tappable despite partial coverage',
        canTap: true,
        build: () => MaterialApp(
          home: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: const SizedBox.expand(),
                  ),
                  const Positioned(
                    left: 50,
                    top: 0,
                    bottom: 0,
                    width: 50,
                    child: ColoredBox(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
        selector: () => spot<GestureDetector>(),
      ),
      _TapParityCase(
        name: 'covered by another widget',
        canTap: false,
        build: () => MaterialApp(
          home: Stack(
            children: [
              Center(child: ElevatedButton(onPressed: () {}, child: null)),
              const Positioned.fill(child: ColoredBox(color: Colors.green)),
            ],
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'wrapped in AbsorbPointer',
        canTap: false,
        build: () => MaterialApp(
          home: Center(
            child: AbsorbPointer(
              child: ElevatedButton(onPressed: () {}, child: null),
            ),
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'AbsorbPointer created in another widget',
        canTap: false,
        build: () => const MaterialApp(
          home: Center(child: _AbsorbingButtonWrapper()),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'wrapped in IgnorePointer',
        canTap: false,
        build: () => MaterialApp(
          home: Center(
            child: IgnorePointer(
              child: ElevatedButton(onPressed: () {}, child: null),
            ),
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'forced to zero size',
        canTap: false,
        build: () => MaterialApp(
          home: Center(
            child: SizedBox.shrink(
              child: ElevatedButton(onPressed: () {}, child: null),
            ),
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'outside the viewport',
        canTap: false,
        build: () => MaterialApp(
          home: Stack(
            children: [
              Positioned(
                top: -1000,
                child: ElevatedButton(onPressed: () {}, child: null),
              ),
            ],
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'offstage',
        canTap: false,
        build: () {
          return MaterialApp(
            home: Center(
              child: Offstage(
                child: ElevatedButton(onPressed: () {}, child: null),
              ),
            ),
          );
        },
        selector: () => spotOffstage().spot<ElevatedButton>().atMost(1),
      ),
      _TapParityCase(
        name: 'no render object',
        canTap: false,
        build: _NoRenderObjectWidget.new,
        selector: () => spot<_NoRenderObjectWidget>(),
      ),
      _TapParityCase(
        name: 'not a RenderBox',
        canTap: false,
        // The fixture hands out a fresh _CustomRenderObject on every access and
        // the message names it, so the two calls can never print the same text.
        sameMessage: false,
        build: _NonCartesianWidget.new,
        selector: () => spot<_NonCartesianWidget>(),
      ),
      _TapParityCase(
        name: 'no known reason',
        canTap: false,
        build: () {
          return const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: SizedBox(width: 100, height: 100)),
          );
        },
        selector: () => spot<SizedBox>(),
      ),
      _TapParityCase(
        name: 'no match',
        canTap: false,
        build: () => const MaterialApp(home: Text('Save')),
        selector: () => spot<ElevatedButton>(),
      ),
      _TapParityCase(
        name: 'multiple matches',
        canTap: false,
        build: () => MaterialApp(
          home: Row(
            children: [
              ElevatedButton(onPressed: () {}, child: null),
              ElevatedButton(onPressed: () {}, child: null),
            ],
          ),
        ),
        selector: () => spot<ElevatedButton>(),
      ),
    ];

    for (final parityCase in cases) {
      testWidgets(parityCase.name, (tester) async {
        await tester.pumpWidget(parityCase.build());
        final selector = parityCase.selector();
        final inspection = act.inspectTap(selector);

        expect(inspection.canTap, parityCase.canTap);

        if (parityCase.canTap) {
          expect(inspection.message, isNull);
          expect(inspection.tapFailure, isNull);
          await act.tap(selector);
          return;
        }

        // act.tap fails, and says the same thing the inspection did.
        expect(inspection.message, isNotNull);
        await expectLater(
          () => act.tap(selector),
          throwsA(
            parityCase.sameMessage
                ? isA<Object>().having(
                    (it) => it.toString(),
                    'message',
                    contains(inspection.message),
                  )
                : isA<TestFailure>(),
          ),
        );
      });
    }
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
      // Record events so we can assert the unfocused field is tapped. This also
      // acts as the control for the "already-focused field is not tapped" test:
      // it proves the timeline captures taps, so the absence of the event there
      // is meaningful.
      timeline.mode = TimelineMode.reportOnError;
      await tester
          .pumpWidget(const MaterialApp(home: Material(child: TextField())));
      await act.enterText(spot<TextField>(), 'hello');
      spotText('hello').existsOnce();

      expect(
        timeline.events.where((e) => e.eventType.label == 'Tap Event'),
        isNotEmpty,
      );
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
      // Record events so we can assert that no tap happened.
      timeline.mode = TimelineMode.reportOnError;

      await tester.pumpWidget(
        const _KeyboardCoveredTextFieldApp(autofocus: true),
      );
      // Let autofocus take effect.
      await tester.pump();

      await act.enterText(spot<TextField>(), 'hello');
      spotText('hello').existsOnce();

      // The field was already focused, so enterText skipped the tap entirely -
      // no 'Tap Event' was added to the timeline.
      expect(
        timeline.events.where((e) => e.eventType.label == 'Tap Event'),
        isEmpty,
      );
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

/// Creates the [AbsorbPointer] inside [build], so the widget below the hit
/// target is this wrapper instead of the [AbsorbPointer].
class _AbsorbingButtonWrapper extends StatelessWidget {
  const _AbsorbingButtonWrapper();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Save'),
      ),
    );
  }
}

class _IgnoredButtonWrapper extends StatelessWidget {
  const _IgnoredButtonWrapper();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Save'),
      ),
    );
  }
}

/// One widget tree that [act.tap] and [act.inspectTap] must agree on.
class _TapParityCase {
  _TapParityCase({
    required this.name,
    required this.canTap,
    required this.build,
    required this.selector,
    this.sameMessage = true,
  });

  final String name;

  /// What [TapInspection.canTap] must report, and whether [act.tap] must work.
  final bool canTap;

  /// Whether the message [act.tap] throws must repeat the inspection's.
  ///
  /// Only `false` where the message embeds something that differs between two
  /// calls, such as a `RenderObject` that is rebuilt on every access. The
  /// decision is still compared, which is the part that can drift.
  final bool sameMessage;

  final Widget Function() build;

  /// Created after pumping, selectors resolve against the current tree.
  final WidgetSelector<Widget> Function() selector;
}
