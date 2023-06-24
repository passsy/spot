import 'package:flutter/gestures.dart';
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
    final position = _getPosition(selector);

    final binding = WidgetsBinding.instance;
    final isIntegrationTest = binding is LiveTestWidgetsFlutterBinding;

    late final bool previousShouldPropagateDevicePointerEvents;
    if (isIntegrationTest) {
      previousShouldPropagateDevicePointerEvents =
          binding.shouldPropagateDevicePointerEvents;

      // Actually tap the widget and not show which widgets are located at
      // that position in console. This is only necessary when executing the
      // widget test on a real device or simulator.
      binding.shouldPropagateDevicePointerEvents = true;
    }

    final downEvent = PointerDownEvent(position: position);
    binding.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    binding.handlePointerEvent(upEvent);

    if (isIntegrationTest) {
      binding.shouldPropagateDevicePointerEvents =
          previousShouldPropagateDevicePointerEvents;
    }
  }

  /// Returns the center position of a widget.
  static Offset _getPosition(SingleWidgetSelector selector) {
    // Check if widget is in the widget tree.
    selector.existsOnce();

    final snapshot = selector.snapshot();
    final discovered = snapshot.discovered;

    if (discovered == null) {
      throw TestFailure(
        "Widget '${selector.type}' can't be tapped",
      );
    }

    final element = discovered.element;
    final box = element.renderObject as RenderBox?;

    if (box == null) {
      throw TestFailure(
        "Widget '${selector.type}' has no render object and can't be tapped",
      );
    }

    final position = box.localToGlobal(box.size.center(Offset.zero));

    final isVisible = _checkIfVisible(position: position, box: box);

    if (!isVisible) {
      throw TestFailure(
        "Widget '${selector.type}' is not visible and can't be tapped",
      );
    }

    return position;
  }

  static bool _checkIfVisible(
      {required Offset position, required RenderBox box}) {
    final binding = WidgetsBinding.instance;
    final HitTestResult result = HitTestResult();
    binding.hitTest(result, position);
    for (final HitTestEntry entry in result.path) {
      if (entry.target == box) {
        return true;
      }
    }
    return false;
  }
}
