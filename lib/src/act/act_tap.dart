import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
// Imported so the [Act.tap] and [Act.inspectTap] doc references below resolve.
// act.dart imports this file for the implementation, never the other way round.
import 'package:spot/src/act/act.dart';
import 'package:spot/src/spot/element_extensions.dart';
import 'package:spot/src/spot/selectors.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/widget_location.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Inspects whether [selector] can be tapped.
///
/// This does not send pointer events and does not pump a frame.
TapInspection inspectTapSelector(WidgetSelector selector) {
  final selectorDescription = selector.toStringBreadcrumb();
  final snapshot = selector.snapshot();
  final discoveredElements = snapshot.discoveredElements;

  if (discoveredElements.isEmpty) {
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: null,
      reason: TapNotFoundReason(
        selectorDescription: selectorDescription,
      ),
      message: 'Could not find $selectorDescription in widget tree',
    );
  }

  if (discoveredElements.length > 1) {
    final matches = discoveredElements.map(_tapWidgetInfo).toList();
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: null,
      reason: TapMultipleWidgetsFoundReason(
        selectorDescription: selectorDescription,
        matches: matches,
      ),
      message:
          'Found ${discoveredElements.length} elements matching $selectorDescription in widget tree',
    );
  }

  final targetElement = discoveredElements.single;
  final target = _tapWidgetInfo(targetElement);
  final renderObject = targetElement.renderObject;
  if (renderObject == null) {
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: target,
      reason: TapNoRenderObjectReason(),
      message:
          "Widget '$selectorDescription' has no associated RenderObject.\n",
    );
  }

  if (renderObject is! RenderBox) {
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: target,
      reason: TapNonRenderBoxReason(
        renderObject: renderObject,
      ),
      message:
          "Widget '$selectorDescription' is associated to $renderObject which "
          "is not a RenderObject in the 2D Cartesian coordinate system "
          "(implements RenderBox).",
    );
  }

  final outsideViewportFailure = _inspectViewBounds(
    selectorDescription: selectorDescription,
    target: target,
    renderBox: renderObject,
  );
  if (outsideViewportFailure != null) {
    return outsideViewportFailure;
  }

  // The cheap search decides whether the widget can be tapped. Collecting the
  // per-sample hit-test paths costs an order of magnitude more and is only
  // paid for when someone reads TapInspection.samples.
  final pokablePositions = findPokablePositions(renderObject);
  TapSamples collectSamples() => _collectSamples(renderObject);

  if (pokablePositions.hits.isEmpty) {
    final centerPosition =
        renderObject.localToGlobal(renderObject.size.center(Offset.zero));
    return _inspectUntappableTarget(
      selectorDescription: selectorDescription,
      target: target,
      targetElement: targetElement,
      renderBox: renderObject,
      position: centerPosition,
      samples: collectSamples,
    );
  }

  return TapInspection._(
    selectorDescription: selectorDescription,
    target: target,
    samples: collectSamples,
    tapPosition: pokablePositions.mostCenterHittablePosition,
    message: null,
    tapFailure: null,
  );
}

/// Throws a [TapFailure] when the target of [snapshot] is outside the viewport.
///
/// Unlike [validateViewBounds] this reports the failure as a [TapInspection],
/// so a caller of [Act.tap] can read the reason instead of the message.
void throwIfOutsideViewport({
  required WidgetSnapshot snapshot,
  required RenderBox renderBox,
}) {
  final targetElement = snapshot.discoveredElement;
  if (targetElement == null) {
    validateViewBounds(renderBox, selector: snapshot.selector);
    return;
  }
  final failure = _inspectViewBounds(
    selectorDescription: snapshot.selector.toStringBreadcrumb(),
    target: _tapWidgetInfo(targetElement),
    renderBox: renderBox,
  );
  if (failure != null) {
    throw TapFailure(failure);
  }
}

/// Throws when the widget is not at least partially located in the viewport.
void validateViewBounds(
  RenderBox renderBox, {
  required WidgetSelector selector,
}) {
  final bounds = _viewBoundsOf(renderBox);
  if (bounds.isOutside) {
    throw TestFailure(bounds.messageFor(selector.toStringBreadcrumb()));
  }
  // TODO handle case when location is partially outside viewport
}

/// Where a widget sits relative to the viewport.
///
/// Shared by the throwing [validateViewBounds] and the reporting
/// [_inspectViewBounds] so both agree on what "outside the viewport" means and
/// phrase it the same way.
class _ViewBounds {
  _ViewBounds({required this.viewport, required this.targetRect});

  /// The visible area of the view, in global coordinates.
  final Rect viewport;

  /// Where the target is, in the same coordinates as [viewport].
  final Rect targetRect;

  /// Whether the target does not overlap the viewport at all.
  bool get isOutside {
    final intersection = viewport.intersect(targetRect);
    return intersection.width < 0 || intersection.height < 0;
  }

  /// The part of the target that is inside the viewport.
  Rect get visibleRect {
    final intersection = viewport.intersect(targetRect);
    return intersection.isEmpty ? Rect.zero : intersection;
  }

  /// How much of the target is inside the viewport, from `0` to `1`.
  double get visibleFraction {
    final targetArea = targetRect.width * targetRect.height;
    if (targetArea <= 0) {
      return 0;
    }
    final visible = visibleRect;
    return visible.width * visible.height / targetArea;
  }

  /// The failure text, identical whether it is thrown or reported.
  String messageFor(String selectorDescription) {
    return "Widget '$selectorDescription' is located outside the viewport "
        '($targetRect).';
  }
}

/// Where [renderBox] sits relative to the view it is rendered into.
_ViewBounds _viewBoundsOf(RenderBox renderBox) {
  // ignore: deprecated_member_use
  final view = WidgetsBinding.instance.renderView;
  return _ViewBounds(
    viewport: Offset.zero & view.size,
    targetRect:
        renderBox.localToGlobal(Offset.zero) & renderBox.paintBounds.size,
  );
}

