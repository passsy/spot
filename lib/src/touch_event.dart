import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

class TouchEvent {
  static void tap(SingleWidgetSelector selector) {
    final snapshot = selector.snapshot();
    final element = snapshot.discoveredElements;
    final box = element?.renderObject as RenderBox?;

    if (box == null) {
      throw Exception("Element has no render object and can't be tapped");
    }

    final position = box.localToGlobal(box.size.center(Offset.zero));

    final downEvent = PointerDownEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(upEvent);
  }
}
