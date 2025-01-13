import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/act/gestures.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:spot/src/spot/element_extensions.dart';
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
  /// If a [Timeline] is running, an annotated screenshot, indicating the tap
  /// position, is added to the timeline.
  ///
  /// See also:
  /// - [Timeline]
  Future<void> tap(WidgetSelector selector) async {
    // Check if widget is in the widget tree. Throws if not.
    final snapshot = selector.snapshot()..existsOnce();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final renderBox = _getRenderBoxOrThrow(selector);

        // Before tapping the widget, we need to make sure that the widget is
        // not outside the viewport or covered by another widget.
        _validateViewBounds(renderBox, selector: selector);
        final pokablePositions = _findPokablePositions(renderBox);

        if (pokablePositions.hits.isEmpty) {
          final centerPosition =
              renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          _throwHitTestFailureReport(
            position: centerPosition,
            target: renderBox,
            snapshot: snapshot,
            actType: _ActType.tap,
          );
          return;
        }
        final partialWarning =
            _createPartialCoverageMessage(pokablePositions, snapshot);
        if (partialWarning != null) {
          // ignore: avoid_print
          print(partialWarning);
        }

        final positionToTap = pokablePositions.mostCenterHittablePosition!;
        final binding = TestWidgetsFlutterBinding.instance;

        if (timeline.mode != TimelineMode.off) {
          final screenshot = timeline.takeScreenshotSync(
            annotators: [
              CrosshairAnnotator(centerPosition: positionToTap),
            ],
          );
          final partial = partialWarning == null ? '' : '\n$partialWarning';
          timeline.addEvent(
            eventType: 'Tap Event',
            details: 'Tap ${selector.toStringBreadcrumb()}$partial',
            screenshot: screenshot,
            color: partialWarning == null ? Colors.blue : Colors.purple,
          );
        }

        // Finally, tap the widget by sending a down and up event.
        final downEvent = PointerDownEvent(position: positionToTap);
        binding.handlePointerEvent(downEvent);

        final upEvent = PointerUpEvent(position: positionToTap);
        binding.handlePointerEvent(upEvent);

        await binding.pump();
      });
    });
  }

  /// Taps the screen (down + up) at [position] on the global coordinate system
  /// and pumps a frame.
  ///
  /// - Checks that [position] is within the viewport.
  /// - Lists all widgets at that position in the timeline
  Future<void> tapAt(Offset position) async {
    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        final binding = TestWidgetsFlutterBinding.instance;
        _validatePositionInViewBounds(position);
        if (timeline.mode != TimelineMode.off) {
          final screenshot = timeline.takeScreenshotSync(
            annotators: [
              CrosshairAnnotator(centerPosition: position),
            ],
          );
          final HitTestResult result = HitTestResult();
          // ignore: deprecated_member_use
          binding.hitTest(result, position);
          final hits = result.path.map((e) => e.element).toList();

          final widgetInProject = hits.mapNotNull((e) {
            if (e == null) return null;
            final debugWidgetLocation = e.debugWidgetLocation;
            if (debugWidgetLocation == null ||
                debugWidgetLocation.isUserCode == false) {
              return null;
            }
            return "${e.widget.toStringShort()} at ${debugWidgetLocation.file.path}";
          }).joinToString(prefix: '\n- ');

          final allWidgets = hits.mapNotNull((e) {
            if (e == null) return null;
            return "${e.widget.toStringShort()} at ${e.debugWidgetLocation?.file.path}";
          }).joinToString(prefix: '\n- ');

          timeline.addEvent(
            eventType: 'TapAt Event',
            details: 'TapAt $position.\n'
                'Relevant widgets at position: $widgetInProject'
                '\n\n'
                'Widgets at position: $allWidgets',
            screenshot: screenshot,
            color: Colors.blue,
          );
        }
        final downEvent = PointerDownEvent(position: position);
        binding.handlePointerEvent(downEvent);
        final upEvent = PointerUpEvent(position: position);
        binding.handlePointerEvent(upEvent);
        await binding.pump();
      });
    });
  }

  /// Repeatedly drags at the position of `dragStart` by `moveStep` until `dragTarget` is visible.
  ///
  /// Between each drag, advances the clock by `duration`.
  ///
  /// Throws a [TestFailure] if `dragTarget` is not found after [maxIteration]
  /// drags. May drag one additional time after reaching [maxIteration] to place
  /// the target more visible in the viewport.
  ///
  /// Usage:
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
    final dragStartSnapshot = dragStart.snapshot()..existsOnce();
    _detectSizeZero(
      snapshot: dragStartSnapshot,
      actType: _ActType.drag,
    );

    // Take the closest Scrollable above the dragStart widget. This is the
    // widget which makes a widget scrollable. It must always exist.
    final WidgetSelector<Scrollable> scrollable =
        spot<Scrollable>().withChild(dragStart).last();

    // Every scrollable contains a Listener handling the touch events.
    // We only care about the size and location of the RenderObject.
    final scrollableSizedRenderBox =
        scrollable.spot<Listener>().first().snapshotRenderBox();

    return TestAsyncUtils.guard<void>(() async {
      return _alwaysPropagateDevicePointerEvents(() async {
        // Before dragging, we need to make sure that `dragStart` is
        // not outside the viewport or covered by another widget.
        final dragStartRenderBox = _getRenderBoxOrThrow(dragStart);
        _validateViewBounds(dragStartRenderBox, selector: dragStart);
        final dragStartRenderBoxRect = _globalRect(dragStartRenderBox);

        final binding = TestWidgetsFlutterBinding.instance;

        // Hit test the Scrollable at the location of dragStart. Do not check
        // dragStart directly, because it might not be hittable (IgnorePointer).
        final pokablePositionsAtDragStart = _findPokablePositions(
          scrollableSizedRenderBox,
          shouldBePoked: (local, Offset global) {
            return dragStartRenderBoxRect.contains(global);
          },
        );
        if (pokablePositionsAtDragStart.hits.isEmpty) {
          final Offset dragStartCenter = dragStartRenderBox
              .localToGlobal(dragStartRenderBox.size.center(Offset.zero));
          final closestToCenterFlop =
              pokablePositionsAtDragStart.flops.minBy((offset) {
            return (offset - dragStartCenter).distance;
          });

          _throwHitTestFailureReport(
            position: closestToCenterFlop ?? dragStartCenter,
            target: scrollableSizedRenderBox,
            snapshot: scrollable.snapshot(),
            actType: _ActType.drag,
          );
          return;
        }

        final partialWarning = _createPartialCoverageMessage(
          pokablePositionsAtDragStart,
          scrollable.snapshot(),
          isDragStart: true,
        );
        if (partialWarning != null) {
          // ignore: avoid_print
          print(partialWarning);
        }

        final targetName = dragTarget.toStringBreadcrumb();
        final dragBeginPosition =
            pokablePositionsAtDragStart.mostCenterHittablePosition!;

        void addDragEvent(String details, {Offset? direction}) {
          if (timeline.mode != TimelineMode.off) {
            final screenshot = timeline.takeScreenshotSync(
              annotators: [
                CrosshairAnnotator(centerPosition: dragBeginPosition),
                if (direction != null) ...[
                  ArrowAnnotator(
                    start: dragBeginPosition - const Offset(40, 0),
                    end: dragBeginPosition - const Offset(40, 0) + direction,
                  ),
                  ArrowAnnotator(
                    start: dragBeginPosition + const Offset(40, 0),
                    end: dragBeginPosition + const Offset(40, 0) + direction,
                  ),
                ],
              ],
            );
            timeline.addEvent(
              eventType: 'Drag Event',
              details: details,
              screenshot: screenshot,
              color: Colors.blue,
            );
          }
        }

        void addDragErrorEvent(String details, {Offset? direction}) {
          if (timeline.mode != TimelineMode.off) {
            final screenshot = timeline.takeScreenshotSync(
              annotators: [
                CrosshairAnnotator(centerPosition: dragBeginPosition),
                if (direction != null) ...[
                  ArrowAnnotator(
                    start: dragBeginPosition - const Offset(40, 0),
                    end: dragBeginPosition - const Offset(40, 0) + direction,
                  ),
                  ArrowAnnotator(
                    start: dragBeginPosition + const Offset(40, 0),
                    end: dragBeginPosition + const Offset(40, 0) + direction,
                  ),
                ],
              ],
            );
            timeline.addEvent(
              eventType: 'Drag Error Event',
              details: details,
              screenshot: screenshot,
              color: Colors.red,
            );
          }
        }

        final direction = () {
          if (moveStep.dx != 0 && moveStep.dy != 0) return 'diagonally';
          if (moveStep.dy < 0) return 'upwards';
          if (moveStep.dy > 0) return 'downwards';
          if (moveStep.dx > 0) return 'to the left';
          if (moveStep.dx < 0) return 'to the right';
          //TODO: Either throw or show warning
          return 'nowhere';
        }();

        addDragEvent(
          'Scrolling $direction beginning at $dragBeginPosition in order to find $targetName.',
          direction: moveStep,
        );

        bool targetFound() {
          final snapshot = dragTarget.snapshot();
          if (snapshot.discoveredElements.isNotEmpty) {
            dragTarget.existsOnce();
            return true;
          }
          return false;
        }

        // Now we begin to drag the scrollable until we find the target in the widget tree
        int dragCount = 0;
        while (!targetFound()) {
          if (dragCount >= maxIteration) {
            final totalDragged = moveStep * dragCount.toDouble();
            final message =
                "$targetName is not visible after dragging $dragCount times and a total dragged offset of $totalDragged.";
            addDragErrorEvent(message);
            throw TestFailure(message);
          }
          await gestures.drag(dragBeginPosition, moveStep);
          await binding.pump(duration);
          dragCount++;
        }

        // found the widget in the tree, now do a final drag to make sure it is fully visible
        final spotScrollableBoundsAfterDrag = spot<Scrollable>()
            .withChild(dragTarget)
            .last()
            .spot<Listener>()
            .first();
        final scrollableSizedRenderBoxAfterDrag =
            spotScrollableBoundsAfterDrag.snapshotRenderBox();
        final viewportGlobalPosition =
            scrollableSizedRenderBoxAfterDrag.localToGlobal(Offset.zero);
        final viewportRect = Rect.fromLTWH(
          viewportGlobalPosition.dx,
          viewportGlobalPosition.dy,
          scrollableSizedRenderBoxAfterDrag.size.width,
          scrollableSizedRenderBoxAfterDrag.size.height,
        );

        final targetRenderBox = dragTarget.snapshotRenderBox();
        final Offset globalTargetPositionTopLeft =
            targetRenderBox.localToGlobal(Offset.zero);
        final targetRect = Rect.fromLTWH(
          globalTargetPositionTopLeft.dx,
          globalTargetPositionTopLeft.dy,
          targetRenderBox.size.width,
          targetRenderBox.size.height,
        );

        final targetFullyVisible =
            viewportRect.contains(globalTargetPositionTopLeft) &&
                viewportRect.contains(targetRect.bottomRight);

        Offset finalDragOffset = Offset.zero;
        if (!targetFullyVisible) {
          // drag the target to the location of the dragStart widget (top right corner)
          final endDragLocation = dragStartRenderBoxRect.topLeft;
          final Offset distanceToEnd =
              endDragLocation - globalTargetPositionTopLeft;
          await gestures.drag(dragBeginPosition, distanceToEnd);
          await binding.pump(duration);
          finalDragOffset = distanceToEnd;
          addDragEvent(
            'Scrolling to fully reveal $targetName.',
            direction: distanceToEnd,
          );
        }

        final totalDragged = moveStep * dragCount.toDouble() + finalDragOffset;
        final message = "Target $targetName found after $dragCount drags. "
            "Total dragged offset: $totalDragged";
        addDragEvent(message);
      });
    });
  }
}