/// Throws a warning when the widget is only partially reacting to tap events.
String? createPartialCoverageMessage(
  PokablePositions pokablePositions,
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

/// Throws a [TapFailure] with the analysis [inspectTapSelector] would produce.
///
/// Only for [Act.tap]. Gestures that are not a tap throw through
/// [throwHitTestFailureReport], which reports the same message without claiming
/// a tap was attempted.
void throwTapFailureReport({
  required Offset position,
  required RenderObject target,
  required WidgetSnapshot snapshot,
}) {
  final failure = _inspectHitTestFailure(
    position: position,
    target: target,
    snapshot: snapshot,
  );
  if (failure != null) {
    throw TapFailure(failure);
  }
  throw TestFailure(_unknownHitTestMessage(position, target, snapshot));
}

/// Throws the same tap failure message produced by [inspectTapSelector].
///
/// Throws a plain [TestFailure]. [Act.dragUntilVisible] hit tests the widget it
/// wants to start the drag on, which is not a tap, so a [TapFailure] carrying a
/// [TapInspection] of a different widget would be a lie.
void throwHitTestFailureReport({
  required Offset position,
  required RenderObject target,
  required WidgetSnapshot snapshot,
}) {
  final failure = _inspectHitTestFailure(
    position: position,
    target: target,
    snapshot: snapshot,
  );
  if (failure != null) {
    throw TestFailure(failure.message);
  }
  throw TestFailure(_unknownHitTestMessage(position, target, snapshot));
}

/// The analysis behind [throwTapFailureReport] and [throwHitTestFailureReport].
///
/// Returns `null` when the target is not a [RenderBox], or when [snapshot]
/// matched no single element. Nothing here can explain a widget it cannot
/// measure, so the callers fall back to [_unknownHitTestMessage].
TapInspection? _inspectHitTestFailure({
  required Offset position,
  required RenderObject target,
  required WidgetSnapshot snapshot,
}) {
  final targetElement = snapshot.discoveredElement;
  if (target is! RenderBox || targetElement == null) {
    return null;
  }
  return _inspectUntappableTarget(
    selectorDescription: snapshot.selector.toStringBreadcrumb(),
    target: _tapWidgetInfo(targetElement),
    targetElement: targetElement,
    renderBox: target,
    position: position,
    samples: () => _collectSamples(target),
  );
}

/// The message for a target the diagnostics could not reason about at all.
///
/// Unlike [TapUnknownReason] this is not backed by a [TapInspection]: it is what
/// is left when even building one was not possible.
String _unknownHitTestMessage(
  Offset position,
  RenderObject target,
  WidgetSnapshot snapshot,
) {
  final probe = probeHitTest(position, target);
  return "Widget '${snapshot.discoveredWidget!.toStringShort()}' can not be interacted with at position $position where its RenderObject $target was found.\n"
      "The exact reason, why it doesn't receive hitTest events is unknown.\n"
      "Hit-test path: ${probe.hitTest.path.joinToString(separator: ', ')}\n"
      "If you think this case needs a better error message, create an issue https://github.com/passsy/spot for anyone else running in a similar issue.\n"
      "A small example would be highly appreciated.";
}

/// Throws when [snapshot] points at a zero-size render box.
void throwIfZeroSize({required WidgetSnapshot snapshot}) {
  final targetElement = snapshot.discoveredElement;
  final renderObject = targetElement?.renderObject;
  if (targetElement == null || renderObject is! RenderBox) {
    return;
  }
  if (renderObject.size != Size.zero) {
    return;
  }

  final failure = _inspectZeroSize(
    selectorDescription: snapshot.selector.toStringBreadcrumb(),
    target: _tapWidgetInfo(targetElement),
    targetElement: targetElement,
    renderBox: renderObject,
    samples: () => _collectSamples(renderObject),
  );
  if (failure == null) {
    return;
  }

  throw TestFailure(failure.message);
}

/// Builds a [TapInspection] that reports [reason].
///
/// The single place where a failure is assembled, so [TapInspection.message]
/// and [TapInspection.tapFailure] can never disagree about which failure it is.
TapInspection _tapInspectionFailure({
  required String selectorDescription,
  required TapWidgetInfo? target,
  required Object reason,
  required String message,
  TapSamples Function()? samples,
}) {
  return TapInspection._(
    selectorDescription: selectorDescription,
    target: target,
    samples: samples,
    tapPosition: null,
    message: message,
    tapFailure: reason,
  );
}

/// Reports a target that does not overlap the viewport at all.
///
/// Returns `null` while any part of it is inside, even a single pixel. Hit
/// testing decides the rest, a partially visible widget may still be tappable.
TapInspection? _inspectViewBounds({
  required String selectorDescription,
  required TapWidgetInfo target,
  required RenderBox renderBox,
}) {
  final bounds = _viewBoundsOf(renderBox);
  if (!bounds.isOutside) {
    return null;
  }

  final reason = TapOutsideViewportReason(
    viewport: bounds.viewport,
    targetRect: bounds.targetRect,
    // Both are 0 as long as this reason is only reported for targets that do
    // not overlap the viewport at all. They stay correct once partially
    // visible targets are reported here too.
    visibleRect: bounds.visibleRect,
    visibleFraction: bounds.visibleFraction,
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    message: bounds.messageFor(selectorDescription),
  );
}

/// Works out why a target that was hit tested everywhere received nothing.
///
/// The order is the order the causes take effect in: a widget above the target
/// swallowing the event beats the target having no size, which beats a sibling
/// painted on top of it. Whatever is left gets [TapUnknownReason].
TapInspection _inspectUntappableTarget({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required RenderBox renderBox,
  required Offset position,
  required TapSamples Function() samples,
}) {
  final probe = probeHitTest(position, renderBox);
  final renderElement = _elementForRenderBox(renderBox) ?? targetElement;
  final blockedFailure = _inspectPointerBlocker(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: renderElement,
    hitTest: probe.hitTest,
    samples: samples,
  );
  if (blockedFailure != null) {
    return blockedFailure;
  }

  final zeroSizeFailure = _inspectZeroSize(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: targetElement,
    renderBox: renderBox,
    samples: samples,
  );
  if (zeroSizeFailure != null) {
    return zeroSizeFailure;
  }

  final coveredFailure = _inspectCoveredWidget(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: targetElement,
    hitTest: probe.hitTest,
    samples: samples,
  );
  if (coveredFailure != null) {
    return coveredFailure;
  }

  final reason = TapUnknownReason(
    position: position,
    hitTest: probe.hitTest,
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    samples: samples,
    message:
        "Widget '${target.widgetName}' can not be interacted with at position $position where its RenderObject $renderBox was found.\n"
        "The exact reason, why it doesn't receive hitTest events is unknown.\n"
        "If you think this case needs a better error message, create an issue https://github.com/passsy/spot for anyone else running in a similar issue.\n"
        "A small example would be highly appreciated.",
  );
}

/// The [Element] that created [renderBox], `null` outside debug builds.
///
/// Flutter only records the creator in debug mode, which is where tests run.
Element? _elementForRenderBox(RenderBox renderBox) {
  final debugCreator = renderBox.debugCreator;
  if (debugCreator is! DebugCreator) {
    return null;
  }
  return debugCreator.element;
}

/// Whether [element] stops a hit test from reaching anything below it.
bool _blocksPointerEvents(Element element) {
  final widget = element.widget;
  if (widget is AbsorbPointer) {
    return widget.absorbing;
  }
  if (widget is IgnorePointer) {
    return widget.ignoring;
  }
  if (widget is Offstage) {
    return widget.offstage;
  }
  return false;
}

/// Reports the widget above [targetElement] that swallows the pointer event.
///
/// Flutter hit tests from the root down, and [RenderAbsorbPointer],
/// [RenderIgnorePointer] and [RenderOffstage] all answer without visiting their
/// child. The outermost blocker is therefore the one that stops the hit test;
/// anything below it is never asked and removing it would not help. That is why
/// this walks root to target and takes the first match, not the closest one.
///
/// [Element.parents] starts at [targetElement], so a blocker on the target
/// itself is found here too.
TapInspection? _inspectPointerBlocker({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required TapHitTestInfo hitTest,
  required TapSamples Function() samples,
}) {
  final rootToTarget = targetElement.parents.toList().reversed;
  final blockerElement = rootToTarget.firstOrNullWhere(_blocksPointerEvents);
  if (blockerElement == null) {
    return null;
  }

  final blocker = _tapWidgetInfo(blockerElement);
  final location = blockerElement.debugWidgetLocation?.file.path ??
      blockerElement.debugGetCreatorChain(100);
  final introducer = _findIntroducer(blockerElement);
  final introducedBy = introducer == null ? null : _tapWidgetInfo(introducer);

  final widget = blockerElement.widget;
  if (widget is AbsorbPointer) {
    final closestReceiver = hitTest.receiver?.element.toStringDeep() ?? '';
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: target,
      samples: samples,
      reason: TapAbsorbedReason(
        absorbPointer: blocker,
        hitTest: hitTest,
      ),
      message:
          "Widget '${target.widgetName}' is wrapped in AbsorbPointer and doesn't receive pointer events.\n"
          "AbsorbPointer is created at $location\n"
          "The closest widget reacting to the touch event is:\n"
          "$closestReceiver",
    );
  }

  if (widget is IgnorePointer) {
    return _tapInspectionFailure(
      selectorDescription: selectorDescription,
      target: target,
      samples: samples,
      reason: TapIgnoredReason(
        ignorePointer: blocker,
        introducedBy: introducedBy,
        hitTest: hitTest,
      ),
      message:
          "Widget '${target.widgetName}' is wrapped in IgnorePointer and doesn't receive pointer events.\n"
          "The IgnorePointer is located at $location",
    );
  }

  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    samples: samples,
    reason: TapOffstageReason(
      offstage: blocker,
      introducedBy: introducedBy,
      hitTest: hitTest,
    ),
    message:
        "Widget '${target.widgetName}' is wrapped in Offstage, which takes it out of the layout and out of hit testing.\n"
        "The Offstage is located at $location\n"
        "Offstage widgets are not on screen. spotOffstage() finds them, nothing can tap them.",
  );
}

