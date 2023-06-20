import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

extension TouchEventExtension on SingleWidgetSelector {
  void tap() => TouchEvent.tap(this);
}

class TouchEvent {
  static void tap(SingleWidgetSelector selector) {
    final position = _getPosition(selector);

    final downEvent = PointerDownEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(upEvent);
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
