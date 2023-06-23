import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  (WidgetsBinding.instance as LiveTestWidgetsFlutterBinding).shouldPropagateDevicePointerEvents = true;

  testWidgets('test touch event', (tester) async {
    int i = 0;
    void onPressed() => i++;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child: null,
          ),
        ),
      ),
    );

    final button = spotSingle<MaterialApp>().spotSingle<ElevatedButton>();

    /// Can be removed - copied to [_TouchEvent]

    // final snapshot = button.snapshot();
    // final element = snapshot.discoveredElement;
    // final box = element?.renderObject as RenderBox?;
    // final position = box!.localToGlobal(box.size.center(Offset.zero));
    // final downEvent = PointerDownEvent(position: position);
    // final upEvent = PointerUpEvent(position: position);
    //
    // binding.handlePointerEvent(downEvent);
    // binding.handlePointerEvent(upEvent);
    //
    // binding.handlePointerEvent(downEvent);
    // binding.handlePointerEvent(upEvent);
    //
    // expect(i, 2);
    // i = 0;

    /// Unnecessary, since dispatchEvent() doesn't work:
    // final result = BoxHitTestResult();
    // final entry = BoxHitTestEntry(box, position);
    // result.add(entry);

    /// Doesn't work, because it's calling [dispatchEvent] from abstract class [HitTestDispatcher]:
    // binding.deviceEventDispatcher?.dispatchEvent(event, result);

    /// Doesn't increment:
    // dispatcher?.binding.dispatchEvent(downEvent, result);
    // dispatcher?.binding.dispatchEvent(upEvent, result);

    /// Doesn't increment:
    // (dispatcher?.binding as LiveTestWidgetsFlutterBinding?)?.dispatchEvent(downEvent, result);
    // (dispatcher?.binding as LiveTestWidgetsFlutterBinding?)?.dispatchEvent(upEvent, result);

    expect(i, 0);
    button.tap();
    expect(i, 1);
    button.tap();
    expect(i, 2);
  });
}