/// The widget a test author would have to change to remove [blockerElement].
///
/// [Visibility] builds an [IgnorePointer] or an [Offstage] depending on its
/// flags, so it is named directly. Otherwise the closest user-code ancestor is
/// the best guess.
Element? _findIntroducer(Element blockerElement) {
  final visibility = blockerElement.parents.skip(1).firstOrNullWhere((it) {
    return it.widget is Visibility;
  });
  if (visibility != null) {
    return visibility;
  }
  return blockerElement.parents.skip(1).firstOrNullWhere((it) {
    return it.debugWidgetLocation?.isUserCode ?? false;
  });
}

/// Reports a target of zero size and the ancestor that shrank it.
///
/// Names the outermost zero-sized ancestor, because giving any widget below it
/// a size changes nothing. Returns `null` when [renderBox] has a size.
TapInspection? _inspectZeroSize({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required RenderBox renderBox,
  required TapSamples Function() samples,
}) {
  if (renderBox.size != Size.zero) {
    return null;
  }

  final parents = targetElement.parents.toList();
  final shrinker = parents.reversed.firstWhere((it) {
    final renderObject = it.renderObject;
    if (renderObject is! RenderBox) {
      return false;
    }
    return renderObject.size == Size.zero;
  });
  final shrinkChain = targetElement.parents
      .takeWhile((it) => it != shrinker)
      .map(_tapWidgetInfo)
      .toList();
  final shrinkerInfo = _tapWidgetInfo(shrinker);
  final reason = TapZeroSizeReason(
    shrinker: shrinkerInfo,
    shrinkChain: shrinkChain,
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    samples: samples,
    message:
        "${target.element.toStringShort()} can't be interacted with because it has size ${Size.zero}.\n"
        "${shrinker.toStringShort()} forces ${target.element.toStringShort()} to have the size ${Size.zero}.\n"
        "${shrinker.toStringShort()} ${shrinker.debugWidgetLocation?.file.path}",
  );
}

/// Reports the widget that received the pointer event instead of the target.
///
/// Returns `null` when nothing was hit, or when the receiver turns out to be an
/// ancestor of the target rather than a sibling painted over it, see
/// [analyzeCoverWidget].
TapInspection? _inspectCoveredWidget({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required TapHitTestInfo hitTest,
  required TapSamples Function() samples,
}) {
  final cover = hitTest.receiver;
  if (cover == null) {
    return null;
  }

  final analysis = analyzeCoverWidget(
    coverElement: cover.element,
    targetElement: targetElement,
  );
  if (analysis == null) {
    return null;
  }

  final coverChain = analysis.coverChain.map(_tapWidgetInfo).toList();
  final relevantCoveringWidgets = coverChain.where((it) {
    return it.isUserCode ?? false;
  }).toList();
  final reason = TapCoveredReason(
    hitTest: hitTest,
    relevantCoveringWidgets: relevantCoveringWidgets,
    commonAncestor: _tapWidgetInfo(analysis.commonAncestor),
    userRelevantAncestor: _tapWidgetInfo(analysis.firstUsefulParent),
    targetChain: analysis.targetChain.map(_tapWidgetInfo).toList(),
    coverChain: coverChain,
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    samples: samples,
    message: createCoverWidgetMessage(
      targetName: target.widgetName,
      analysis: analysis,
    ),
  );
}

