import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Top level entry point to drag widgets on the screen.
///
/// ```dart
/// final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
///final secondItem = spotText('Item at index: 27', exact: true)..doesNotExist();
/// await act.dragUntilVisible(
/// dragStart: firstItem,
/// dragTarget: secondItem,
/// maxIteration: 30,
/// moveStep: const Offset(0, -100),
/// );
/// secondItem.existsOnce();
/// ```
const gestures = Gestures._();

/// Drag stuff
class Gestures {
  const Gestures._();

  /// The next available pointer identifier.
  ///
  /// This is the default pointer identifier that will be used the next time the
  /// [startGesture] method is called without an explicit pointer identifier.
  int get nextPointer => _nextPointer;

  static int _nextPointer = 1;

  static int _getNextPointer() {
    final int result = _nextPointer;
    _nextPointer += 1;
    return result;
  }

  /// Attempts to drag the given widget by the given offset, by
  /// starting a drag in the middle of the widget.
  ///
  /// {@macro flutter.flutter_test.WidgetController.tap.warnIfMissed}
  ///
  /// If you want the drag to end with a speed so that the gesture recognition
  /// system identifies the gesture as a fling, consider using [fling] instead.
  ///
  /// The operation happens at once. If you want the drag to last for a period
  /// of time, consider using [timedDrag].
  ///
  /// {@macro flutter.flutter_test.WidgetController.fling.offset}
  ///
  /// {@template flutter.flutter_test.WidgetController.drag}
  /// By default, if the x or y component of offset is greater than
  /// [kDragSlopDefault], the gesture is broken up into two separate moves
  /// calls. Changing `touchSlopX` or `touchSlopY` will change the minimum
  /// amount of movement in the respective axis before the drag will be broken
  /// into multiple calls. To always send the drag with just a single call to
  /// [TestGesture.moveBy], `touchSlopX` and `touchSlopY` should be set to 0.
  ///
  /// Breaking the drag into multiple moves is necessary for accurate execution
  /// of drag update calls with a [DragStartBehavior] variable set to
  /// [DragStartBehavior.start]. Without such a change, the dragUpdate callback
  /// from a drag recognizer will never be invoked.
  ///
  /// To force this function to a send a single move event, the `touchSlopX` and
  /// `touchSlopY` variables should be set to 0. However, generally, these values
  /// should be left to their default values.
  /// {@endtemplate}
  Future<void> drag(
    Offset position,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    bool warnIfMissed = true,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    return dragFrom(
      position,
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
      kind: kind,
    );
  }