Rect _globalRect(RenderBox renderBox) {
  final position = renderBox.localToGlobal(Offset.zero);
  return Rect.fromLTWH(
    position.dx,
    position.dy,
    renderBox.size.width,
    renderBox.size.height,
  );
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

void _validatePositionInViewBounds(Offset position) {
  // ignore: deprecated_member_use
  final view = WidgetsBinding.instance.renderView;
  final Rect viewport = Offset.zero & view.size;
  final isInViewport = viewport.contains(position);
  if (!isInViewport) {
    throw TestFailure(
      "Tried to tapAt position ($position) which is outside the viewport (${view.size}).",
    );
  }
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
}

/// Throws a warning when the widget is only partially reacting to tap events
String? _createPartialCoverageMessage(
  _PokablePositions pokablePositions,
  WidgetSnapshot snapshot, {
  bool isDragStart = false,
}) {
  final roundUp = pokablePositions.percent.ceil();
  if (roundUp > 80) {
    // Don't be pedantic when the widget is almost fully tappable
    return null;
  }

  final messageHeader = () {
    final widgetAsString = snapshot.discoveredWidget!.toStringShort();
    if (isDragStart) {
      return "Warning: dragStart '$widgetAsString' is only partially reacting to drag events. ";
    } else {
      return "Warning: The '$widgetAsString' is only partially reacting to tap events. ";
    }
  }();
  // ignore: avoid_print
  return "$messageHeader"
      "Only ~$roundUp% of the widget reacts to hitTest events.\n"
      "\n"
      "Possible causes:\n"
      " - The widget is partially positioned out of view\n"
      " - It is covered by another widget.\n"
      " - It is too small (<8x8)\n"
      "\n"
      "Possible solutions:\n"
      " - Scroll the widget into view using act.dragUntilVisible()\n"
      " - Make sure no other Widget is overlapping on small screens\n"
      " - Increase the Widget size\n";
}

/// Checks if the widget is visible and not covered by another widget
///
/// This test fails when the widget does not react to hit tests
void _throwHitTestFailureReport({
  required Offset position,
  required RenderObject target,
  required WidgetSnapshot snapshot,
  required _ActType actType,
}) {
  final binding = WidgetsBinding.instance;

  // do the tap, hit test the position of [target]
  final HitTestResult result = HitTestResult();
  // ignore: deprecated_member_use
  binding.hitTest(result, position);
  final hitTestEntries = result.path.toList();

  final List<Element> hitTargetElements =
      hitTestEntries.mapNotNull((e) => e.element).toList();

  _detectAbsorbPointer(
    hitTarget: hitTargetElements.first,
    snapshot: snapshot,
    actType: actType,
  );
  _detectIgnorePointer(target: target, snapshot: snapshot, actType: actType);
  _detectSizeZero(snapshot: snapshot, actType: actType);
  _detectCoverWidget(
    target: target,
    snapshot: snapshot,
    hitTargetElements: hitTargetElements,
    actType: actType,
  );

  throw TestFailure(
    "Widget '${snapshot.discoveredWidget!.toStringShort()}' can not be ${actType.pastParticiple} at position $position where its RenderObject $target was found.\n"
    "The exact reason, why it doesn't receive hitTest events is unknown.\n"
    "If you think this case needs a a better error message, create an issue https://github.com/passsy/spot for anyone else running in a similar issue.\n"
    "A small example would be highly appreciated.",
  );
}

/// Throws when the widget is wrapped in an AbsorbPointer that is absorbing
/// the taps and doesn't forward them to the child
void _detectAbsorbPointer({
  required Element hitTarget,
  required WidgetSnapshot<Widget> snapshot,
  required _ActType actType,
}) {
  final childElement = hitTarget.children.firstOrNull;
  if (childElement?.widget is AbsorbPointer) {
    final absorbPointer = childElement!.widget as AbsorbPointer;
    if (absorbPointer.absorbing) {
      final location = childElement.debugWidgetLocation?.file.path ??
          childElement.debugGetCreatorChain(100);

      throw TestFailure(
        "Widget '${snapshot.discoveredWidget!.toStringShort()}' is wrapped in AbsorbPointer and doesn't receive ${actType.multiples}.\n"
        "AbsorbPointer is created at $location\n"
        "The closest widget reacting to the touch event is:\n"
        "${hitTarget.toStringDeep()}",
      );
    }
  }
}

/// Throws if the widget is wrapped in an IgnorePointer that is not forwarding events
void _detectIgnorePointer({
  required RenderObject target,
  required WidgetSnapshot<Widget> snapshot,
  required _ActType actType,
}) {
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
    final location = ignorePointer.debugWidgetLocation?.file.path ??
        targetElement.debugGetCreatorChain(100);
    throw TestFailure(
      "Widget '${snapshot.discoveredWidget!.toStringShort()}' is wrapped in IgnorePointer and doesn't receive ${actType.multiples}.\n"
      "The IgnorePointer is located at $location",
    );
  }
}