/// Hit tests all of [renderBox] and records what each point reached.
///
/// An order of magnitude more expensive than [findPokablePositions] without
/// `collectHitTests`, because it builds a [TapWidgetInfo] for every widget on
/// every sample's hit-test path. Only called when [TapInspection.samples] is
/// actually read.
TapSamples _collectSamples(RenderBox renderBox) {
  final pokablePositions = findPokablePositions(
    renderBox,
    collectHitTests: true,
  );
  final all = pokablePositions.samples.mapNotNull((it) {
    final hitTest = it.hitTest;
    if (hitTest == null) {
      return null;
    }
    return TapHitSample(
      localPosition: it.localPosition,
      globalPosition: it.globalPosition,
      hitsTarget: it.hitsTarget,
      hitTest: hitTest,
    );
  }).toList();
  return TapSamples(
    searchArea: pokablePositions.searchArea,
    all: all,
  );
}

/// Works out how [coverElement] ends up in front of [targetElement].
///
/// Returns `null` when the two are not siblings under a common ancestor, for
/// example when the cover is an ancestor of the target and therefore does not
/// cover anything.
CoverWidgetAnalysis? analyzeCoverWidget({
  required Element coverElement,
  required Element targetElement,
}) {
  final commonAncestor = findCommonAncestor([coverElement, targetElement]);
  final coverChain = coverElement
      .debugGetDiagnosticChain()
      .takeWhile((it) => it != commonAncestor)
      .toList();
  if (coverChain.isEmpty) {
    return null;
  }

  final targetChain = targetElement
      .debugGetDiagnosticChain()
      .takeWhile((it) => it != commonAncestor)
      .toList();
  final commonAncestorChain = commonAncestor.debugGetDiagnosticChain();
  final usefulParents = commonAncestorChain.drop(1).where((it) {
    return it.debugWidgetLocation?.isUserCode ?? false;
  }).toList();
  final firstUsefulParent =
      usefulParents.firstOrNull ?? commonAncestorChain.first;
  final usefulToTarget =
      targetChain.takeWhile((it) => it != firstUsefulParent).toList();
  final receiverColumn =
      "(Cover - Received pointer event)\n${coverChain.joinToString(separator: '\n', transform: (it) => it.toStringShort())}";
  final targetColumn =
      "(Target for pointer event, below Cover)\n${usefulToTarget.joinToString(separator: '\n', transform: (it) => it.toStringShort())}";
  final diagram = """
${_createColumns(receiverColumn, targetColumn)}
 │ ┌──────────────────────────────────────┘
${commonAncestor.toStringShort().trimRight()} (${commonAncestor.debugWidgetLocation?.file.path})
${usefulParents.takeWhile((it) => it != firstUsefulParent).joinToString(separator: '\n', transform: (it) => it.toStringShort()).trimRight()}
${firstUsefulParent.toStringShort()} (${firstUsefulParent.debugWidgetLocation?.file.path})
""";
  return CoverWidgetAnalysis(
    coverElement: coverElement,
    commonAncestor: commonAncestor,
    firstUsefulParent: firstUsefulParent,
    coverChain: coverChain,
    targetChain: targetChain,
    diagram: diagram,
  );
}

/// Renders [analysis] as the failure message shown when a widget is covered.
String createCoverWidgetMessage({
  required String targetName,
  required CoverWidgetAnalysis analysis,
}) {
  return "Widget '$targetName' can not be interacted with directly, because another widget (${analysis.coverElement.toStringShort()}) inside ${analysis.firstUsefulParent.toStringShort()} is completely covering it and consumes all pointer events.\n"
      "\n"
      "Try interacting with the ${analysis.firstUsefulParent.toStringShort()} which contains '$targetName' instead.\n\n"
      "Example:\n"
      "  // BAD: tap the Text inside ElevatedButton\n"
      "  WidgetSelector<AnyText> selector = spot<ElevatedButton>().spotText('Tap me');\n"
      "  await act.tap(selector);\n"
      "\n"
      "  // GOOD: tap the ElevatedButton which contains text 'Tap me'\n"
      "  WidgetSelector<ElevatedButton> selector = spot<ElevatedButton>().withChild(spotText('Tap me'));\n"
      "  await act.tap(selector);\n"
      "\n"
      "${removeEmptyLines(analysis.diagram)}\n";
}

/// Drops all blank lines from [value].
String removeEmptyLines(String value) {
  return value.split('\n').where((line) => line.trim().isNotEmpty).join('\n');
}

/// Hit-tests [position] and returns widgets on the hit-test path.
TapHitTestInfo hitTestWidgetsAt(Offset position) {
  final entries = _hitTestEntriesAt(position);
  return _tapHitTestInfo(position, entries);
}

/// True iff a hit-test at [position] reaches [target].
bool canBePoked({
  required Offset position,
  required RenderObject target,
  Rect? insideArea,
}) {
  if (insideArea != null && !insideArea.contains(position)) {
    return false;
  }
  final entries = _hitTestEntriesAt(position);
  return entries.any((it) => it.target == target);
}

