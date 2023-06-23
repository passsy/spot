import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

extension TouchEventExtension on SingleWidgetSelector {
  void tap() => _TouchEvent.tap(this);
}

class _TouchEvent {
  static void tap(SingleWidgetSelector selector) {
    final position = _getPosition(selector);
    final binding = WidgetsBinding.instance;

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