/// Detects when the widget is 0x0 pixels in size and throws a `TestFailure`
/// containing the widget that forces it to be 0x0 pixels.
void _detectSizeZero({
  required WidgetSnapshot<Widget> snapshot,
  required _ActType actType,
}) {
  final renderObject = snapshot.discoveredElement?.renderObject;
  if (renderObject == null) {
    return;
  }
  final renderBox = renderObject as RenderBox;
  final size = renderBox.size;
  if (size == Size.zero) {
    final parents = snapshot.discoveredElement?.parents.toList() ?? [];
    final parentsWithSizes = parents.map(
      (element) {
        final renderObject = element.renderObject;
        if (renderObject is RenderBox?) {
          return (renderObject?.size, element);
        }
        return (null, element);
      },
    ).toList();
    final Element shrinker =
        parentsWithSizes.reversed.firstWhere((it) => it.$1 == Size.zero).$2;

    throw TestFailure(
      "${snapshot.discoveredElement!.toStringShort()} can't be ${actType.pastParticiple} because it has size ${Size.zero}.\n"
      "${shrinker.toStringShort()} forces ${snapshot.discoveredElement!.toStringShort()} to have the size ${Size.zero}.\n"
      "${shrinker.toStringShort()} ${shrinker.debugWidgetLocation?.file.path}",
    );
  }
}

