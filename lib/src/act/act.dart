import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/act/act_tap.dart';
import 'package:spot/src/act/gestures.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:spot/src/spot/widget_location.dart';

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
  /// By default the field is tapped the way a real user would tap it before the
  /// text is entered. The tap goes through the same hit-test validation as
  /// [tap], so this throws if the field is outside the viewport or covered by
  /// another widget (e.g. an overlay or an on-screen keyboard). This makes the
  /// test fail when the field could not actually be reached by a user.
  ///
  /// Set [bypassHitTest] to `true` to skip the tap and force-focus the field by
  /// reaching directly into the widget tree. This fills the field even when it
  /// is not reachable, which is occasionally useful to seed state for a field
  /// that is not the subject of the test. Prefer the default whenever the
  /// field's reachability is part of what you are testing.
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
  Future<void> enterText(
    WidgetSelector selector,
    String text, {
    bool bypassHitTest = false,
  }) async {
    // Check if widget is in the widget tree. Throws if not.
    selector.snapshot().existsOnce();

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

    // A read-only field (e.g. a disabled or readOnly TextField) can not receive
    // input on any path: tapping it produces a generic hit-test failure, and
    // bypassing the hit test only results in a silent no-op. Surface a clear
    // reason instead.
    if (editableTextState.widget.readOnly) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is read-only and can not "
        'receive text input. This is usually caused by a disabled or '
        'read-only TextField. To set its content, assign it through the '
        "field's TextEditingController instead.",
      );
    }

    if (!bypassHitTest && !editableTextState.widget.focusNode.hasFocus) {
      // A real user does not always tap a field to focus it - it may already be
      // focused via the keyboard or autofocus. Only when it isn't focused yet do
      // we tap it the way a user would. The tap also validates that the field is
      // actually hittable (not off-screen or covered) and focuses it, which in
      // turn requests the keyboard and attaches the text input connection.
      await tap(editableText);
    }

    return await TestAsyncUtils.guard<void>(() async {
      final binding = TestWidgetsFlutterBinding.instance;

      if (bypassHitTest) {
        // Setting focusedEditable causes the binding to call requestKeyboard()
        // on the EditableTextState, which itself eventually calls
        // TextInput.attach to establish the connection.
        binding.focusedEditable = editableTextState;
        await binding.pump();
      }

      if (!kIsWeb) {
        // Fix for enterText() not working in release mode on real iOS devices.
        // See https://github.com/flutter/flutter/pull/89703
        // Also a fix for enterText() not being able to interact with the same
        // textfield 2 times in the same test.
        // See https://github.com/flutter/flutter/issues/134604
        binding.testTextInput.register();
      }

      binding.testTextInput.enterText(text);
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
    final RenderBox renderBox;
    try {
      renderBox = snapshot.discoveredRenderBox;
    } catch (_) {
      debugPrint(
        'Spot does not know how to hit test a non-cartesian coordinate system.',
      );
      rethrow;
    }

    return await TestAsyncUtils.guard<void>(() async {
      return await alwaysPropagateDevicePointerEvents(() async {
        // Before tapping the widget, we need to make sure that the widget is
        // not outside the viewport or covered by another widget.
        throwIfOutsideViewport(snapshot: snapshot, renderBox: renderBox);
        final pokablePositions = findPokablePositions(renderBox);

        if (pokablePositions.hits.isEmpty) {
          final centerPosition =
              renderBox.localToGlobal(renderBox.size.center(Offset.zero));
          throwTapFailureReport(
            position: centerPosition,
            target: renderBox,
            snapshot: snapshot,
          );
          return;
        }
        final partialWarning =
            createPartialCoverageMessage(pokablePositions, snapshot);
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

        // Finally, tap the widget by sending a down and up event. Use a fresh
        // pointer id, because reusing an id (like the default 0) joins the
        // gesture arena of a previous gesture with the same id, where the tap
        // can lose against a stale winner and get silently swallowed.
        final gesture = await gestures.startGesture(positionToTap);
        await gesture.up();

        await binding.pump();
      });
    });
  }

  /// Answers whether [selector] can be tapped, and why not, without tapping it.
  ///
  /// Sends no pointer events and pumps no frame, so the app is in the same
  /// state afterwards. That makes it the way to assert untappability:
  /// [Act.tap] proves a widget cannot be tapped by failing the test, which is
  /// the opposite of what an assertion needs.
  ///
  /// ```dart
  /// final inspection = act.inspectTap(spot<SubmitButton>());
  /// expect(inspection.canTap, isFalse);
  /// ```
  ///
  /// [TapInspection.tapFailure] is `null` when the widget can be tapped,
  /// otherwise it carries the reason. Read it untyped via
  /// [TapFailureReason.reason], or through a typed getter that fails the test
  /// with the full diagnostics when the widget turned out to be untappable for
  /// a different reason than expected:
  ///
  /// ```dart
  /// final reason = act.inspectTap(spot<SubmitButton>())
  ///     .tapFailure!
  ///     .tapCoveredReason;
  /// expect(reason.primaryCover?.widget, isA<ColoredBox>());
  /// ```
  ///
  /// The reasons are [TapNotFoundReason], [TapMultipleWidgetsFoundReason],
  /// [TapNoRenderObjectReason], [TapNonRenderBoxReason],
  /// [TapOutsideViewportReason], [TapAbsorbedReason], [TapIgnoredReason],
  /// [TapOffstageReason], [TapZeroSizeReason], [TapCoveredReason] and
  /// [TapUnknownReason]. Each one carries the widgets that explain it, such as
  /// the [AbsorbPointer] that swallowed the event or the ancestor that forced
  /// the target to zero size.
  ///
  /// A widget that can be tapped may still be partially covered, which no
  /// failure can describe. [TapInspection.samples] answers that for tappable
  /// and untappable widgets alike:
  ///
  /// ```dart
  /// final samples = act.inspectTap(spot<SubmitButton>()).samples!;
  /// expect(samples.hittablePercent, 100);
  /// expect(samples.blockers, isEmpty);
  /// ```
  ///
  /// The result describes the frame it was taken in and does not update when a
  /// frame is pumped, see [TapInspection]. [Act.tap] throws a [TapFailure]
  /// carrying the same inspection, so the reason of a real tap can be asserted
  /// the same way.
  TapInspection inspectTap(WidgetSelector selector) {
    return inspectTapSelector(selector);
  }

  /// Taps the screen (down + up) at [position] on the global coordinate system
  /// and pumps a frame.
  ///
  /// - Checks that [position] is within the viewport.
  /// - Lists all widgets at that position in the timeline
  Future<void> tapAt(Offset position) async {
    return await TestAsyncUtils.guard<void>(() async {
      return await alwaysPropagateDevicePointerEvents(() async {
        final binding = TestWidgetsFlutterBinding.instance;
        _validatePositionInViewBounds(position);
        if (timeline.mode != TimelineMode.off) {
          final screenshot = timeline.takeScreenshotSync(
            annotators: [
              CrosshairAnnotator(centerPosition: position),
            ],
          );
          final hitTest = hitTestWidgetsAt(position);

          final widgetInProject = hitTest.path.mapNotNull((it) {
            final debugWidgetLocation = it.element.debugWidgetLocation;
            if (debugWidgetLocation == null ||
                debugWidgetLocation.isUserCode == false) {
              return null;
            }
            return "${it.widgetName} at ${debugWidgetLocation.file.path}";
          }).joinToString(prefix: '\n- ');

          final allWidgets = hitTest.path.map((it) {
            final location = it.element.debugWidgetLocation;
            return "${it.widgetName} at ${location?.file.path}";
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
        // Use a fresh pointer id, see Act.tap for why pointer 0 must not be
        // reused.
        final gesture = await gestures.startGesture(position);
        await gesture.up();
        await binding.pump();
      });
    });
  }

  /// Repeatedly drags at the position of [dragStart] towards the end of the list
  /// until [dragTarget] is visible.
  ///
  /// Between each drag, advances the clock by [duration].
  ///
  /// [moveStep] is the distance to drag in each iteration. If not provided, the
  /// default value is half the height or width of the scrollable (depending on
  /// its axis). For example, use `moveStep: const Offset(0, -100)` to scroll
  /// 100 pixels upward.
  ///
  /// If [moveStep] is not provided, the method automatically drags towards the
  /// end of the `Scrollable` by default. Provide [toStart] as `true` if you want
  /// to drag towards the start of the `Scrollable`.
  ///
  /// Throws a [TestFailure] if [dragTarget] is not found after [maxIteration]
  /// drags. May drag one additional time after reaching [maxIteration] to place
  /// the target more squarely in the viewport.
  ///
  /// [fallbackScrollableSelector] is an optional backup in case the scrollable that
  /// originally contained [dragStart] becomes undiscoverable during the drag
  /// (for example, if its keys get swapped). Providing this fallback can help avoid
  /// test failures in dynamic layouts, ensuring the final checks can still succeed.
  ///
  /// [padding] defines areas within the scrollable that should be avoided during
  /// dragging. The target will not be positioned within the padding when scrolling is complete.
  /// This is useful for avoiding fixed headers, footers, or other UI elements that
  /// overlap the scrollable content.
  ///
  /// Usage:
  /// ```dart
  /// final firstItem = spotText('Item at index: 0')..existsOnce();
  /// final secondItem = spotText('Item at index: 27')..doesNotExist();
  /// await act.dragUntilVisible(
  ///   dragStart: firstItem,
  ///   dragTarget: secondItem,
  /// );
  /// secondItem.existsOnce();
  /// ```
  Future<void> dragUntilVisible({
    required WidgetSelector<Widget> dragStart,
    required WidgetSelector<Widget> dragTarget,
    Offset? moveStep,
    int maxIteration = 50,
    Duration duration = const Duration(milliseconds: 50),
    bool toStart = false,
    WidgetSelector<Scrollable>? fallbackScrollableSelector,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    assert(
      !(moveStep != null && toStart),
      'You can either provide `moveStep`, or set `toStart` to true, or neither, '
      'but not both.',
    );

    if (moveStep != null) {
      assert(
        (moveStep.dx != 0) ^ (moveStep.dy != 0),
        'If `moveStep` is provided, one of dx or dy must be non-zero. '
        'Both dx and dy being 0 results in no dragging. '
        'Both being non-zero implicates diagonal dragging, which is not supported.',
      );
    }

    // Check if widget is in the widget tree. Throws if not.
    final dragStartSnapshot = dragStart.snapshot()..existsOnce();
    throwIfZeroSize(snapshot: dragStartSnapshot);

    final WidgetSelector<Scrollable> scrollable = () {
      final element = dragStartSnapshot.discoveredElement!;
      if (element.widget is Scrollable) {
        return spotElement<Scrollable>(element);
      }
      return spot<Scrollable>().withChild(dragStart).last();
    }();

    // Save the 'Element' of the currently targeted Scrollable.
    // This ensures that—even if multiple scrollables exist or the
    // widget tree changes—we’ll be able to re-spot and reliably
    // refer back to this exact same scrollable later.
    final scrollableElement = scrollable.snapshotElement();

    // Every scrollable contains a Listener handling the touch events.
    // We only care about the size and location of the RenderObject.
    final scrollableSizedRenderBox =
        scrollable.spot<Listener>().first().snapshotRenderBox();

    return TestAsyncUtils.guard<void>(() async {
      return await alwaysPropagateDevicePointerEvents(() async {
        // Before dragging, we need to make sure that `dragStart` is
        // not outside the viewport or covered by another widget.
        final dragStartRenderBox = dragStart.snapshotRenderBox();
        validateViewBounds(dragStartRenderBox, selector: dragStart);
        final dragStartRenderBoxRect = dragStartRenderBox.globalRect;

        final binding = TestWidgetsFlutterBinding.instance;

        // Hit test the Scrollable at the location of dragStart. Do not check
        // dragStart directly, because it might not be hittable (IgnorePointer).
        final pokablePositionsAtDragStart = findPokablePositions(
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

          throwHitTestFailureReport(
            position: closestToCenterFlop ?? dragStartCenter,
            target: scrollableSizedRenderBox,
            snapshot: scrollable.snapshot(),
          );
          return;
        }

        final partialWarning = createPartialCoverageMessage(
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

        void addDragEvent(
          String details, {
          Offset? direction,
          Offset? origin,
        }) {
          if (timeline.mode != TimelineMode.off) {
            final crosshair = origin ?? dragBeginPosition;
            final screenshot = timeline.takeScreenshotSync(
              annotators: [
                CrosshairAnnotator(centerPosition: crosshair),
                if (direction != null) ...[
                  ArrowAnnotator(
                    start: crosshair - const Offset(40, 0),
                    end: crosshair - const Offset(40, 0) + direction,
                  ),
                  ArrowAnnotator(
                    start: crosshair + const Offset(40, 0),
                    end: crosshair + const Offset(40, 0) + direction,
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

        final scrollAxis = scrollable.snapshotWidget().axis;

        final moveOffset = moveStep ??= () {
          if (scrollAxis == Axis.vertical) {
            final autoScrollHeight = scrollableSizedRenderBox.size.height / 2;
            final dy = toStart ? autoScrollHeight : -autoScrollHeight;
            return Offset(0, dy);
          } else {
            final autoScrollWidth = scrollableSizedRenderBox.size.width / 2;
            final dx = toStart ? autoScrollWidth : -autoScrollWidth;
            return Offset(dx, 0);
          }
        }();

        final direction = () {
          if (moveOffset.dy < 0) return 'to the end';
          if (moveOffset.dy > 0) return 'to the start';
          if (moveOffset.dx < 0) return 'to the end';
          if (moveOffset.dx > 0) return 'to the start';
        }();

        addDragEvent(
          'Scrolling $direction, beginning at $dragBeginPosition in order to find $targetName.',
          direction: moveOffset,
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
            final totalDragged = moveOffset * dragCount.toDouble();
            final message =
                "$targetName is not visible after dragging $dragCount times and a total dragged offset of $totalDragged.";
            addDragErrorEvent(message);
            throw TestFailure(message);
          }
          await gestures.drag(dragBeginPosition, moveOffset);
          await binding.pump(duration);
          dragCount++;
        }

        // Use the saved 'scrollableElement' to look up the exact same
        // Scrollable we started with, rather than picking any Scrollable in
        // the tree. This guarantees that our final alignment calculations
        // run against the very same Scrollable we just finished dragging.
        Widget? scrollableWidget = spot<Scrollable>()
            .snapshot()
            .discovered
            .firstOrNullWhere((e) => e.element == scrollableElement)
            ?.element
            .widget;

        if (scrollableWidget == null) {
          if (fallbackScrollableSelector == null) {
            // ignore: avoid_print
            print(
              'Warning: Could not find the original scrollable widget anymore, and no '
              'fallback was provided. Skipping final bounding-box check. '
              'Possibly the widget tree changed or its keys were swapped.',
            );
            return;
          } else {
            final fallbackWidget =
                fallbackScrollableSelector.snapshot().discoveredWidget;
            if (fallbackWidget == null) {
              // ignore: avoid_print
              print(
                'Warning: Could not find the provided fallback scrollable either. '
                'Skipping final bounding-box check.',
              );
              return;
            } else {
              scrollableWidget = fallbackWidget;
            }
          }
        }

        // Found the widget in the tree, now do a final drag to make sure it is
        // within the scrollable's viewport entirely
        final spotScrollableBoundsAfterDrag = spotWidget(scrollableWidget);

        final scrollableSizedRenderBoxAfterDrag =
            spotScrollableBoundsAfterDrag.snapshotRenderBox();
        final viewportGlobalPosition =
            scrollableSizedRenderBoxAfterDrag.localToGlobal(Offset.zero);
        final fullViewportRect = Rect.fromLTWH(
          viewportGlobalPosition.dx,
          viewportGlobalPosition.dy,
          scrollableSizedRenderBoxAfterDrag.size.width,
          scrollableSizedRenderBoxAfterDrag.size.height,
        );

        // Account for padding when determining the usable viewport area
        final viewportRect = Rect.fromLTRB(
          fullViewportRect.left + padding.left,
          fullViewportRect.top + padding.top,
          fullViewportRect.right - padding.right,
          fullViewportRect.bottom - padding.bottom,
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

        final targetFullyInViewport =
            viewportRect.contains(globalTargetPositionTopLeft) &&
                viewportRect.contains(targetRect.bottomRight);

        Offset finalDragOffset = Offset.zero;
        if (!targetFullyInViewport) {
          // Calculate the desired end location, respecting padding
          final Offset endDragLocation;
          if (scrollAxis == Axis.vertical) {
            // Position target at top of usable viewport (excluding padding)
            endDragLocation = Offset(
              globalTargetPositionTopLeft.dx,
              viewportRect.top,
            );
          } else {
            // Position target at left of usable viewport (excluding padding)
            endDragLocation = Offset(
              viewportRect.left,
              globalTargetPositionTopLeft.dy,
            );
          }

          final Offset fullDistanceToEnd =
              endDragLocation - globalTargetPositionTopLeft;

          // Only drag in the direction of the scroll axis, never diagonal
          final Offset distanceToEnd;
          if (scrollAxis == Axis.vertical) {
            distanceToEnd = Offset(0, fullDistanceToEnd.dy);
          } else {
            distanceToEnd = Offset(fullDistanceToEnd.dx, 0);
          }

          // Ensure the drag is always recognized as a drag gesture, not a tap
          if (distanceToEnd.distance >= kDragSlopDefault) {
            // Distance is large enough, drag directly
            await gestures.drag(dragBeginPosition, distanceToEnd);
            await binding.pump(duration);
            finalDragOffset = distanceToEnd;
            addDragEvent(
              'Scrolling to fully reveal $targetName.',
              direction: distanceToEnd,
            );
          } else if (distanceToEnd.distance > 0) {
            // Distance is too small, overshoot then return to ensure drag recognition, not a tap.
            const overshootDistance = kDragSlopDefault + 1;
            final direction = distanceToEnd / distanceToEnd.distance;

            // The second gesture starts at dragBeginPosition + overshootOffset.
            // It must be hittable on the scrollable AND outside the padded
            // strip, so it never lands in an obscured area like a fixed
            // header/footer. Try the natural overshoot direction; if its
            // origin lies in the padded strip, flip the direction; if even
            // the flipped origin is unsafe (very thin visible band), search
            // along the dragBegin → preferred-end line, then fall back to a
            // full 8 px grid scan of the scrollable.
            Offset overshootOffset = direction * overshootDistance;
            Offset secondGestureOrigin = dragBeginPosition + overshootOffset;
            if (!canBePoked(
              position: secondGestureOrigin,
              target: scrollableSizedRenderBoxAfterDrag,
              insideArea: viewportRect,
            )) {
              overshootOffset = -overshootOffset;
              secondGestureOrigin = dragBeginPosition + overshootOffset;
            }
            if (!canBePoked(
              position: secondGestureOrigin,
              target: scrollableSizedRenderBoxAfterDrag,
              insideArea: viewportRect,
            )) {
              // Walk the line from dragBeginPosition toward the preferred
              // origin, closest-to-preferred first, and pick the first safe
              // point. dragBeginPosition itself is always safe (the earlier
              // findPokablePositions ensured that), so the search always
              // finds at least that as a fallback.
              secondGestureOrigin = _findPokablePosition(
                scrollable: scrollableSizedRenderBoxAfterDrag,
                paddedViewport: viewportRect,
                priorityPoints: _lineSamples(
                  dragBeginPosition,
                  secondGestureOrigin,
                ),
              )!;
            }
            final returnOffset = overshootOffset - distanceToEnd;

            // First drag: overshoot the target
            await gestures.drag(dragBeginPosition, overshootOffset);
            await binding.pump(duration);
            addDragEvent(
              'Overshoot drag (1/2) to fully reveal $targetName.',
              direction: overshootOffset,
            );

            // Second drag: return to the correct position
            await gestures.drag(secondGestureOrigin, -returnOffset);
            await binding.pump(duration);
            addDragEvent(
              'Return drag (2/2) to fully reveal $targetName.',
              direction: -returnOffset,
              origin: secondGestureOrigin,
            );

            finalDragOffset = distanceToEnd;
          }
        }

        final totalDragged =
            moveOffset * dragCount.toDouble() + finalDragOffset;
        final message = "Target $targetName found after $dragCount drags. "
            "Total dragged offset: $totalDragged";
        addDragEvent(message);
      });
    });
  }
}

void _validatePositionInViewBounds(Offset position) {
  // ignore: deprecated_member_use
  final view = WidgetsBinding.instance.renderView;
  final Rect viewport = Offset.zero & view.size;
  final isInViewport = viewport.contains(position);
  if (!isInViewport) {
    throw TestFailure(
      "Point of interaction (${position.dx}, ${position.dy}) is outside the viewport (${view.size.width}, ${view.size.height}). "
      "Humans can not interact with this point.",
    );
  }
}

/// Returns the first point in [priorityPoints] that is hittable on
/// [scrollable] AND inside [paddedViewport]. Returns null if no candidate
/// qualifies. Callers should include a known-safe fallback (e.g. the
/// original [dragBeginPosition]) at the end of [priorityPoints].
Offset? _findPokablePosition({
  required RenderBox scrollable,
  required Rect paddedViewport,
  required List<Offset> priorityPoints,
}) {
  for (final candidate in priorityPoints) {
    if (canBePoked(
      position: candidate,
      target: scrollable,
      insideArea: paddedViewport,
    )) {
      return candidate;
    }
  }
  return null;
}

/// Returns the points of the line from [from] to [to] in [gridSize] steps,
/// ordered from [to] back to [from] (closest-to-[to] first).
List<Offset> _lineSamples(Offset from, Offset to, {int gridSize = 8}) {
  final delta = to - from;
  final steps = (delta.distance / gridSize).ceil();
  if (steps == 0) return [from];
  return [
    for (int i = steps; i >= 0; i--) from + delta * (i / steps),
  ];
}

/// Makes sure that the device pointer events are always propagated to the
/// widgets and are not intercepted by [LiveTestWidgetsFlutterBinding].
///
/// See [LiveTestWidgetsFlutterBinding.shouldPropagateDevicePointerEvents].
Future<T> alwaysPropagateDevicePointerEvents<T>(
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