/// Attempts to find hittable positions on [renderBox] using an 8 px grid.
PokablePositions findPokablePositions(
  RenderBox renderBox, {
  bool Function(Offset local, Offset global)? shouldBePoked,
  bool collectHitTests = false,
}) {
  final List<Offset> hits = [];
  final List<Offset> flops = [];
  final List<Offset> skipped = [];
  final samples = <PokablePositionSample>[];
  const gridSize = 8;
  for (int x = 0; x < renderBox.size.width; x += gridSize) {
    for (int y = 0; y < renderBox.size.height; y += gridSize) {
      final localPosition = Offset(x.toDouble(), y.toDouble());
      final globalPosition = renderBox.localToGlobal(localPosition);
      final shouldPoke =
          shouldBePoked?.call(localPosition, globalPosition) ?? true;
      if (!shouldPoke) {
        skipped.add(globalPosition);
        if (collectHitTests) {
          samples.add(
            PokablePositionSample(
              localPosition: localPosition,
              globalPosition: globalPosition,
              hitsTarget: false,
              hitTest: null,
            ),
          );
        }
        continue;
      }
      final probe =
          collectHitTests ? probeHitTest(globalPosition, renderBox) : null;
      final canPoke = probe?.hitsTarget ??
          canBePoked(position: globalPosition, target: renderBox);
      if (canPoke) {
        hits.add(globalPosition);
      } else {
        flops.add(globalPosition);
      }
      if (collectHitTests) {
        samples.add(
          PokablePositionSample(
            localPosition: localPosition,
            globalPosition: globalPosition,
            hitsTarget: canPoke,
            hitTest: probe!.hitTest,
          ),
        );
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
    return PokablePositions(
      searchArea: searchArea,
      hits: hits,
      flops: flops,
      skipped: skipped,
      target: renderBox,
      spacing: gridSize,
      samples: samples,
    );
  }

  final centerOfPokablePoints = () {
    final maxX = hits.maxBy((it) => it.dx)!.dx;
    final minX = hits.minBy((it) => it.dx)!.dx;
    final maxY = hits.maxBy((it) => it.dy)!.dy;
    final minY = hits.minBy((it) => it.dy)!.dy;
    return Offset(
      ((maxX + minX) ~/ 2).toDouble(),
      ((maxY + minY) ~/ 2).toDouble(),
    );
  }();
  final centerCanBePoked = canBePoked(
    position: centerOfPokablePoints,
    target: renderBox,
  );
  final Offset? mostCenterPoint;
  if (centerCanBePoked) {
    mostCenterPoint = centerOfPokablePoints;
  } else {
    mostCenterPoint =
        hits.minBy((it) => (it - centerOfPokablePoints).distanceSquared);
  }

  return PokablePositions(
    searchArea: searchArea,
    hits: hits,
    flops: flops,
    skipped: skipped,
    target: renderBox,
    spacing: gridSize,
    samples: samples,
    mostCenterHittablePosition: mostCenterPoint,
  );
}

/// Hit-tests [position] once and reports whether [target] was reached.
TapHitTestProbe probeHitTest(Offset position, RenderObject target) {
  final entries = _hitTestEntriesAt(position);
  final hitsTarget = entries.any((it) => it.target == target);
  return TapHitTestProbe(
    hitsTarget: hitsTarget,
    hitTest: _tapHitTestInfo(position, entries),
  );
}

/// Describes one hit test, dropping entries that belong to no [Element].
///
/// The path keeps Flutter's order, innermost receiver first.
TapHitTestInfo _tapHitTestInfo(
  Offset position,
  List<HitTestEntry> entries,
) {
  final path =
      entries.mapNotNull((it) => it.element).map(_tapWidgetInfo).toList();
  return TapHitTestInfo(
    position: position,
    path: path,
  );
}

/// Hit tests [position] and returns everything the event would travel through.
///
/// The one place that asks the binding, called once per sampled grid point, so
/// it stays free of anything the caller does not need.
List<HitTestEntry> _hitTestEntriesAt(Offset position) {
  final result = HitTestResult();
  // ignore: deprecated_member_use
  WidgetsBinding.instance.hitTest(result, position);
  return result.path.toList();
}

/// Captures what [element] looks like right now.
///
/// Geometry is read eagerly because it changes with the next layout. The source
/// location is not, see [TapWidgetInfo.sourceLocation] — resolving it serializes
/// a diagnostics node, and this runs for every widget on every sampled
/// hit-test path.
TapWidgetInfo _tapWidgetInfo(Element element) {
  final renderObject = element.renderObject;
  final renderBox = renderObject is RenderBox ? renderObject : null;
  return TapWidgetInfo(
    widget: element.widget,
    element: element,
    renderObject: renderObject,
    widgetName: element.toStringShort(),
    globalRect: renderBox?.globalRect,
  );
}

/// Lays out [receiver] and [target] side by side for the cover diagram.
///
/// Both are multi-line widget chains. Lines longer than the column are cut
/// rather than wrapped, so the two columns stay aligned.
String _createColumns(String receiver, String target) {
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
      targetLine.characters.take(columnWidth).toString().padRight(columnWidth),
    );
    buffer.writeln();
  }
  return buffer.toString().trimRight();
}

/// Result of checking whether [Act.tap] can tap a selector.
///
/// A snapshot of the widget tree at the time [Act.inspectTap] was called. It
/// holds on to [Element]s, [RenderObject]s and the [Rect]s they had back then.
/// Pumping a frame does not update it, and the elements it points at may be
/// unmounted by the next build. Read it before continuing the test, do not
/// keep it around.
class TapInspection {
  TapInspection._({
    required this.selectorDescription,
    required this.target,
    required TapSamples Function()? samples,
    required this.tapPosition,
    required this.message,
    required Object? tapFailure,
  })  : _samples = samples,
        _tapFailure = tapFailure,
        _tree = currentWidgetTreeSnapshot();

  /// Human-readable selector description used in diagnostics.
  final String selectorDescription;

  /// The single widget selected as tap target, if one was found.
  final TapWidgetInfo? target;

  final TapSamples Function()? _samples;

  /// The tree this inspection describes, to notice when it is outdated.
  final WidgetTreeSnapshot _tree;

  TapSamples? _resolvedSamples;

  /// The points that were poked to find out whether the target can be tapped.
  ///
  /// `null` when nothing was sampled, because the target was never found or was
  /// ruled out before the search, see [tapFailure].
  ///
  /// Sampling hit tests the whole target on a grid, which costs far more than
  /// the rest of the inspection, so it happens on first read rather than up
  /// front. That only works while the tree still looks the way it did when
  /// [Act.inspectTap] ran — reading this after a pump throws a [TestFailure]
  /// rather than reporting what a different tree does.
  TapSamples? get samples {
    final resolved = _resolvedSamples;
    if (resolved != null) {
      return resolved;
    }
    final collect = _samples;
    if (collect == null) {
      return null;
    }
    if (!_tree.isFromThisFrame) {
      throw TestFailure(
        'TapInspection.samples was read after a new frame was pumped.\n'
        'The samples are collected on first read by hit testing the target, so '
        'they would describe the tree as it is now, not the one the inspection '
        'reports on.\n'
        'Read inspection.samples before pumping, or inspect again if it is the '
        'current tree you want to know about.',
      );
    }
    return _resolvedSamples = collect();
  }

  /// The position [Act.tap] would use.
  final Offset? tapPosition;

  /// A plain-text message describing why [Act.tap] cannot tap the selector.
  final String? message;

  /// Why [Act.tap] can not tap the selector, `null` when it can.
  ///
  /// Casts the failure to one of the `Tap*Reason` types, see
  /// [TapFailureReason].
  TapFailureReason? get tapFailure {
    final tapFailure = _tapFailure;
    if (tapFailure == null) {
      return null;
    }
    return TapFailureReason._(this, tapFailure);
  }

  /// The raw failure, `null` when the widget can be tapped.
  ///
  /// Kept untyped and private so a new reason type cannot break callers, see
  /// [TapFailureReason.reason].
  final Object? _tapFailure;