void _detectCoverWidget({
  required RenderObject target,
  required WidgetSnapshot<Widget> snapshot,
  required List<Element> hitTargetElements,
  required _ActType actType,
}) {
  final Element cover = hitTargetElements.first;
  final Element commonAncestor = findCommonAncestor(
    [hitTargetElements.first, snapshot.discoveredElement!],
  );
  final coverChain = cover
      .debugGetDiagnosticChain()
      .takeWhile((e) => e != commonAncestor)
      .toList();
  if (coverChain.isEmpty) {
    // no widget is covering the target,
    // target is child of the cover
    return;
  }

  final targetChain = snapshot.discoveredElement!
      .debugGetDiagnosticChain()
      .takeWhile((e) => e != commonAncestor)
      .toList();

  final commonAncestorChain = commonAncestor.debugGetDiagnosticChain();
  final usefulParents = commonAncestorChain.drop(1).where((e) {
    return e.debugWidgetLocation?.isUserCode ?? false;
  }).toList();

  // TODO find not only the first Widget constructor call, but actually the first widget class in the user code
  final firstUsefulParent =
      usefulParents.firstOrNull ?? commonAncestorChain.first;

  final usefulToTarget =
      targetChain.takeWhile((e) => e != firstUsefulParent).toList();

  final receiverColumn =
      "(Cover - Received ${actType.imperative} event)\n${coverChain.joinToString(separator: '\n', transform: (it) => it.toStringShort())}";
  final targetColumn =
      "(Target for ${actType.imperative}, below Cover)\n${usefulToTarget.joinToString(separator: '\n', transform: (it) => it.toStringShort())}";

  // create a string with two columns (max width 40), one for the receiver and one for the target
  String createColumns(String receiver, String target) {
    final receiverLines = receiver.split('\n');
    final targetLines = target.split('\n');
    final lines =
        receiverLines.length > targetLines.length ? receiverLines : targetLines;
    const columnWidth = 40;
    const columnSeparator = ' ';
    final buffer = StringBuffer();
    const empty = ' │';
    for (int i = 0; i < lines.length; i++) {
      final receiverLine = receiverLines.length > i ? receiverLines[i] : empty;
      final targetLine = targetLines.length > i ? targetLines[i] : empty;
      buffer.write(
        receiverLine.characters
            .take(columnWidth)
            .toString()
            .padRight(columnWidth),
      );
      buffer.write(columnSeparator);
      buffer.write(
        targetLine.characters
            .take(columnWidth)
            .toString()
            .padRight(columnWidth),
      );
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  final diagram = """
${createColumns(receiverColumn, targetColumn)}
 │ ┌──────────────────────────────────────┘
${commonAncestor.toStringShort().trimRight()} (${commonAncestor.debugWidgetLocation?.file.path})
${usefulParents.takeWhile((it) => it != firstUsefulParent).joinToString(separator: '\n', transform: (it) => it.toStringShort()).trimRight()}
${firstUsefulParent.toStringShort()} (${firstUsefulParent.debugWidgetLocation?.file.path})
""";
  throw TestFailure(
    "Widget '${snapshot.discoveredWidget!.toStringShort()}' can not be ${actType.pastParticiple} directly, because another widget (${cover.toStringShort()}) inside ${firstUsefulParent.toStringShort()} is completely covering it and consumes all ${actType.imperative} events.\n"
    "\n"
    "Try ${actType.presentParticiple} the ${firstUsefulParent.toStringShort()} which contains '${snapshot.discoveredWidget!.toStringShort()}' instead.\n\n"
    "Example:\n"
    "  // BAD: ${actType.multiples.capitalized} the Text inside ElevatedButton\n"
    "  WidgetSelector<AnyText> selector = spot<ElevatedButton>().spotText('${actType.imperative.capitalized} me');\n"
    "  await act.tap(selector);\n"
    "\n"
    "  // GOOD: ${actType.multiples.capitalized} the ElevatedButton which contains text '${actType.imperative.capitalized} me'\n"
    "  WidgetSelector<ElevatedButton> selector = spot<ElevatedButton>().withChild(spotText('${actType.imperative.capitalized} me'));\n"
    "  await act.tap(selector);\n"
    "\n"
    "${diagram.removeEmptyLines()}\n",
  );
}

/// Checks if the widget is visible and not covered by another widget
bool _canBePoked({
  required Offset position,
  required RenderObject target,
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

/// Attempts to find hittable position on the [snapshot] [RenderObject] using
/// an 8px grid.
///
/// It returns the results of the search as [_PokablePositions], including all
/// failed hit tests and a good estimate of a center point which is tappable
/// ([_PokablePositions.mostCenterHittablePosition]).
_PokablePositions _findPokablePositions(
  // WidgetSelector<Widget> widgetSelector,
  RenderBox renderBox, {
  bool Function(Offset local, Offset global)? shouldBePoked,
}) {
  // final RenderBox renderBox = _getRenderBoxOrThrow(widgetSelector);

  final List<Offset> hits = [];
  final List<Offset> flops = [];
  final List<Offset> skipped = [];
  const gridSize = 8;
  for (int x = 0; x < renderBox.size.width; x += gridSize) {
    for (int y = 0; y < renderBox.size.height; y += gridSize) {
      final Offset localPosition = Offset(x.toDouble(), y.toDouble());
      final Offset globalPosition = renderBox.localToGlobal(localPosition);
      final shouldPoke =
          shouldBePoked?.call(localPosition, globalPosition) ?? true;
      if (!shouldPoke) {
        skipped.add(globalPosition);
        continue;
      }
      final canBePoked =
          _canBePoked(position: globalPosition, target: renderBox);
      if (canBePoked) {
        hits.add(globalPosition);
      } else {
        flops.add(globalPosition);
      }
    }
  }

  final pos = renderBox.localToGlobal(Offset.zero);
  final searchArea = Rect.fromLTWH(
    pos.dx,
    pos.dy,
    renderBox.size.width,
    renderBox.size.height,
  );

  if (hits.isEmpty) {
    return _PokablePositions(
      searchArea: searchArea,
      hits: hits,
      flops: flops,
      skipped: skipped,
      target: renderBox,
    );
  }

  // Find a good point to actually tap the widget
  // When parts of the widget are covered (like the right side) the center is
  // the middle of the right side.
  // This only fails when there is a hole of tappable points in the middle (which rarely happens)
  final Offset centerOfPokablePoints = () {
    final maxX = hits.maxBy((e) => e.dx)!.dx;
    final minX = hits.minBy((e) => e.dx)!.dx;
    final maxY = hits.maxBy((e) => e.dy)!.dy;
    final minY = hits.minBy((e) => e.dy)!.dy;
    return Offset(
      ((maxX + minX) ~/ 2).toDouble(),
      ((maxY + minY) ~/ 2).toDouble(),
    );
  }();
  final centerCanBePoked =
      _canBePoked(position: centerOfPokablePoints, target: renderBox);
  final Offset? mostCenterPoint;
  if (centerCanBePoked) {
    mostCenterPoint = centerOfPokablePoints;
  } else {
    // this is point is already working, use it as fallback when the center
    // is not tappable
    mostCenterPoint =
        hits.minBy((e) => (e - centerOfPokablePoints).distanceSquared);
  }

  return _PokablePositions(
    searchArea: searchArea,
    hits: hits,
    flops: flops,
    skipped: skipped,
    target: renderBox,
    mostCenterHittablePosition: mostCenterPoint,
  );
}

/// Contains the result of hit testing an entire [RenderObject] in [_findPokablePositions]
class _PokablePositions {
  /// The area that was searched via hit testing
  final Rect searchArea;

  /// All points that where able to hit the [RenderObject]
  final List<Offset> hits;

  /// Points that where not able to hit the [RenderObject], but where inside [searchArea].
  ///
  /// Those points are covered by something and the [target] did not react
  final List<Offset> flops;

  /// All points that where skipped due to shouldBePoked returning false
  final List<Offset> skipped;

  /// The target that was used for hit testing
  final RenderBox target;

  /// The most center position that is hittable
  ///
  /// Returns null when no hittable position was found ([hits] is empty)
  final Offset? mostCenterHittablePosition;

  _PokablePositions({
    required this.searchArea,
    required this.hits,
    required this.flops,
    required this.skipped,
    required this.target,
    this.mostCenterHittablePosition,
  });

  /// The percentage (0-100%) of positions that were hittable
  double get percent => hits.length / (hits.length + flops.length) * 100;
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
Future<T> _alwaysPropagateDevicePointerEvents<T>(
  FutureOr<T> Function() block,
) async {
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
    return await block();
  } finally {
    if (live) {
      binding.shouldPropagateDevicePointerEvents = previousPropagateValue;
    }
  }
}

/// Grants access to the location of a Widget via [WidgetInspectorService]
extension WidgetLocationExt on Element {
  /// Returns where the widget was created in code
  WidgetLocation? get debugWidgetLocation {
    try {
      final delegate = InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
      );
      final json = toDiagnosticsNode().toJsonMap(delegate);
      final creationLocation =
          json['creationLocation'] as Map<String, Object?>?;
      final file = creationLocation!['file'] as String?;
      final line = creationLocation['line'] as int?;
      final column = creationLocation['column'] as int?;
      final String location1 = '$file:$line:$column';
      final createdByLocalProject = json['createdByLocalProject'] as bool?;

      return WidgetLocation(
        file: File(location1),
        createdByLocalProject: createdByLocalProject,
      );
    } catch (e) {
      return null;
    }
  }
}

/// The location on the users filesystem where a Widget constructor was called
class WidgetLocation {
  /// The pointer to the file
  final File file;

  /// True when the [WidgetInspectorService] reports that the location is
  /// - not within an external package
  /// - not within the dart or flutter sdk
  final bool? createdByLocalProject;

  /// Creates a new [WidgetLocation]
  WidgetLocation({
    required this.file,
    required this.createdByLocalProject,
  });

  /// Returns true, when the location is relevant for error messages, because
  /// it is within the users project
  bool get isUserCode {
    if (file.path.contains('packages/flutter/')) {
      return false;
    }
    if (createdByLocalProject != null) {
      return createdByLocalProject!;
    }
    return true;
  }

  @override
  String toString() {
    return 'WidgetLocation{userCode: $isUserCode, ${file.name}';
  }
}

extension on String {
  String removeEmptyLines() {
    return split('\n').where((line) => line.trim().isNotEmpty).join('\n');
  }
}

/// Recursively searches for the first Element whose `renderObject` is a `RenderBox`.
Element? _findFirstDescendantElementWithRenderBox(Element element) {
  // If this element’s renderObject is a RenderBox, we’re done.
  if (element.renderObject is RenderBox) {
    return element;
  }

  // Otherwise, search each child recursively.
  for (final Element child in element.children) {
    final match = _findFirstDescendantElementWithRenderBox(child);
    if (match != null) {
      return match;
    }
  }
  return null;
}

enum _ActType {
  tap(
    imperative: 'tap',
    presentParticiple: 'tapping',
    pastParticiple: 'tapped',
    multiples: 'taps',
  ),
  drag(
    imperative: 'drag',
    presentParticiple: 'dragging',
    pastParticiple: 'dragged',
    multiples: 'drags',
  );

  const _ActType({
    required this.multiples,
    required this.imperative,
    required this.presentParticiple,
    required this.pastParticiple,
  });

  final String multiples;
  final String imperative;
  final String presentParticiple;
  final String pastParticiple;
}

extension on String {
  String get capitalized {
    if (this.isEmpty || length == 1) return toUpperCase();
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
