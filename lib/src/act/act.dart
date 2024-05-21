import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/snapshot.dart';

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

  /// Enters a text into the first [EditableText] child of [selector].
  ///
  /// ```dart
  /// final emailTextField = spot<Form>()
  ///     .spot<TextField>()
  ///     .whereWidgetProp(
  ///       widgetProp('labelText', (textField) => textField.decoration?.labelText),
  ///       (label) => label == 'Email',
  ///     )..existsOnce();
  /// await act.enterText(emailTextField, 'alfred@phntm.xyz');
  /// ```
  Future<void> enterText(WidgetSelector selector, String text) async {
    // Check if widget is in the widget tree. Throws if not.
    selector.snapshot().existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      final binding = TestWidgetsFlutterBinding.instance;

      final editableText = spot<EditableText>().withParent(selector);
      final element = editableText.snapshot().discoveredElement;
      final EditableTextState editableTextState;

      if (element is! StatefulElement || element.state is! EditableTextState) {
        throw TestFailure(
          "Widget '${selector.toStringBreadcrumb()}' is not a descendant of EditableText.",
        );
      } else {
        editableTextState = element.state as EditableTextState;
      }

      // Setting focusedEditable causes the binding to call requestKeyboard()
      // on the EditableTextState, which itself eventually calls TextInput.attach
      // to establish the connection.
      binding.focusedEditable = editableTextState;
      await binding.pump();

      if (!kIsWeb) {
        // Fix for enterText() not working in release mode on real iOS devices.
        // See https://github.com/flutter/flutter/pull/89703
        // Also a fix for enterText() not being able to interact with the same
        // textfield 2 times in the same test.
        // See https://github.com/flutter/flutter/issues/134604
        binding.testTextInput.register();
      }

      final testTextInput = binding.testTextInput;
      testTextInput.enterText(text);
      await binding.pump();
    });
  }

  /// Triggers a tap event on a given widget.
  /// If [showTapPosition] is true, a crosshair is drawn on the screenshot at
  /// the position of the tap.
  Future<void> tap(
    WidgetSelector selector, {
    bool? showTapPosition,
  }) async {
    // Check if widget is in the widget tree. Throws if not.
    final snapshot = selector.snapshot()..existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        // Find the associated RenderObject to get the position of the element on the screen
        final element = snapshot.discoveredElement!;
        final renderObject = element.renderObject;
        if (renderObject == null) {
          throw TestFailure(
            "Widget '${selector.toStringBreadcrumb()}' has no associated RenderObject.\n"
            "Spot does not know where the widget is located on the screen.",
          );
        }
        if (renderObject is! RenderBox) {
          throw TestFailure(
            "Widget '${selector.toStringBreadcrumb()}' is associated to $renderObject which "
            "is not a RenderObject in the 2D Cartesian coordinate system "
            "(implements RenderBox).\n"
            "Spot does not know how to hit test such a widget.",
          );
        }
        _validateViewBounds(renderObject, selector: selector);

        final centerPosition =
            renderObject.localToGlobal(renderObject.size.center(Offset.zero));

        // Before tapping the widget, we need to make sure that the widget is not
        // covered by another widget, or outside the viewport.
        _pokeRenderObject(
          position: centerPosition,
          target: renderObject,
          snapshot: snapshot,
        );

        final binding = TestWidgetsFlutterBinding.instance;

        // Finally, tap the widget by sending a down and up event.
        final downEvent = PointerDownEvent(position: centerPosition);
        binding.handlePointerEvent(downEvent);

        final upEvent = PointerUpEvent(position: centerPosition);
        binding.handlePointerEvent(upEvent);

        await binding.pump();

        if (showTapPosition == true) {
          await takeScreenshotWithCrosshair(
            element: element,
            crosshairPosition: centerPosition,
          );
        }
      });
    });
  }

  // Validates that the widget is at least partially visible in the viewport.
  void _validateViewBounds(
    RenderBox renderBox, {
    required WidgetSelector selector,
  }) {
    // ignore: deprecated_member_use
    final view = WidgetsBinding.instance.renderView;
    final Rect viewport = Offset.zero & view.size;
    final Rect location =
        renderBox.localToGlobal(Offset.zero) & renderBox.paintBounds.size;

    final intersection = viewport.intersect(location);
    if (intersection.width < 0 || intersection.height < 0) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is located outside the viewport ($location).",
      );
    }
    // TODO handle case when location is partially outside viewport
    // TODO what if the center is outside the viewport, should we move the touch location or error?
  }

  /// Checks if the widget is visible and not covered by another widget
  ///
  /// This test fails when the widget does not react to hit tests
  void _pokeRenderObject({
    required Offset position,
    required RenderObject target,
    required WidgetSnapshot snapshot,
  }) {
    final binding = WidgetsBinding.instance;

    // do the tap, hit test the position of [target]
    final HitTestResult result = HitTestResult();
    // ignore: deprecated_member_use
    binding.hitTest(result, position);
    final hitTestEntries = result.path.toList();

    // Check if [target] received the tap event
    for (final HitTestEntry entry in hitTestEntries) {
      if (entry.target == target) {
        // Success, target was hit by hitTest
        return;
      }
    }

    final List<Element> hitTargetElements =
        hitTestEntries.mapNotNull((e) => e.element).toList();

    _detectAbsorbPointer(hitTargetElements.first, snapshot);
    _detectIgnorePointer(target, snapshot);

    final Element commonAncestor = findCommonAncestor(
      [hitTargetElements.first, snapshot.discoveredElement!],
    );

    throw TestFailure(
      "Widget '${snapshot.selector.toStringBreadcrumb()}' is covered by '${hitTargetElements.first.widget.toStringShort()}' and can't be tapped.\n"
      "The common ancestor of both widgets is:\n"
      "${commonAncestor.toStringDeep()}",
    );
  }

  /// Throws when the widget is wrapped in an AbsorbPointer that is absorbing
  /// the taps and doesn't forward them to the child
  void _detectAbsorbPointer(
    Element hitTarget,
    WidgetSnapshot<Widget> snapshot,
  ) {
    final childElement = hitTarget.children.firstOrNull;
    if (childElement?.widget is AbsorbPointer) {
      final absorbPointer = childElement!.widget as AbsorbPointer;
      if (absorbPointer.absorbing) {
        final location = getCreationLocation(childElement) ??
            childElement.debugGetCreatorChain(100);
        throw TestFailure(
            "Widget '${snapshot.selector.toStringBreadcrumb()}' is wrapped in AbsorbPointer and doesn't receive taps.\n"
            "AbsorbPointer is created at $location\n"
            "The closest widget reacting to the touch event is:\n"
            "${hitTarget.toStringDeep()}");
      }
    }
  }

  /// Throws if the widget is wrapped in an IgnorePointer that is not forwarding events
  void _detectIgnorePointer(
    RenderObject target,
    WidgetSnapshot<Widget> snapshot,
  ) {
    final targetElement = (target.debugCreator as DebugCreator?)!.element;
    // sorted from root to target
    final parents = targetElement.parents.reversed.toList();
    // the first IgnorePointer that is not forwarding events
    final ignorePointer = parents.firstOrNullWhere(
      (element) {
        if (element.widget is! IgnorePointer) return false;
        final ignorePointer = element.widget as IgnorePointer;
        return ignorePointer.ignoring;
      },
    );
    if (ignorePointer != null) {
      final location = getCreationLocation(ignorePointer) ??
          targetElement.debugGetCreatorChain(100);
      throw TestFailure(
        "Widget '${snapshot.selector.toStringBreadcrumb()}' is wrapped in IgnorePointer and doesn't receive taps. "
        "The IgnorePointer is located at $location",
      );
    }
  }
}