  /// Whether [Act.tap] can tap the selector.
  bool get canTap => _tapFailure == null && tapPosition != null;
}

/// Why [Act.tap] can not tap the widget of a [TapInspection].
///
/// Every getter casts the failure to one concrete reason. When the tap failed
/// for a different reason, it throws a [TestFailure] with the full tap
/// diagnostics attached, which makes it safe to read a property right away:
///
/// ```dart
/// final inspection = act.inspectTap(spot<ElevatedButton>());
/// expect(inspection.tapFailure?.tapCoveredReason.primaryCover?.widget,
///     isA<ColoredBox>());
/// ```
///
/// Read [reason] to branch on the failure instead of asserting one, for
/// example with `isA<TapCoveredReason>()`.
class TapFailureReason {
  TapFailureReason._(this._inspection, this.reason);

  /// The inspection [reason] came from, to attach its full diagnostics when a
  /// typed getter is asked for the wrong reason.
  final TapInspection _inspection;

  /// The failure object.
  ///
  /// One of the `Tap*Reason` types. It is intentionally untyped: adding a new
  /// reason must not break callers that switch over the known ones.
  final Object reason;

  /// Returns the not-found reason or throws a [TestFailure].
  TapNotFoundReason get tapNotFoundReason {
    return _as<TapNotFoundReason>();
  }

  /// Returns the multiple-widgets reason or throws a [TestFailure].
  TapMultipleWidgetsFoundReason get tapMultipleWidgetsFoundReason {
    return _as<TapMultipleWidgetsFoundReason>();
  }

  /// Returns the no-render-object reason or throws a [TestFailure].
  TapNoRenderObjectReason get tapNoRenderObjectReason {
    return _as<TapNoRenderObjectReason>();
  }

  /// Returns the non-render-box reason or throws a [TestFailure].
  TapNonRenderBoxReason get tapNonRenderBoxReason {
    return _as<TapNonRenderBoxReason>();
  }

  /// Returns the outside-viewport reason or throws a [TestFailure].
  TapOutsideViewportReason get tapOutsideViewportReason {
    return _as<TapOutsideViewportReason>();
  }

  /// Returns the offstage reason or throws a [TestFailure].
  TapOffstageReason get tapOffstageReason {
    return _as<TapOffstageReason>();
  }

  /// Returns the zero-size reason or throws a [TestFailure].
  TapZeroSizeReason get tapZeroSizeReason {
    return _as<TapZeroSizeReason>();
  }

  /// Returns the absorbed reason or throws a [TestFailure].
  TapAbsorbedReason get tapAbsorbedReason {
    return _as<TapAbsorbedReason>();
  }

  /// Returns the ignored reason or throws a [TestFailure].
  TapIgnoredReason get tapIgnoredReason {
    return _as<TapIgnoredReason>();
  }

  /// Returns the covered reason or throws a [TestFailure].
  TapCoveredReason get tapCoveredReason {
    return _as<TapCoveredReason>();
  }

  /// Returns the unknown reason or throws a [TestFailure].
  TapUnknownReason get tapUnknownReason {
    return _as<TapUnknownReason>();
  }

  /// The reason type and the first line of [TapInspection.message].
  ///
  /// ```txt
  /// TapCoveredReason: Widget 'ElevatedButton' can not be interacted with
  /// directly, because another widget (ColoredBox) inside Padding is
  /// completely covering it and consumes all pointer events.
  /// ```
  ///
  /// Print [TapInspection.message] for the full diagnostics, including the
  /// widget trees of the target and whatever is in its way.
  @override
  String toString() {
    final summary = _inspection.message?.split('\n').first.trim();
    if (summary == null || summary.isEmpty) {
      return '${reason.runtimeType}';
    }
    return '${reason.runtimeType}: $summary';
  }

  /// Casts [reason] to [R], or fails the test with the real diagnostics.
  ///
  /// A wrong assumption about why a tap failed reads as a normal test failure
  /// naming the actual reason, not as a cast error.
  R _as<R extends Object>() {
    final reason = this.reason;
    if (reason is R) {
      return reason;
    }

    throw TestFailure(
      'Expected $R but tap failed with ${reason.runtimeType}.\n'
      '${_inspection.message}',
    );
  }
}

/// Thrown by [Act.tap] when the widget can not be tapped.
///
/// Carries the [inspection] that explains why, so a test can assert the reason
/// instead of matching on the message:
///
/// ```dart
/// await expectLater(
///   () => act.tap(spot<SubmitButton>()),
///   throwsA(
///     isA<TapFailure>().having(
///       (it) => it.inspection.tapFailure?.reason,
///       'reason',
///       isA<TapCoveredReason>(),
///     ),
///   ),
/// );
/// ```
///
/// Extends [TestFailure], so it is still reported as a failed assertion rather
/// than a crashed test.
class TapFailure extends TestFailure {
  /// Creates a tap failure for [inspection].
  TapFailure(this.inspection) : super(inspection.message);

  /// Describes the widget and why [Act.tap] could not tap it.
  final TapInspection inspection;
}

/// Details about a widget involved in tap inspection.
class TapWidgetInfo {
  /// Creates widget information for tap diagnostics.
  TapWidgetInfo({
    required this.widget,
    required this.element,
    required this.renderObject,
    required this.widgetName,
    required this.globalRect,
  });

  /// The widget currently mounted at [element].
  final Widget widget;

  /// The element that owns [widget].
  final Element element;

  /// The render object attached to [element], if any.
  final RenderObject? renderObject;

  /// Short widget name used in diagnostics.
  final String widgetName;

  /// Source location reported by Flutter's widget inspector, if available.
  ///
  /// Resolved on access from the live [element], not from the captured
  /// [widget]. A rebuild can swap the widget at [element], after which this
  /// describes the widget mounted there now instead of [widget]. Read it
  /// before pumping another frame, like the rest of the inspection.
  String? get sourceLocation => element.debugWidgetLocation?.file.path;

  /// Whether Flutter reports this widget as user code.
  ///
  /// Resolved on access, see [sourceLocation].
  bool? get isUserCode => element.debugWidgetLocation?.isUserCode;

  /// The render object's global rectangle, if it is a [RenderBox].
  final Rect? globalRect;

  @override
  String toString() {
    return widgetName;
  }
}

/// Hit-test information for one inspected point.
class TapHitTestInfo {
  /// Creates hit-test information.
  TapHitTestInfo({
    required this.position,
    required List<TapWidgetInfo> path,
  }) : path = List.unmodifiable(path);

  /// The global screen position that was hit-tested.
  final Offset position;

