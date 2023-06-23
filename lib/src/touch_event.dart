import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

extension TouchEventExtension on SingleWidgetSelector {
  void tap() => TouchEvent.tap(this);
}

class TouchEvent {
  static void initIntegrationTest() {
    final binding = WidgetsBinding.instance;
    if (binding is LiveTestWidgetsFlutterBinding) {
      LiveTestWidgetsFlutterBinding.ensureInitialized();
      binding.shouldPropagateDevicePointerEvents = true;
    }
  }

  static void _checkIfInitialized(WidgetsBinding binding) {
    if (binding is LiveTestWidgetsFlutterBinding) {
      LiveTestWidgetsFlutterBinding.ensureInitialized();
      final isInitialized = binding.shouldPropagateDevicePointerEvents == true;
      if (!isInitialized) {
        throw Exception(
          "Need to call TouchEvent.initIntegrationTest() before the test in main(). "
          "This sets LiveTestWidgetsFlutterBinding.shouldPropagateDevicePointerEvents to true.",
        );
      }
    }
  }

  static void tap(SingleWidgetSelector selector) {
    final binding = WidgetsBinding.instance;
    _checkIfInitialized(binding);

    final position = _getPosition(selector);

    final downEvent = PointerDownEvent(position: position);
    binding.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    binding.handlePointerEvent(upEvent);
  }

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
