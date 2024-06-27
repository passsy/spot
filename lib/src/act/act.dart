import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/act/gestures.dart';
import 'package:spot/src/spot/snapshot.dart';

/// Top level entry point to interact with widgets on the screen.
///
/// ```dart
/// final button = spotSingle<FloatingActionButton>();
/// act.tap(button);
/// ```
const act = Act._();

/// Entrypoint to interact with widgets found via [spot].
class Act {
  const Act._();

  /// Enters a text into the first [EditableText] child of [selector].
  ///
  /// ```dart
  /// final emailTextField = spot<Form>()
  ///     .spot<TextField>()
  ///     .whereWidgetProp(
  ///       widgetProp('labelText', (textField) => textField.decoration?.labelText),
  ///       (label) => label == 'Email',
  ///     )..existsOnce();
  /// await act.enterText(emailTextField, 'alfred@phntm.xyz');
  /// ```
  Future<void> enterText(WidgetSelector selector, String text) async {
    // Check if widget is in the widget tree. Throws if not.
    selector.snapshot().existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      final binding = TestWidgetsFlutterBinding.instance;

      final editableText = spot<EditableText>().withParent(selector);
      final element = editableText.snapshot().discoveredElement;
      final EditableTextState editableTextState;

      if (element is! StatefulElement || element.state is! EditableTextState) {
        throw TestFailure(
          "Widget '${selector.toStringBreadcrumb()}' is not a descendant of EditableText.",
        );
      } else {
        editableTextState = element.state as EditableTextState;
      }

      // Setting focusedEditable causes the binding to call requestKeyboard()
      // on the EditableTextState, which itself eventually calls TextInput.attach
      // to establish the connection.
      binding.focusedEditable = editableTextState;
      await binding.pump();

      if (!kIsWeb) {
        // Fix for enterText() not working in release mode on real iOS devices.
        // See https://github.com/flutter/flutter/pull/89703
        // Also a fix for enterText() not being able to interact with the same
        // textfield 2 times in the same test.
        // See https://github.com/flutter/flutter/issues/134604
        binding.testTextInput.register();
      }

      final testTextInput = binding.testTextInput;
      testTextInput.enterText(text);
      await binding.pump();
    });
  }

  /// Triggers a tap event on a given widget.
  Future<void> tap(WidgetSelector selector) async {
    // Check if widget is in the widget tree. Throws if not.
    final snapshot = selector.snapshot()..existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final renderBox = _getRenderBoxOrThrow(selector);

        // Before tapping the widget, we need to make sure that the widget is
        // not outside the viewport or covered by another widget.
        _validateViewBounds(renderBox, selector: selector);
        final pokablePositions = _findPokablePositions(
          widgetSelector: selector,
          snapshot: snapshot,
        );

        if (pokablePositions.hits.isEmpty) {
          final centerPosition =
              renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          _throwHitTestFailureReport(
            position: centerPosition,
            target: renderBox,
            snapshot: snapshot,
          );
          return;
        }

        final positionToTap = pokablePositions.mostCenterHittablePosition!;
        if (pokablePositions.percent < 100) {
          final roundUp = pokablePositions.percent.ceil();
          // TODO replace prints with events once timeline is incorporated
          // ignore: avoid_print
          print(
            "Warning: The '${snapshot.discoveredWidget!.toStringShort()}' is partially covered.\n"
            "~$roundUp% of the widget are still tappable.\n"
            "Using $positionToTap.",
          );
        }

        final binding = TestWidgetsFlutterBinding.instance;

        // Finally, tap the widget by sending a down and up event.
        final downEvent = PointerDownEvent(position: positionToTap);
        binding.handlePointerEvent(downEvent);

        final upEvent = PointerUpEvent(position: positionToTap);
        binding.handlePointerEvent(upEvent);

        await binding.pump();
      });
    });
  }

  /// Repeatedly drags at the position of `dragStart` by `moveStep` until `dragTarget` is visible.
  ///
  /// Between each drag, advances the clock by `duration`.
  ///
  /// Throws a [TestFailure] if `dragTarget` is not found after `maxIteration`
  /// drags.
  ///
  /// usage:
  /// ```dart
  /// final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
  /// final secondItem = spotText('Item at index: 27', exact: true)..doesNotExist();
  /// await act.dragUntilVisible(
  ///   dragStart: firstItem,
  ///   dragTarget: secondItem,
  ///   maxIteration: 30,
  ///   moveStep: const Offset(0, -100),
  /// );
  /// secondItem.existsOnce();
  /// ```
  Future<void> dragUntilVisible({
    required WidgetSelector<Widget> dragStart,
    required WidgetSelector<Widget> dragTarget,
    required Offset moveStep,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    // Check if widget is in the widget tree. Throws if not.
    final snapshot = dragStart.snapshot()..existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final renderBox = _getRenderBoxOrThrow(dragStart);

        final binding = TestWidgetsFlutterBinding.instance;

        // Before dragging, we need to make sure that `dragStart` is
        // not outside the viewport or covered by another widget.
        _validateViewBounds(renderBox, selector: dragStart);
        final pokablePositions = _findPokablePositions(
          widgetSelector: dragStart,
          snapshot: snapshot,
        );

        if (pokablePositions.hits.isEmpty) {
          final centerPosition =
              renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          _throwHitTestFailureReport(
            position: centerPosition,
            target: renderBox,
            snapshot: snapshot,
          );
          return;
        }
        final targetName = dragTarget.toStringBreadcrumb();

        bool isTargetVisible() {
          final renderObject = _renderObjectFromSelector(dragTarget);
          if (renderObject is RenderBox) {
            return _validateViewBounds(
              renderObject,
              selector: dragTarget,
              throwIfInvisible: false,
            );
          } else {
            return false;
          }
        }

        bool isVisible = isTargetVisible();

        if (isVisible) {
          return;
        }
        final dragPosition = pokablePositions.mostCenterHittablePosition!;
        if (pokablePositions.percent < 100) {
          final roundUp = pokablePositions.percent.ceil();
          // TODO replace prints with events once timeline is incorporated
          // ignore: avoid_print
          print(
            "Warning: The '${snapshot.discoveredWidget!.toStringShort()}' is partially covered.\n"
            "~$roundUp% of the widget are still tappable.\n"
            "Using $dragPosition.",
          );
        }

        int iterations = 0;
        while (iterations < maxIteration && !isVisible) {
          await gestures.drag(dragPosition, moveStep);
          await binding.pump(duration);
          iterations++;
          isVisible = isTargetVisible();
        }

        final totalDragged = moveStep * iterations.toDouble();

        if (!isVisible) {
          throw TestFailure(
            "$targetName is not visible after dragging $iterations times and a total dragged offset of $totalDragged.",
          );
        }
      });
    });
  }

  /// Returns the `RenderBox` of a widget based on the given selector.
  /// Throws `TestFailure` if the widget's render object is null or not a `RenderBox`.
  RenderBox _getRenderBoxOrThrow(WidgetSelector<Widget> selector) {
    final renderObject = _renderObjectFromSelector(selector);
    if (renderObject == null) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' has no associated RenderObject.\n"
        "Spot does not know where the widget is located on the screen.",
      );
    }
    if (renderObject is! RenderBox) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is associated to $renderObject which "
        "is not a RenderObject in the 2D Cartesian coordinate system "
        "(implements RenderBox).\n"
        "Spot does not know how to hit test such a widget.",
      );
    }
    return renderObject;
  }

  /// Returns the `RenderObject` of a widget based on the given selector.
  /// Returns `null` if the widget's render object is null.
  RenderObject? _renderObjectFromSelector(WidgetSelector<Widget> selector) {
    final snapshot = selector.snapshot();
    final element = snapshot.discoveredElement;
    return element?.renderObject;
  }

  // Validates that the widget is at least partially visible in the viewport.
  bool _validateViewBounds(
    RenderBox renderBox, {
    required WidgetSelector selector,
    bool throwIfInvisible = true,
  }) {
    // ignore: deprecated_member_use
    final view = WidgetsBinding.instance.renderView;
    final Rect viewport = Offset.zero & view.size;
    final Rect location =
        renderBox.localToGlobal(Offset.zero) & renderBox.paintBounds.size;

    final intersection = viewport.intersect(location);
    final isNotVisible = intersection.width < 0 || intersection.height < 0;
    if (isNotVisible && throwIfInvisible) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is located outside the viewport ($location).",
      );
    }
    return !isNotVisible;
    // TODO handle case when location is partially outside viewport
    // TODO what if the center is outside the viewport, should we move the touch location or error?
  }

  /// Checks if the widget is visible and not covered by another widget
  ///
  /// This test fails when the widget does not react to hit tests
  void _throwHitTestFailureReport({
    required Offset position,
    required RenderObject target,
    required WidgetSnapshot snapshot,
  }) {
    final binding = WidgetsBinding.instance;

    // do the tap, hit test the position of [target]
    final HitTestResult result = HitTestResult();
    // ignore: deprecated_member_use
    binding.hitTest(result, position);
    final hitTestEntries = result.path.toList();

    final List<Element> hitTargetElements =
        hitTestEntries.mapNotNull((e) => e.element).toList();

    _detectAbsorbPointer(hitTargetElements.first, snapshot);
    _detectIgnorePointer(target, snapshot);

    final Element commonAncestor = findCommonAncestor(
      [hitTargetElements.first, snapshot.discoveredElement!],
    );

    throw TestFailure(
      "Widget '${snapshot.selector.toStringBreadcrumb()}' is covered by '${hitTargetElements.first.widget.toStringShort()}' and can't be tapped.\n"
      "The common ancestor of both widgets is:\n"
      "${commonAncestor.toStringDeep()}",
    );
  }

  /// Attempts to find hittable position on the [snapshot] [RenderObject] using
  /// an 8px grid.
  ///
  /// It returns the results of the search as [_PokablePositions], including all
  /// failed hit tests and a good estimate of a center point which is tappable
  /// ([_PokablePositions.mostCenterHittablePosition]).
  _PokablePositions _findPokablePositions({
    required WidgetSelector<Widget> widgetSelector,
    required WidgetSnapshot snapshot,
  }) {
    final RenderBox renderBox = _getRenderBoxOrThrow(widgetSelector);

    final List<Offset> hits = [];
    final List<Offset> flops = [];
    const gridSize = 8;
    for (int x = 0; x < renderBox.size.width; x += gridSize) {
      for (int y = 0; y < renderBox.size.height; y += gridSize) {
        final Offset localPosition = Offset(x.toDouble(), y.toDouble());
        final Offset globalPosition = renderBox.localToGlobal(localPosition);
        final canBePoked =
            _canBePoked(position: globalPosition, target: renderBox);
        if (canBePoked) {
          hits.add(globalPosition);
        } else {
          flops.add(globalPosition);
        }
      }
    }

    final pos = renderBox.localToGlobal(Offset.zero);
    final searchArea = Rect.fromLTWH(
      pos.dx,
      pos.dy,
      renderBox.size.width,
      renderBox.size.height,
    );

    if (hits.isEmpty) {
      return _PokablePositions(
        searchArea: searchArea,
        hits: hits,
        flops: flops,
        target: renderBox,
      );
    }

    // Find a good point to actually tap the widget
    // When parts of the widget are covered (like the right side) the center is
    // the middle of the right side.
    // This only fails when there is a hole of tappable points in the middle (which rarely happens)
    final Offset centerOfPokablePoints = () {
      final maxX = hits.maxBy((e) => e.dx)!.dx;
      final minX = hits.minBy((e) => e.dx)!.dx;
      final maxY = hits.maxBy((e) => e.dy)!.dy;
      final minY = hits.minBy((e) => e.dy)!.dy;
      return Offset(
        ((maxX + minX) ~/ 2).toDouble(),
        ((maxY + minY) ~/ 2).toDouble(),
      );
    }();
    final centerCanBePoked =
        _canBePoked(position: centerOfPokablePoints, target: renderBox);
    final Offset? mostCenterPoint;
    if (centerCanBePoked) {
      mostCenterPoint = centerOfPokablePoints;
    } else {
      // this is point is already working, use it as fallback when the center
      // is not tappable
      mostCenterPoint =
          hits.minBy((e) => (e - centerOfPokablePoints).distanceSquared);
    }

    return _PokablePositions(
      searchArea: searchArea,
      hits: hits,
      flops: flops,
      target: renderBox,
      mostCenterHittablePosition: mostCenterPoint,
    );
  }

  /// Checks if the widget is visible and not covered by another widget
  bool _canBePoked({
    required Offset position,
    required RenderObject target,
  }) {
    final binding = WidgetsBinding.instance;

    // do the tap, hit test the position of [target]
    final HitTestResult result = HitTestResult();
    // ignore: deprecated_member_use
    binding.hitTest(result, position);
    final hitTestEntries = result.path.toList();

    // Check if [target] received the tap event
    for (final HitTestEntry entry in hitTestEntries) {
      if (entry.target == target) {
        // Success, target was hit by hitTest
        return true;
      }
    }
    return false;
  }

  /// Throws when the widget is wrapped in an AbsorbPointer that is absorbing
  /// the taps and doesn't forward them to the child
  void _detectAbsorbPointer(
    Element hitTarget,
    WidgetSnapshot<Widget> snapshot,
  ) {
    final childElement = hitTarget.children.firstOrNull;
    if (childElement?.widget is AbsorbPointer) {
      final absorbPointer = childElement!.widget as AbsorbPointer;
      if (absorbPointer.absorbing) {
        final location = getCreationLocation(childElement) ??
            childElement.debugGetCreatorChain(100);
        throw TestFailure(
            "Widget '${snapshot.selector.toStringBreadcrumb()}' is wrapped in AbsorbPointer and doesn't receive taps.\n"
            "AbsorbPointer is created at $location\n"
            "The closest widget reacting to the touch event is:\n"
            "${hitTarget.toStringDeep()}");
      }
    }
  }

  /// Throws if the widget is wrapped in an IgnorePointer that is not forwarding events
  void _detectIgnorePointer(
    RenderObject target,
    WidgetSnapshot<Widget> snapshot,
  ) {
    final targetElement = (target.debugCreator as DebugCreator?)!.element;
    // sorted from root to target
    final parents = targetElement.parents.reversed.toList();
    // the first IgnorePointer that is not forwarding events
    final ignorePointer = parents.firstOrNullWhere(
      (element) {
        if (element.widget is! IgnorePointer) return false;
        final ignorePointer = element.widget as IgnorePointer;
        return ignorePointer.ignoring;
      },
    );
    if (ignorePointer != null) {
      final location = getCreationLocation(ignorePointer) ??
          targetElement.debugGetCreatorChain(100);
      throw TestFailure(
        "Widget '${snapshot.selector.toStringBreadcrumb()}' is wrapped in IgnorePointer and doesn't receive taps. "
        "The IgnorePointer is located at $location",
      );
    }
  }
}