  /// Widgets on the hit-test path, ordered from receiver outward.
  final List<TapWidgetInfo> path;

  /// The widget that received the hit-test first.
  TapWidgetInfo? get receiver {
    if (path.isEmpty) {
      return null;
    }
    return path.first;
  }
}

/// One sampled point in the tap-target search.
class TapHitSample {
  /// Creates a tap hit sample.
  TapHitSample({
    required this.localPosition,
    required this.globalPosition,
    required this.hitsTarget,
    required this.hitTest,
  });

  /// Position relative to the inspected target.
  final Offset localPosition;

  /// Position in global screen coordinates.
  final Offset globalPosition;

  /// Whether this sample reached the target render object.
  final bool hitsTarget;

  /// Hit-test path for [globalPosition].
  final TapHitTestInfo hitTest;

  /// The widget that received this point instead of the target.
  ///
  /// `null` when the point reached the target, or when nothing was hit.
  TapWidgetInfo? get blockedBy {
    if (hitsTarget) {
      return null;
    }
    return hitTest.receiver;
  }
}

/// The points spot poked to find out whether a widget can be tapped.
class TapSamples {
  /// Creates sampled hit-test information.
  TapSamples({
    required this.searchArea,
    required List<TapHitSample> all,
  }) : _all = List.unmodifiable(all);

  /// The global rectangle covered by the sampled target.
  final Rect searchArea;

  /// Every point that was poked. How the points are picked is not part of the
  /// API, a future spot version may search differently.
  final List<TapHitSample> _all;

  /// Points that reached the target render object.
  List<TapHitSample> get hittable {
    return _all.where((it) => it.hitsTarget).toList();
  }

  /// Points that did not reach the target render object.
  List<TapHitSample> get blocked {
    return _all.where((it) => !it.hitsTarget).toList();
  }

  /// Percentage of poked points that reached the target render object.
  double get hittablePercent {
    if (_all.isEmpty) {
      return 0;
    }
    return hittable.length / _all.length * 100;
  }

  /// The widgets that received pointer events instead of the target, the one
  /// covering the most of it first.
  ///
  /// Answers what is in the way without walking every sample:
  ///
  /// ```dart
  /// final blocker = act.inspectTap(spot<MyButton>()).samples!.blockers.first;
  /// print('${blocker.receiver.widgetName} covers ${blocker.percent}%');
  /// ```
  List<TapBlocker> get blockers {
    final counts = <Element, int>{};
    final widgets = <Element, TapWidgetInfo>{};
    for (final sample in blocked) {
      final receiver = sample.blockedBy;
      if (receiver == null) {
        continue;
      }
      counts[receiver.element] = (counts[receiver.element] ?? 0) + 1;
      widgets[receiver.element] ??= receiver;
    }
    final blockers = counts.entries.map((entry) {
      return TapBlocker(
        receiver: widgets[entry.key]!,
        sampleCount: entry.value,
        percent: _all.isEmpty ? 0 : entry.value / _all.length * 100,
      );
    }).toList()
      ..sort((a, b) => b.sampleCount.compareTo(a.sampleCount));
    return List.unmodifiable(blockers);
  }
}

/// A widget that receives pointer events meant for the inspected target.
class TapBlocker {
  /// Creates a blocker.
  TapBlocker({
    required this.receiver,
    required this.sampleCount,
    required this.percent,
  });

  /// The widget that received the pointer events instead of the target.
  final TapWidgetInfo receiver;

  /// How many sampled points this widget intercepted.
  final int sampleCount;

  /// Percentage of the target this widget covers, measured in sampled points.
  final double percent;

  @override
  String toString() {
    return '${receiver.widgetName} (${percent.round()}%)';
  }
}

/// The target was not found.
class TapNotFoundReason {
  /// Creates a not-found tap failure reason.
  TapNotFoundReason({
    required this.selectorDescription,
  });

  /// Human-readable selector description.
  final String selectorDescription;
}

/// The selector matched more than one widget.
class TapMultipleWidgetsFoundReason {
  /// Creates a multiple-widgets tap failure reason.
  TapMultipleWidgetsFoundReason({
    required this.selectorDescription,
    required List<TapWidgetInfo> matches,
  }) : matches = List.unmodifiable(matches);

  /// Human-readable selector description.
  final String selectorDescription;

  /// Widgets matched by the selector.
  final List<TapWidgetInfo> matches;
}

/// The selected widget has no render object.
class TapNoRenderObjectReason {
  /// Creates a no-render-object tap failure reason.
  TapNoRenderObjectReason();
}

/// The selected widget is not backed by a [RenderBox].
class TapNonRenderBoxReason {
  /// Creates a non-render-box tap failure reason.
  TapNonRenderBoxReason({
    required this.renderObject,
  });

  /// The render object that is not a [RenderBox].
  final RenderObject renderObject;
}

/// The target is outside the viewport.
class TapOutsideViewportReason {
  /// Creates an outside-viewport tap failure reason.
  TapOutsideViewportReason({
    required this.viewport,
    required this.targetRect,
    required this.visibleRect,
    required this.visibleFraction,
  });

  /// The visible viewport.
  final Rect viewport;

  /// Global rectangle of the target.
  final Rect targetRect;

  /// Visible portion of [targetRect].
  final Rect visibleRect;

  /// Fraction of [targetRect] visible in [viewport].
  final double visibleFraction;
}

/// The target has zero size.
class TapZeroSizeReason {
  /// Creates a zero-size tap failure reason.
  TapZeroSizeReason({
    required this.shrinker,
    required List<TapWidgetInfo> shrinkChain,
  }) : shrinkChain = List.unmodifiable(shrinkChain);

  /// Closest ancestor that forces the target to zero size.
  final TapWidgetInfo shrinker;

  /// Widgets from the target up to, but excluding, [shrinker].
  final List<TapWidgetInfo> shrinkChain;
}

/// An [AbsorbPointer] prevents the target from receiving pointer events.
class TapAbsorbedReason {
  /// Creates an absorbed tap failure reason.
  TapAbsorbedReason({
    required this.absorbPointer,
    required this.hitTest,
  });

  /// The [AbsorbPointer] that absorbs pointer events.
  final TapWidgetInfo absorbPointer;

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;
}

/// An [Offstage] takes the target out of the layout and out of hit testing.
///
/// Reported for widgets reached with `spotOffstage()`. The default [spot]
/// selectors skip offstage widgets, so an offstage target usually surfaces as
/// [TapNotFoundReason] instead.
class TapOffstageReason {
  /// Creates an offstage tap failure reason.
  TapOffstageReason({
    required this.offstage,
    required this.introducedBy,
    required this.hitTest,
  });