  /// Attempts a drag gesture consisting of a pointer down, a move by
  /// the given offset, and a pointer up.
  ///
  /// If you want the drag to end with a speed so that the gesture recognition
  /// system identifies the gesture as a fling, consider using [flingFrom]
  /// instead.
  ///
  /// The operation happens at once. If you want the drag to last for a period
  /// of time, consider using [timedDragFrom].
  ///
  /// {@macro flutter.flutter_test.WidgetController.drag}
  Future<void> dragFrom(
    Offset startLocation,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) {
    assert(kDragSlopDefault > kTouchSlop);
    return TestAsyncUtils.guard<void>(() async {
      final TestGesture gesture = await startGesture(
        startLocation,
        pointer: pointer,
        buttons: buttons,
        kind: kind,
      );

      final double xSign = offset.dx.sign;
      final double ySign = offset.dy.sign;

      final double offsetX = offset.dx;
      final double offsetY = offset.dy;

      final bool separateX = offset.dx.abs() > touchSlopX && touchSlopX > 0;
      final bool separateY = offset.dy.abs() > touchSlopY && touchSlopY > 0;

      if (separateY || separateX) {
        final double offsetSlope = offsetY / offsetX;
        final double inverseOffsetSlope = offsetX / offsetY;
        final double slopSlope = touchSlopY / touchSlopX;
        final double absoluteOffsetSlope = offsetSlope.abs();
        final double signedSlopX = touchSlopX * xSign;
        final double signedSlopY = touchSlopY * ySign;
        if (absoluteOffsetSlope != slopSlope) {
          // The drag goes through one or both of the extents of the edges of the box.
          if (absoluteOffsetSlope < slopSlope) {
            assert(offsetX.abs() > touchSlopX);
            // The drag goes through the vertical edge of the box.
            // It is guaranteed that the |offsetX| > touchSlopX.
            final double diffY = offsetSlope.abs() * touchSlopX * ySign;

            // The vector from the origin to the vertical edge.
            await gesture.moveBy(Offset(signedSlopX, diffY));
            if (offsetY.abs() <= touchSlopY) {
              // The drag ends on or before getting to the horizontal extension of the horizontal edge.
              await gesture
                  .moveBy(Offset(offsetX - signedSlopX, offsetY - diffY));
            } else {
              final double diffY2 = signedSlopY - diffY;
              final double diffX2 = inverseOffsetSlope * diffY2;

              // The vector from the edge of the box to the horizontal extension of the horizontal edge.
              await gesture.moveBy(Offset(diffX2, diffY2));
              await gesture.moveBy(
                Offset(
                  offsetX - diffX2 - signedSlopX,
                  offsetY - signedSlopY,
                ),
              );
            }
          } else {
            assert(offsetY.abs() > touchSlopY);
            // The drag goes through the horizontal edge of the box.
            // It is guaranteed that the |offsetY| > touchSlopY.
            final double diffX = inverseOffsetSlope.abs() * touchSlopY * xSign;

            // The vector from the origin to the vertical edge.
            await gesture.moveBy(Offset(diffX, signedSlopY));
            if (offsetX.abs() <= touchSlopX) {
              // The drag ends on or before getting to the vertical extension of the vertical edge.
              await gesture
                  .moveBy(Offset(offsetX - diffX, offsetY - signedSlopY));
            } else {
              final double diffX2 = signedSlopX - diffX;
              final double diffY2 = offsetSlope * diffX2;

              // The vector from the edge of the box to the vertical extension of the vertical edge.
              await gesture.moveBy(Offset(diffX2, diffY2));
              await gesture.moveBy(
                Offset(
                  offsetX - signedSlopX,
                  offsetY - diffY2 - signedSlopY,
                ),
              );
            }
          }
        } else {
          // The drag goes through the corner of the box.
          await gesture.moveBy(Offset(signedSlopX, signedSlopY));
          await gesture
              .moveBy(Offset(offsetX - signedSlopX, offsetY - signedSlopY));
        }
      } else {
        // The drag ends inside the box.
        await gesture.moveBy(offset);
      }
      await gesture.up();
    });
  }

  /// Creates a gesture with an initial appropriate starting gesture at a
  /// particular point, and returns the [TestGesture] object which you can use
  /// to continue the gesture. Usually, the starting gesture will be a down event,
  /// but if [kind] is set to [PointerDeviceKind.trackpad], the gesture will start
  /// with a panZoomStart gesture.
  ///
  /// You can use [createGesture] if your gesture doesn't begin with an initial
  /// down or panZoomStart gesture.
  ///
  /// See also:
  ///  * [WidgetController.drag], a method to simulate a drag.
  ///  * [WidgetController.timedDrag], a method to simulate the drag of a given
  ///    widget in a given duration. It sends move events at a given frequency and
  ///    it is useful when there are listeners involved.
  ///  * [WidgetController.fling], a method to simulate a fling.
  Future<TestGesture> startGesture(
    Offset downLocation, {
    int? pointer,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int buttons = kPrimaryButton,
  }) async {
    final TestGesture result =
        _createGesture(pointer: pointer, kind: kind, buttons: buttons);
    if (kind == PointerDeviceKind.trackpad) {
      await result.panZoomStart(downLocation);
    } else {
      await result.down(downLocation);
    }
    return result;
  }

  TestGesture _createGesture({
    int? pointer,
    required PointerDeviceKind kind,
    required int buttons,
  }) {
    return TestGesture(
      dispatcher: sendEventToBinding,
      kind: kind,
      pointer: pointer ?? _getNextPointer(),
      buttons: buttons,
    );
  }

  /// Forwards the given pointer event to the binding.
  Future<void> sendEventToBinding(PointerEvent event) {
    return TestAsyncUtils.guard<void>(() async {
      final binding = TestWidgetsFlutterBinding.instance;
      binding.handlePointerEvent(event);
    });
  }
}
