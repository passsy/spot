import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// Top level entry point to interact with widgets on the screen.
///
/// ```dart
/// final button = spotSingle<FloatingActionButton>();
/// act.tap(button);
/// ```
const Act act = Act._();

/// Entrypoint to interact with widgets found via [spot]
class Act {
  /// {@macro Act}
  const Act._();

  /// Triggers a tap event on a given widget.
  void tap(SingleWidgetSelector selector) {
    final binding = WidgetsBinding.instance;

    late final bool previousShouldPropagateDevicePointerEvents;
    if (binding is LiveTestWidgetsFlutterBinding) {
      final liveBinding = LiveTestWidgetsFlutterBinding.instance;
      previousShouldPropagateDevicePointerEvents =
          liveBinding.shouldPropagateDevicePointerEvents;
      // actually tap the widget and not show which widgets are located at
      // that position in console. This is only necessary when executing the
      // widget test on a device
      liveBinding.shouldPropagateDevicePointerEvents = true;
    }

    final position = _getPosition(selector);
    final downEvent = PointerDownEvent(position: position);
    binding.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    binding.handlePointerEvent(upEvent);

    if (binding is LiveTestWidgetsFlutterBinding) {
      final liveBinding = LiveTestWidgetsFlutterBinding.instance;
      liveBinding.shouldPropagateDevicePointerEvents =
          previousShouldPropagateDevicePointerEvents;
    }
  }

  /// Returns the center position of a widget.
  static Offset _getPosition(SingleWidgetSelector selector) {
    final snapshot = selector.snapshot();
    final element = snapshot.discoveredElement;
    final box = element?.renderObject as RenderBox?;

    if (box == null) {
      throw Exception(
        "Element ${selector.type} has no render object and can't be tapped",
      );
    }

    final position = box.localToGlobal(box.size.center(Offset.zero));
    return position;
  }
}
