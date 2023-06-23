import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

// {@template Act}
/// Class that provides methods to trigger events on widgets.
///
/// If running a test on a device, make sure to call [Act.initIntegrationTest]
/// in test's main() method, before [testWidgets].
// {@endtemplate}
class Act {
  /// {@macro Act}
  const Act();

  /// Triggers a tap event on a given widget.
  void tap(SingleWidgetSelector selector) {
    final binding = WidgetsBinding.instance;
    _checkIfInitialized(binding);

    final position = _getPosition(selector);

    final downEvent = PointerDownEvent(position: position);
    binding.handlePointerEvent(downEvent);

    final upEvent = PointerUpEvent(position: position);
    binding.handlePointerEvent(upEvent);
  }

  /// Needs to be called in the main() method of an integration test.
  static void initIntegrationTest() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = WidgetsBinding.instance;
    if (binding is LiveTestWidgetsFlutterBinding) {
      LiveTestWidgetsFlutterBinding.ensureInitialized();
      binding.shouldPropagateDevicePointerEvents = true;
    }
  }

  /// Checks if [initIntegrationTest] was called.
  /// Only necessary if running a test on a simulator/device.
  static void _checkIfInitialized(WidgetsBinding binding) {
    if (binding is LiveTestWidgetsFlutterBinding) {
      LiveTestWidgetsFlutterBinding.ensureInitialized();
      final isInitialized = binding.shouldPropagateDevicePointerEvents == true;
      if (!isInitialized) {
        throw Exception(
          "Need to call Act.initIntegrationTest() before the test in main(). "
          "This sets LiveTestWidgetsFlutterBinding.shouldPropagateDevicePointerEvents to true.",
        );
      }
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
