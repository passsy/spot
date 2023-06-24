import 'package:dartx/dartx.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

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
    final snapshot = selector.snapshot();

    // Check if widget is in the widget tree. Throws if not.
    selector.existsOnce();

    // Find the associated RenderObject to get the position of the element on the screen
    final renderObject = snapshot.discovered!.element.renderObject;
    if (renderObject == null) {
      throw TestFailure(
        "Widget '${selector.type}' has no associated RenderObject.\n"
        "Spot does not know where the widget is located on the screen.",
      );
    }
    if (renderObject is! RenderBox) {
      throw TestFailure(
        "Widget '${selector.type}' is associated to $renderObject which "
        "is not a RenderObject in the 2D Cartesian coordinate system "
        "(implements RenderBox).\n"
        "Spot does not know how to hit test such a widget.",
      );
    }
    final position =
        renderObject.localToGlobal(renderObject.size.center(Offset.zero));

    final binding = WidgetsBinding.instance;
    // Special handling when running the test on a device/simulator.
    final isIntegrationTest = binding is LiveTestWidgetsFlutterBinding;

    late final bool previousPropagateValue;
    if (isIntegrationTest) {
      previousPropagateValue = binding.shouldPropagateDevicePointerEvents;

      // Actually tap the widget and not show which widgets are located at
      // that position in console. This is only necessary when executing the
      // widget test on a real device or simulator.
      binding.shouldPropagateDevicePointerEvents = true;
    }
    try {
      // Before tapping the widget, we need to make sure that the widget is not
      // covered by another widget, or outside the viewport.
      _probeLocation(
        position: position,
        target: renderObject,
        selector: selector,
      );

      // Finally, tap the widget by sending an down and up event.
      final downEvent = PointerDownEvent(position: position);
      binding.handlePointerEvent(downEvent);

      final upEvent = PointerUpEvent(position: position);
      binding.handlePointerEvent(upEvent);
    } finally {
      // Cleanup
      if (isIntegrationTest) {
        binding.shouldPropagateDevicePointerEvents = previousPropagateValue;
      }
    }
  }

  /// Checks if the widget is visible and not covered by another widget by
  /// hit testing the location of the widget.
  void _probeLocation({
    required Offset position,
    required RenderObject target,
    required SingleWidgetSelector selector,
  }) {
    final binding = WidgetsBinding.instance;
    final HitTestResult result = HitTestResult();
    binding.hitTest(result, position);
    final hitTestEntries = result.path.toList();
    for (final HitTestEntry entry in hitTestEntries) {
      if (entry.target == target) {
        // box was hit by the hit test
        return;
      }
    }

    // did not hit RenderObject, it is either covered by another widget or outside
    // the viewport
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

    throw TestFailure(
      "Widget '${selector.type}' is not visible and can't be tapped",
    );
  }
}
