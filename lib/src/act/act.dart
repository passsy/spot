import 'package:dartx/dartx.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
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

  /// Triggers a tap event on a given widget.
  void tap(SingleWidgetSelector selector) {
    return _alwaysPropagateDevicePointerEvents(() {
      final snapshot = selector.snapshot();

      // Check if widget is in the widget tree. Throws if not.
      selector.existsOnce();

      // Find the associated RenderObject to get the position of the element on the screen
      final element = snapshot.discovered!.element;
      final renderObject = element.renderObject;
      if (renderObject == null) {
        throw TestFailure(
          "Widget '${selector.toStringWithoutParents()}' has no associated RenderObject.\n"
          "Spot does not know where the widget is located on the screen.",
        );
      }
      if (renderObject is! RenderBox) {
        throw TestFailure(
          "Widget '${selector.toStringWithoutParents()}' is associated to $renderObject which "
          "is not a RenderObject in the 2D Cartesian coordinate system "
          "(implements RenderBox).\n"
          "Spot does not know how to hit test such a widget.",
        );
      }
      _validateViewBounds(renderObject, selector: selector);

      final centerPosition =
          renderObject.localToGlobal(renderObject.size.center(Offset.zero));

      // Before tapping the widget, we need to make sure that the widget is not
      // covered by another widget, or outside the viewport.
      _pokeRenderObject(
        position: centerPosition,
        target: renderObject,
        snapshot: snapshot,
      );

      final binding = WidgetsBinding.instance;

      // Finally, tap the widget by sending a down and up event.
      final downEvent = PointerDownEvent(position: centerPosition);
      binding.handlePointerEvent(downEvent);

      final upEvent = PointerUpEvent(position: centerPosition);
      binding.handlePointerEvent(upEvent);
    });
  }

  // Validates that the widget is at least partially visible in the viewport.
  void _validateViewBounds(
    RenderBox renderBox, {
    required SingleWidgetSelector selector,
  }) {
    final Rect viewport =
        Offset.zero & WidgetsBinding.instance.renderView.configuration.size;
    final Rect location =
        renderBox.localToGlobal(Offset.zero) & renderBox.paintBounds.size;

    final intersection = viewport.intersect(location);
    if (intersection.width < 0 || intersection.height < 0) {
      throw TestFailure(
        "Widget '${selector.toStringWithoutParents()}' is located outside the viewport ($location).",
      );
    }
    // TODO handle case when location is partially outside viewport
    // TODO what if the center is outside the viewport, should we move the touch location or error?
  }

  /// Checks if the widget is visible and not covered by another widget
  ///
  /// This test fails when the widget does not react to hit tests
  void _pokeRenderObject({
    required Offset position,
    required RenderObject target,
    required SingleWidgetSnapshot snapshot,
  }) {
    final binding = WidgetsBinding.instance;
    final HitTestResult result = HitTestResult();
    // ignore: deprecated_member_use
    binding.hitTest(result, position);
    final hitTestEntries = result.path.toList();

    final firstResponder = hitTestEntries.first.target;
    if (firstResponder is RenderObject) {
      final firstResponderElement =
          (firstResponder.debugCreator as DebugCreator?)?.element;
      if (firstResponderElement != null) {
        final childElement = firstResponderElement.children.firstOrNull;
        if (childElement?.widget is AbsorbPointer) {
          final absorbPointer = childElement!.widget as AbsorbPointer;
          if (absorbPointer.absorbing) {
            throw TestFailure(
                "Widget '${snapshot.selector.toStringWithoutParents()}' is wrapped in AbsorbPointer and doesn't receive taps. "
                "The closest widget reacting to the touch event is:\n"
                "${firstResponderElement.toStringDeep()}");
          }
        }
      }
    }

    for (final HitTestEntry entry in hitTestEntries) {
      if (entry.target == target) {
        // Success, target was hit by hitTest
        return;
      }
    }

    // did not hit RenderObject, it is either covered by another widget
    final elements = hitTestEntries.mapNotNull((e) {
      if (e.target is RenderObject) {
        final renderObject = e.target as RenderObject;
        if (renderObject.debugCreator is DebugCreator?) {
          final debugCreator = renderObject.debugCreator as DebugCreator?;
          if (debugCreator != null) {
            return debugCreator.element;
          }
        }
      }
      return null;
    }).toList();

    final Element commonAncestor =
        findCommonAncestor([elements.first, snapshot.discoveredElement!]);

    throw TestFailure(
      "Widget '${snapshot.selector.toStringWithoutParents()}' is covered by '${elements.first.widget.toStringShort()}' and can't be tapped.\n"
      "The common ancestor of both widgets is:\n"
      "${commonAncestor.toStringDeep()}",
    );
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