/// Contains the result of hit testing an entire [RenderObject] in [_findPokablePositions]
class _PokablePositions {
  /// The area that was searched via hit testing
  final Rect searchArea;

  /// All points that where able to hit the [RenderObject]
  final List<Offset> hits;

  /// Points that where not able to hit the [RenderObject], but where inside [searchArea].
  ///
  /// Those points are covered by something and the [target] did not react
  final List<Offset> flops;

  /// The target that was used for hit testing
  final RenderBox target;

  /// The most center position that is hittable
  ///
  /// Returns null when no hittable position was found ([hits] is empty)
  final Offset? mostCenterHittablePosition;

  _PokablePositions({
    required this.searchArea,
    required this.hits,
    required this.flops,
    required this.target,
    this.mostCenterHittablePosition,
  });

  /// The percentage (0-100%) of positions that were hittable
  double get percent => hits.length / (hits.length + flops.length) * 100;
}

extension on HitTestEntry {
  /// Returns the [Element] that created this [RenderObject]
  Element? get element {
    if (target is! RenderObject) return null;
    final t = target as RenderObject;
    if (t.debugCreator is! DebugCreator?) return null;
    final debugCreator = t.debugCreator as DebugCreator?;
    return debugCreator?.element;
  }
}

/// Makes sure that the device pointer events are always propagated to the
/// widgets and are not intercepted by [LiveTestWidgetsFlutterBinding].
///
/// See [LiveTestWidgetsFlutterBinding.shouldPropagateDevicePointerEvents].
T _alwaysPropagateDevicePointerEvents<T>(T Function() block) {
  final binding = WidgetsBinding.instance;
  final live = binding is LiveTestWidgetsFlutterBinding;

  late final bool previousPropagateValue;
  if (live) {
    previousPropagateValue = binding.shouldPropagateDevicePointerEvents;

    // Actually tap the widget and not show which widgets are located at
    // that position in console. This is only necessary when executing the
    // widget test on a real device or simulator.
    binding.shouldPropagateDevicePointerEvents = true;
  }
  try {
    return block();
  } finally {
    if (live) {
      binding.shouldPropagateDevicePointerEvents = previousPropagateValue;
    }
  }
}

/// Workaround to the the location of a widget in code
///
/// This method is a workaround to call `_getCreationLocation()` which is private
String? getCreationLocation(Element element) {
  final debugCreator = element.renderObject?.debugCreator;
  if (debugCreator is! DebugCreator) {
    return null;
  }
  final block =
      debugTransformDebugCreator([DiagnosticsDebugCreator(debugCreator)]).first
          as DiagnosticsBlock;
  final description = block.getChildren().first as ErrorDescription;
  final location = description.value.first.toString();
  // _Location .toString() looks something like this:
  // IgnorePointer IgnorePointer:file:///Users/pascalwelsch/Projects/passsy/spot/test/act/act_test.dart:142:18

  final matches = RegExp('.*(file:///.*)').allMatches(location);
  final filePath = matches.first.group(1);

  return filePath;
}
