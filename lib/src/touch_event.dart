import 'package:flutter/widgets.dart';

class TouchEvent {
  static void tap(Offset position) {
    final downEvent = PointerDownEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    WidgetsBinding.instance.handlePointerEvent(upEvent);
  }
}