extension on HitTestEntry {
  /// Returns the [Element] that created this [RenderObject]
  Element? get element {
    if (target is! RenderObject) return null;
    final t = target as RenderObject;
    if (t.debugCreator is! DebugCreator?) return null;
    final debugCreator = t.debugCreator as DebugCreator?;
    return debugCreator?.element;
  }
}

/// Makes sure that the device pointer events are always propagated to the
/// widgets and are not intercepted by [LiveTestWidgetsFlutterBinding].
///
/// See [LiveTestWidgetsFlutterBinding.shouldPropagateDevicePointerEvents].
T _alwaysPropagateDevicePointerEvents<T>(T Function() block) {
  final binding = WidgetsBinding.instance;
  final live = binding is LiveTestWidgetsFlutterBinding;

  late final bool previousPropagateValue;
  if (live) {
    previousPropagateValue = binding.shouldPropagateDevicePointerEvents;

    // Actually tap the widget and not show which widgets are located at
    // that position in console. This is only necessary when executing the
    // widget test on a real device or simulator.
    binding.shouldPropagateDevicePointerEvents = true;
  }
  try {
    return block();
  } finally {
    if (live) {
      binding.shouldPropagateDevicePointerEvents = previousPropagateValue;
    }
  }
}

/// Workaround to the the location of a widget in code
///
/// This method is a workaround to call `_getCreationLocation()` which is private
String? getCreationLocation(Element element) {
  final debugCreator = element.renderObject?.debugCreator;
  if (debugCreator is! DebugCreator) {
    return null;
  }
  final block =
      debugTransformDebugCreator([DiagnosticsDebugCreator(debugCreator)]).first
          as DiagnosticsBlock;
  final description = block.getChildren().first as ErrorDescription;
  final location = description.value.first.toString();
  // _Location .toString() looks something like this:
  // IgnorePointer IgnorePointer:file:///Users/pascalwelsch/Projects/passsy/spot/test/act/act_test.dart:142:18

  final matches = RegExp('.*(file:///.*)').allMatches(location);
  final filePath = matches.first.group(1);

  return filePath;
}
