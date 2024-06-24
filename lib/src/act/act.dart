import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/act/gestures.dart';
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
  Future<void> tap(WidgetSelector selector) async {
    // Check if widget is in the widget tree. Throws if not.
    final snapshot = selector.snapshot()..existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final renderBox = _getRenderBoxOrThrow(selector);
        _validateViewBounds(renderBox, selector: selector);

        final tappedPosition = _findPokablePosition(
              widgetSelector: selector,
              snapshot: snapshot,
            ) ??
            renderBox.localToGlobal(renderBox.size.center(Offset.zero));

        // Before tapping the widget, we need to make sure that the widget is
        // not covered by another widget, or outside the viewport.
        _validatePokePosition(
          position: tappedPosition,
          target: renderBox,
          snapshot: snapshot,
        );

        final binding = TestWidgetsFlutterBinding.instance;

        // Finally, tap the widget by sending a down and up event.
        final downEvent = PointerDownEvent(position: tappedPosition);
        binding.handlePointerEvent(downEvent);

        final upEvent = PointerUpEvent(position: tappedPosition);
        binding.handlePointerEvent(upEvent);

        await binding.pump();
      });
    });
  }

  /// Repeatedly drags at the position of `dragStart` by `moveStep` until `dragTarget` is visible.
  ///
  /// Between each drag, advances the clock by `duration`.
  ///
  /// Throws a [TestFailure] if `dragTarget` is not found after `maxIteration`
  /// drags.
  ///
  /// usage:
  /// ```dart
  /// final firstItem = spotText('Item at index: 3', exact: true)..existsOnce();
  /// final secondItem = spotText('Item at index: 27', exact: true)..doesNotExist();
  /// await act.dragUntilVisible(
  ///   dragStart: firstItem,
  ///   dragTarget: secondItem,
  ///   maxIteration: 30,
  ///   moveStep: const Offset(0, -100),
  /// );
  /// secondItem.existsOnce();
  /// ```
  Future<void> dragUntilVisible({
    required WidgetSelector<Widget> dragStart,
    required WidgetSelector<Widget> dragTarget,
    required Offset moveStep,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    // Check if widget is in the widget tree. Throws if not.
    dragStart.snapshot().existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final renderBox = _getRenderBoxOrThrow(dragStart);

        final binding = TestWidgetsFlutterBinding.instance;
        final snapShot = dragStart.snapshot();

        final dragPosition = _findPokablePosition(
          widgetSelector: dragStart,
          snapshot: snapShot,
        );

        // This will throw an accurate error about why the center is not
        // interactable
        if (dragPosition == null) {
          final centerPosition =
              renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          _validatePokePosition(
            position: centerPosition,
            target: renderBox,
            snapshot: snapShot,
          );
        } else {
          final targetName = dragTarget.toStringBreadcrumb();

          bool isTargetVisible() {
            final renderObject = _renderObjectFromSelector(dragTarget);
            if (renderObject is RenderBox) {
              return _validateViewBounds(
                renderObject,
                selector: dragTarget,
                throwIfInvisible: false,
              );
            } else {
              return false;
            }
          }

          bool isVisible = isTargetVisible();

          if (isVisible) {
            return;
          }

          int iterations = 0;
          while (iterations < maxIteration && !isVisible) {
            await gestures.drag(dragPosition, moveStep);
            await binding.pump(duration);
            iterations++;
            isVisible = isTargetVisible();
          }

          final totalDragged = moveStep * iterations.toDouble();

          if (!isVisible) {
            throw TestFailure(
              "$targetName is not visible after dragging $iterations times and a total dragged offset of $totalDragged.",
            );
          }
        }
      });
    });
  }

  /// Returns the `RenderBox` of a widget based on the given selector.
  /// Throws `TestFailure` if the widget's render object is null or not a `RenderBox`.
  RenderBox _getRenderBoxOrThrow(WidgetSelector<Widget> selector) {
    final renderObject = _renderObjectFromSelector(selector);
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
    return renderObject;
  }

  /// Returns the `RenderObject` of a widget based on the given selector.
  /// Returns `null` if the widget's render object is null.
  RenderObject? _renderObjectFromSelector(WidgetSelector<Widget> selector) {
    final snapshot = selector.snapshot();
    final element = snapshot.discoveredElement;
    return element?.renderObject;
  }

  // Validates that the widget is at least partially visible in the viewport.
  bool _validateViewBounds(
    RenderBox renderBox, {
    required WidgetSelector selector,
    bool throwIfInvisible = true,
  }) {
    // ignore: deprecated_member_use
    final view = WidgetsBinding.instance.renderView;
    final Rect viewport = Offset.zero & view.size;
    final Rect location =
        renderBox.localToGlobal(Offset.zero) & renderBox.paintBounds.size;

    final intersection = viewport.intersect(location);
    final isNotVisible = intersection.width < 0 || intersection.height < 0;
    if (isNotVisible && throwIfInvisible) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is located outside the viewport ($location).",
      );
    }
    return !isNotVisible;
    // TODO handle case when location is partially outside viewport
    // TODO what if the center is outside the viewport, should we move the touch location or error?
  }

  /// Checks if the widget is visible and not covered by another widget
  ///
  /// This test fails when the widget does not react to hit tests
  void _validatePokePosition({
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

  /// Finds a pokable position on a specified widget by first checking
  /// high-probability interaction points followed by a detailed zigzag grid
  /// search if necessary.
  ///
  /// Initially, this function checks a set of predefined likely interaction
  /// points such as the widget's center, corners, and midpoints of each edge.
  /// If none of these points are interactable, it proceeds to perform a more
  /// exhaustive search using a zigzag pattern across the widget's area. This
  /// dual-phase approach optimizes for speed in typical cases while ensuring
  /// thoroughness when required.
  ///
  /// Returns an Offset representing a global position on the screen that can be
  /// interacted with, or null if no such position exists within the widget's
  /// bounds.
  Offset? _findPokablePosition({
    required WidgetSelector<Widget> widgetSelector,
    required WidgetSnapshot snapshot,
  }) {
    final RenderBox renderBox = _getRenderBoxOrThrow(widgetSelector);

    final initialPosition = renderBox.size.center(Offset.zero);

    final List<Offset> mostLikelyHitRegions = [
      initialPosition,
      renderBox.size.topCenter(Offset.zero),
      renderBox.size.bottomCenter(Offset.zero),
      renderBox.size.centerLeft(Offset.zero),
      renderBox.size.topLeft(Offset.zero),
      renderBox.size.bottomLeft(Offset.zero),
      renderBox.size.centerRight(Offset.zero),
      renderBox.size.topRight(Offset.zero),
      renderBox.size.bottomRight(Offset.zero),
    ];
    int iterations = 0;
    final firstPosition = renderBox.localToGlobal(initialPosition);
    final name = widgetSelector.toStringBreadcrumb();
    String successMessage(Offset location) {
      return 'Found interactable area of $name at $location.';
    }

    for (final localPosition in mostLikelyHitRegions) {
      if (iterations == 1) {
        // ignore: avoid_print
        print(
          "WARNING: Hit test at the center of $name, located at $firstPosition, failed. Attempting to identify and use an interactable area within the boundaries of $name.",
        );
      }
      final Offset globalPosition = renderBox.localToGlobal(localPosition);
      if (_canBePoked(
        position: globalPosition,
        target: renderBox,
        snapshot: snapshot,
      )) {
        if (globalPosition != firstPosition) {
          // ignore: avoid_print
          print(successMessage(globalPosition));
        }
        return globalPosition;
      }
      iterations++;
    }

    // No luck with the most likely hit regions, let's try a grid pattern
    final int horizontalSteps = (renderBox.size.width / 8).ceil();
    final int verticalSteps = (renderBox.size.height / 8).ceil();

    final List<Offset> checkOrder =
        _generateCheckOrder(horizontalSteps, verticalSteps);

    for (final gridPosition in checkOrder) {
      final Offset localPosition =
          Offset(gridPosition.dx * 8, gridPosition.dy * 8);
      if (localPosition.dx < renderBox.size.width &&
          localPosition.dy < renderBox.size.height) {
        final Offset globalPosition = renderBox.localToGlobal(localPosition);
        if (_canBePoked(
          position: globalPosition,
          target: renderBox,
          snapshot: snapshot,
        )) {
          if (globalPosition != firstPosition) {
            // ignore: avoid_print
            print(successMessage(globalPosition));
          }
          return globalPosition;
        }
      }
    }
    // ignore: avoid_print
    print(
      "WARNING: Failed to identify an interactable area within the boundaries of $name.",
    );

    return null;
  }

  List<Offset> _generateCheckOrder(int horizontalSteps, int verticalSteps) {
    final List<Offset> order = [];
    // Start with the center if it's an odd number of steps, add edge centers
    if (horizontalSteps % 2 != 0 && verticalSteps % 2 != 0) {
      order.add(
        Offset(
          (horizontalSteps ~/ 2).toDouble(),
          (verticalSteps ~/ 2).toDouble(),
        ),
      );
    }
    order.addAll([
      Offset.zero, // Top-left
      Offset(horizontalSteps - 1, 0), // Top-right
      Offset(0, verticalSteps - 1), // Bottom-left
      Offset(horizontalSteps - 1, verticalSteps - 1), // Bottom-right
    ]);
    // Zigzag through the grid to cover all positions in a skipping pattern
    for (int y = 0; y < verticalSteps; y++) {
      if (y.isEven) {
        for (int x = 0; x < horizontalSteps; x++) {
          order.add(Offset(x.toDouble(), y.toDouble()));
        }
      } else {
        for (int x = horizontalSteps - 1; x >= 0; x--) {
          order.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    return order;
  }

  /// Checks if the widget is visible and not covered by another widget
  ///
  /// This test fails when the widget does not react to hit tests
  bool _canBePoked({
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
        return true;
      }
    }
    return false;
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