  /// The [Offstage] that hides the target.
  final TapWidgetInfo offstage;

  /// The user-relevant widget that introduced [offstage], if known.
  ///
  /// A [Visibility] when one built the [Offstage], otherwise the closest
  /// ancestor from user code.
  final TapWidgetInfo? introducedBy;

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;
}

/// An [IgnorePointer] prevents the target from receiving pointer events.
class TapIgnoredReason {
  /// Creates an ignored tap failure reason.
  TapIgnoredReason({
    required this.ignorePointer,
    required this.introducedBy,
    required this.hitTest,
  });

  /// The [IgnorePointer] that removes the target subtree from hit testing.
  final TapWidgetInfo ignorePointer;

  /// The user-relevant widget that introduced [ignorePointer], if known.
  ///
  /// A [Visibility] when one built the [IgnorePointer], otherwise the closest
  /// ancestor from user code.
  final TapWidgetInfo? introducedBy;

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;
}

/// Another widget covers the target.
class TapCoveredReason {
  /// Creates a covered tap failure reason.
  TapCoveredReason({
    required this.hitTest,
    required List<TapWidgetInfo> relevantCoveringWidgets,
    required this.commonAncestor,
    required this.userRelevantAncestor,
    required List<TapWidgetInfo> targetChain,
    required List<TapWidgetInfo> coverChain,
  })  : relevantCoveringWidgets = List.unmodifiable(relevantCoveringWidgets),
        targetChain = List.unmodifiable(targetChain),
        coverChain = List.unmodifiable(coverChain);

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;

  /// Covering widgets likely to be useful for test authors.
  final List<TapWidgetInfo> relevantCoveringWidgets;

  /// First common ancestor of the cover and target.
  final TapWidgetInfo commonAncestor;

  /// User-code ancestor that likely explains the overlap.
  final TapWidgetInfo? userRelevantAncestor;

  /// Target-side chain until [commonAncestor].
  final List<TapWidgetInfo> targetChain;

  /// Cover-side chain until [commonAncestor].
  final List<TapWidgetInfo> coverChain;

  /// Best-effort primary cover for concise messages.
  TapWidgetInfo? get primaryCover {
    if (relevantCoveringWidgets.isNotEmpty) {
      return relevantCoveringWidgets.first;
    }
    if (coverChain.isEmpty) {
      return null;
    }
    return coverChain.first;
  }
}

/// No known reason explains why the target cannot be tapped.
///
/// Read [TapInspection.samples] for what the hit tests found, and please report
/// the case at https://github.com/passsy/spot so it can get a real reason.
class TapUnknownReason {
  /// Creates an unknown tap failure reason.
  TapUnknownReason({
    required this.position,
    required this.hitTest,
  });

  /// Inspected global position.
  final Offset position;

  /// Hit-test path at [position].
  final TapHitTestInfo hitTest;
}

/// The outcome of a single hit test, see [probeHitTest].
class TapHitTestProbe {
  /// Creates a hit-test probe result.
  TapHitTestProbe({
    required this.hitsTarget,
    required this.hitTest,
  });

  /// Whether the probed target was on the hit-test path.
  final bool hitsTarget;

  /// The full hit-test path at the probed position.
  final TapHitTestInfo hitTest;
}

/// Describes how a covering widget relates to the widget it covers.
class CoverWidgetAnalysis {
  /// Creates a cover analysis.
  CoverWidgetAnalysis({
    required this.coverElement,
    required this.commonAncestor,
    required this.firstUsefulParent,
    required this.coverChain,
    required this.targetChain,
    required this.diagram,
  });

  /// The widget that receives the pointer events instead of the target.
  final Element coverElement;

  /// The closest ancestor that contains both the cover and the target.
  final Element commonAncestor;

  /// The closest ancestor above [commonAncestor] that is worth naming to a
  /// test author, usually a widget from their own code.
  final Element firstUsefulParent;

  /// Widgets from [coverElement] up to, but excluding, [commonAncestor].
  final List<Element> coverChain;

  /// Widgets from the target up to, but excluding, [commonAncestor].
  final List<Element> targetChain;

  /// Both chains rendered side by side for the failure message.
  final String diagram;
}

/// Contains the result of hit testing an entire [RenderObject].
class PokablePositions {
  /// Creates a tap-position search result.
  PokablePositions({
    required this.searchArea,
    required this.hits,
    required this.flops,
    required this.skipped,
    required this.target,
    required this.spacing,
    this.samples = const [],
    this.mostCenterHittablePosition,
  });

  /// The area that was searched via hit testing.
  final Rect searchArea;

  /// All points that were able to hit [target].
  final List<Offset> hits;

  /// Points that were inside [searchArea] but did not hit [target].
  final List<Offset> flops;

  /// Points skipped because the caller rejected them.
  final List<Offset> skipped;

  /// The target that was used for hit testing.
  final RenderBox target;

  /// Pixel distance between sampled points.
  final int spacing;

  /// Optional rich hit-test samples collected for tap inspection.
  final List<PokablePositionSample> samples;

  /// The most centered hittable position, or null when no hit was found.
  final Offset? mostCenterHittablePosition;

  /// The percentage of positions that were hittable.
  double get percent => hits.length / (hits.length + flops.length) * 100;
}

/// One sampled point collected while looking for a tappable position.
class PokablePositionSample {
  /// Creates a sampled point result.
  PokablePositionSample({
    required this.localPosition,
    required this.globalPosition,
    required this.hitsTarget,
    required this.hitTest,
  });

  /// Position relative to the target render box.
  final Offset localPosition;

  /// Position in global screen coordinates.
  final Offset globalPosition;

  /// Whether this sample reached the target render object.
  final bool hitsTarget;

  /// Optional hit-test details for rich inspection callers.
  final TapHitTestInfo? hitTest;
}

/// Grants access to the element that created a hit-test entry.
extension HitTestEntryElement on HitTestEntry {
  /// Returns the [Element] that created this [RenderObject].
  Element? get element {
    if (target is! RenderObject) {
      return null;
    }
    final renderObject = target as RenderObject;
    final debugCreator = renderObject.debugCreator;
    if (debugCreator is! DebugCreator) {
      return null;
    }
    return debugCreator.element;
  }
}

/// Adds global geometry helpers to [RenderBox].
extension RenderBoxGlobalRect on RenderBox {
  /// The rectangle occupied by this render box in global coordinates.
  Rect get globalRect {
    final position = localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
  }
}
