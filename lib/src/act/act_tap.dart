import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
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

  final search = _inspectTapTarget(renderObject);
  if (search.hittableSamples.isEmpty) {
    final centerPosition =
        renderObject.localToGlobal(renderObject.size.center(Offset.zero));
    return _inspectUntappableTarget(
      selectorDescription: selectorDescription,
      target: target,
      targetElement: targetElement,
      renderBox: renderObject,
      position: centerPosition,
      search: search,
    );
  }

  final reason = TapPartialCoverageReason(
    search: search,
  );
  final warningMessage = _createPartialCoverageWarningMessage(
    target: target,
    search: search,
  );
  final warning = () {
    if (warningMessage == null) {
      return null;
    }
    return TapInspectionWarning(
      message: warningMessage,
      reason: reason,
    );
  }();

  return TapInspection(
    selectorDescription: selectorDescription,
    target: target,
    search: search,
    tapPosition: search.bestTapPosition,
    message: null,
    reason: null,
    warning: warning,
  );
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

  final Rect viewport;
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

  String messageFor(String selectorDescription) {
    return "Widget '$selectorDescription' is located outside the viewport "
        '($targetRect).';
  }
}

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

/// Throws the same tap failure message produced by [inspectTapSelector].
void throwHitTestFailureReport({
  required Offset position,
  required RenderObject target,
  required WidgetSnapshot snapshot,
}) {
  final targetElement = snapshot.discoveredElement;
  if (target is RenderBox && targetElement != null) {
    final failure = _inspectUntappableTarget(
      selectorDescription: snapshot.selector.toStringBreadcrumb(),
      target: _tapWidgetInfo(targetElement),
      targetElement: targetElement,
      renderBox: target,
      position: position,
      search: _inspectTapTarget(target),
    );
    throw TestFailure(failure.message);
  }

  final probe = probeHitTest(position, target);
  throw TestFailure(
    "Widget '${snapshot.discoveredWidget!.toStringShort()}' can not be interacted with at position $position where its RenderObject $target was found.\n"
    "The exact reason, why it doesn't receive hitTest events is unknown.\n"
    "Hit-test path: ${probe.hitTest.path.joinToString(separator: ', ')}\n"
    "If you think this case needs a better error message, create an issue https://github.com/passsy/spot for anyone else running in a similar issue.\n"
    "A small example would be highly appreciated.",
  );
}

/// Throws when [snapshot] points at a zero-size render box.
void throwIfZeroSize({required WidgetSnapshot snapshot}) {
  final targetElement = snapshot.discoveredElement;
  final renderObject = targetElement?.renderObject;
  if (targetElement == null || renderObject is! RenderBox) {
    return;
  }
  if (renderObject.size != Size.zero) {
    // Bail out before collecting diagnostics. _inspectTapTarget hit-tests the
    // whole widget on an 8px grid and resolves the source location of every
    // widget it finds, which is only worth paying for once the size check
    // below is known to fail.
    return;
  }

  final failure = _inspectZeroSize(
    selectorDescription: snapshot.selector.toStringBreadcrumb(),
    target: _tapWidgetInfo(targetElement),
    targetElement: targetElement,
    renderBox: renderObject,
    search: _inspectTapTarget(renderObject),
  );
  if (failure == null) {
    return;
  }

  throw TestFailure(failure.message);
}

TapInspection _tapInspectionFailure({
  required String selectorDescription,
  required TapWidgetInfo? target,
  required Object reason,
  required String message,
  TapTargetSearch? search,
}) {
  return TapInspection(
    selectorDescription: selectorDescription,
    target: target,
    search: search,
    tapPosition: null,
    message: message,
    reason: reason,
    warning: null,
  );
}

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

TapInspection _inspectUntappableTarget({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required RenderBox renderBox,
  required Offset position,
  required TapTargetSearch search,
}) {
  final probe = probeHitTest(position, renderBox);
  final renderElement = _elementForRenderBox(renderBox) ?? targetElement;
  final absorbedFailure = _inspectAbsorbPointer(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: renderElement,
    hitTest: probe.hitTest,
    search: search,
  );
  if (absorbedFailure != null) {
    return absorbedFailure;
  }

  final ignoredFailure = _inspectIgnorePointer(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: renderElement,
    hitTest: probe.hitTest,
    search: search,
  );
  if (ignoredFailure != null) {
    return ignoredFailure;
  }

  final zeroSizeFailure = _inspectZeroSize(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: targetElement,
    renderBox: renderBox,
    search: search,
  );
  if (zeroSizeFailure != null) {
    return zeroSizeFailure;
  }

  final coveredFailure = _inspectCoveredWidget(
    selectorDescription: selectorDescription,
    target: target,
    targetElement: targetElement,
    hitTest: probe.hitTest,
    search: search,
  );
  if (coveredFailure != null) {
    return coveredFailure;
  }

  final reason = TapUnknownReason(
    position: position,
    hitTest: probe.hitTest,
    search: search,
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    search: search,
    message:
        "Widget '${target.widgetName}' can not be interacted with at position $position where its RenderObject $renderBox was found.\n"
        "The exact reason, why it doesn't receive hitTest events is unknown.\n"
        "If you think this case needs a better error message, create an issue https://github.com/passsy/spot for anyone else running in a similar issue.\n"
        "A small example would be highly appreciated.",
  );
}

Element? _elementForRenderBox(RenderBox renderBox) {
  final debugCreator = renderBox.debugCreator;
  if (debugCreator is! DebugCreator) {
    return null;
  }
  return debugCreator.element;
}

TapInspection? _inspectAbsorbPointer({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required TapHitTestInfo hitTest,
  required TapTargetSearch search,
}) {
  // parents starts at targetElement, an AbsorbPointer on the target itself
  // absorbs its own pointer events and has to be found here, too.
  final absorbElement = targetElement.parents.firstOrNullWhere((it) {
    if (it.widget is! AbsorbPointer) {
      return false;
    }
    final absorbPointer = it.widget as AbsorbPointer;
    return absorbPointer.absorbing;
  });
  if (absorbElement == null) {
    return null;
  }

  final absorbPointer = _tapWidgetInfo(absorbElement);
  final reason = TapAbsorbedReason(
    absorbPointer: absorbPointer,
    hitReceiver: hitTest.receiver,
    hitTest: hitTest,
  );
  final location = absorbElement.debugWidgetLocation?.file.path ??
      absorbElement.debugGetCreatorChain(100);
  final closestReceiver = hitTest.receiver?.element.toStringDeep() ?? '';
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    search: search,
    message:
        "Widget '${target.widgetName}' is wrapped in AbsorbPointer and doesn't receive pointer events.\n"
        "AbsorbPointer is created at $location\n"
        "The closest widget reacting to the touch event is:\n"
        "$closestReceiver",
  );
}

TapInspection? _inspectIgnorePointer({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required TapHitTestInfo hitTest,
  required TapTargetSearch search,
}) {
  // parents starts at targetElement, see _inspectAbsorbPointer.
  final ignoreElement = targetElement.parents.firstOrNullWhere((it) {
    if (it.widget is! IgnorePointer) {
      return false;
    }
    final ignorePointer = it.widget as IgnorePointer;
    return ignorePointer.ignoring;
  });
  if (ignoreElement == null) {
    return null;
  }

  final introducedBy = _findIgnorePointerIntroducer(ignoreElement);
  final reason = TapIgnoredReason(
    ignorePointer: _tapWidgetInfo(ignoreElement),
    introducedBy: introducedBy == null ? null : _tapWidgetInfo(introducedBy),
    hitReceiver: hitTest.receiver,
    hitTest: hitTest,
  );
  final location = ignoreElement.debugWidgetLocation?.file.path ??
      targetElement.debugGetCreatorChain(100);
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    search: search,
    message:
        "Widget '${target.widgetName}' is wrapped in IgnorePointer and doesn't receive pointer events.\n"
        "The IgnorePointer is located at $location",
  );
}

Element? _findIgnorePointerIntroducer(Element ignoreElement) {
  final visibility = ignoreElement.parents.skip(1).firstOrNullWhere((it) {
    return it.widget is Visibility;
  });
  if (visibility != null) {
    return visibility;
  }
  return ignoreElement.parents.skip(1).firstOrNullWhere((it) {
    return it.debugWidgetLocation?.isUserCode ?? false;
  });
}

TapInspection? _inspectZeroSize({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required RenderBox renderBox,
  required TapTargetSearch search,
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
    search: search,
    message:
        "${target.element.toStringShort()} can't be interacted with because it has size ${Size.zero}.\n"
        "${shrinker.toStringShort()} forces ${target.element.toStringShort()} to have the size ${Size.zero}.\n"
        "${shrinker.toStringShort()} ${shrinker.debugWidgetLocation?.file.path}",
  );
}

TapInspection? _inspectCoveredWidget({
  required String selectorDescription,
  required TapWidgetInfo target,
  required Element targetElement,
  required TapHitTestInfo hitTest,
  required TapTargetSearch search,
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

  final coveringWidgets = analysis.coverChain.map(_tapWidgetInfo).toList();
  final relevantCoveringWidgets = coveringWidgets.where((it) {
    return it.isUserCode ?? false;
  }).toList();
  final reason = TapCoveredReason(
    hitTest: hitTest,
    coveringWidgets: coveringWidgets,
    relevantCoveringWidgets: relevantCoveringWidgets,
    commonAncestor: _tapWidgetInfo(analysis.commonAncestor),
    userRelevantAncestor: _tapWidgetInfo(analysis.firstUsefulParent),
    targetChain: analysis.targetChain.map(_tapWidgetInfo).toList(),
    coverChain: analysis.coverChain.map(_tapWidgetInfo).toList(),
  );
  return _tapInspectionFailure(
    selectorDescription: selectorDescription,
    target: target,
    reason: reason,
    search: search,
    message: createCoverWidgetMessage(
      targetName: target.widgetName,
      analysis: analysis,
    ),
  );
}

String? _createPartialCoverageWarningMessage({
  required TapWidgetInfo target,
  required TapTargetSearch search,
}) {
  final roundUp = search.hittablePercent.ceil();
  if (roundUp > 80) {
    return null;
  }

  return "Warning: The '${target.widgetName}' is only partially reacting to tap events. "
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

TapTargetSearch _inspectTapTarget(RenderBox renderBox) {
  final pokablePositions = findPokablePositions(
    renderBox,
    collectHitTests: true,
  );
  final samples = pokablePositions.samples.mapNotNull((it) {
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
  return TapTargetSearch(
    searchArea: pokablePositions.searchArea,
    spacing: pokablePositions.spacing,
    samples: samples,
    bestTapPosition: pokablePositions.mostCenterHittablePosition,
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

List<HitTestEntry> _hitTestEntriesAt(Offset position) {
  final result = HitTestResult();
  // ignore: deprecated_member_use
  WidgetsBinding.instance.hitTest(result, position);
  return result.path.toList();
}

TapWidgetInfo _tapWidgetInfo(Element element) {
  final renderObject = element.renderObject;
  final renderBox = renderObject is RenderBox ? renderObject : null;
  return TapWidgetInfo(
    widget: element.widget,
    element: element,
    renderObject: renderObject,
    widgetName: element.toStringShort(),
    paintBounds: renderBox?.paintBounds,
    globalRect: renderBox?.globalRect,
  );
}

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
  /// Creates a tap inspection result.
  TapInspection({
    required this.selectorDescription,
    required this.target,
    required this.search,
    required this.tapPosition,
    required this.message,
    required this.reason,
    required this.warning,
  });

  /// Human-readable selector description used in diagnostics.
  final String selectorDescription;

  /// The single widget selected as tap target, if one was found.
  final TapWidgetInfo? target;

  /// Sampled hit-test information used to find a tappable point.
  final TapTargetSearch? search;

  /// The position [Act.tap] would use.
  final Offset? tapPosition;

  /// A plain-text message describing why [Act.tap] cannot tap the selector.
  final String? message;

  /// The reason why [Act.tap] cannot tap the selector, if any.
  final Object? reason;

  /// Non-fatal diagnostic information about a tappable target.
  final TapInspectionWarning? warning;

  /// Whether [Act.tap] can tap the selector.
  bool get canTap => reason == null && tapPosition != null;

  /// Returns the not-found reason or throws a [TestFailure].
  TapNotFoundReason get tapNotFoundReason {
    return _failureReason<TapNotFoundReason>();
  }

  /// Returns the multiple-widgets reason or throws a [TestFailure].
  TapMultipleWidgetsFoundReason get tapMultipleWidgetsFoundReason {
    return _failureReason<TapMultipleWidgetsFoundReason>();
  }

  /// Returns the no-render-object reason or throws a [TestFailure].
  TapNoRenderObjectReason get tapNoRenderObjectReason {
    return _failureReason<TapNoRenderObjectReason>();
  }

  /// Returns the non-render-box reason or throws a [TestFailure].
  TapNonRenderBoxReason get tapNonRenderBoxReason {
    return _failureReason<TapNonRenderBoxReason>();
  }

  /// Returns the outside-viewport reason or throws a [TestFailure].
  TapOutsideViewportReason get tapOutsideViewportReason {
    return _failureReason<TapOutsideViewportReason>();
  }

  /// Returns the zero-size reason or throws a [TestFailure].
  TapZeroSizeReason get tapZeroSizeReason {
    return _failureReason<TapZeroSizeReason>();
  }

  /// Returns the absorbed reason or throws a [TestFailure].
  TapAbsorbedReason get tapAbsorbedReason {
    return _failureReason<TapAbsorbedReason>();
  }

  /// Returns the ignored reason or throws a [TestFailure].
  TapIgnoredReason get tapIgnoredReason {
    return _failureReason<TapIgnoredReason>();
  }

  /// Returns the covered reason or throws a [TestFailure].
  TapCoveredReason get tapCoveredReason {
    return _failureReason<TapCoveredReason>();
  }

  /// Returns the unknown reason or throws a [TestFailure].
  TapUnknownReason get tapUnknownReason {
    return _failureReason<TapUnknownReason>();
  }

  /// Returns the partial-coverage warning reason or throws a [TestFailure].
  TapPartialCoverageReason get tapPartialCoverageReason {
    return _warningReason<TapPartialCoverageReason>();
  }

  R _failureReason<R extends Object>() {
    final reason = this.reason;
    if (reason == null) {
      throw TestFailure(
        'Expected $R but $selectorDescription can be tapped.',
      );
    }

    if (reason is R) {
      return reason;
    }

    throw TestFailure(
      'Expected $R but tap failed with ${reason.runtimeType}.\n'
      '$message',
    );
  }

  R _warningReason<R extends Object>() {
    final warning = this.warning;
    if (warning == null) {
      throw TestFailure(
        'Expected $R but $selectorDescription has no tap warning.',
      );
    }

    final reason = warning.reason;
    if (reason is R) {
      return reason;
    }

    throw TestFailure(
      'Expected $R but tap warning is ${reason.runtimeType}.\n'
      '${warning.message}',
    );
  }
}

/// Non-fatal warning produced by [Act.inspectTap].
class TapInspectionWarning {
  /// Creates a tap inspection warning.
  TapInspectionWarning({
    required this.message,
    required this.reason,
  });

  /// A plain-text message describing the warning.
  final String message;

  /// Typed warning metadata.
  final Object? reason;
}

/// Details about a widget involved in tap inspection.
class TapWidgetInfo {
  /// Creates widget information for tap diagnostics.
  TapWidgetInfo({
    required this.widget,
    required this.element,
    required this.renderObject,
    required this.widgetName,
    required this.paintBounds,
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
  /// Resolved on access. A widget's creation location does not change, so this
  /// stays accurate no matter when it is read, unlike [globalRect].
  String? get sourceLocation => element.debugWidgetLocation?.file.path;

  /// Whether Flutter reports this widget as user code.
  ///
  /// Resolved on access, see [sourceLocation].
  bool? get isUserCode => element.debugWidgetLocation?.isUserCode;

  /// The render object's local paint bounds, if it is a [RenderBox].
  final Rect? paintBounds;

  /// The render object's global rectangle, if it is a [RenderBox].
  final Rect? globalRect;

  /// The render object's size, if it is a [RenderBox].
  Size? get size => globalRect?.size;

  /// The center of [globalRect], if available.
  Offset? get globalCenter => globalRect?.center;

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

/// Sampled search used to find a tappable position on a widget.
class TapTargetSearch {
  /// Creates tap-target search information.
  TapTargetSearch({
    required this.searchArea,
    required this.spacing,
    required List<TapHitSample> samples,
    required this.bestTapPosition,
  }) : samples = List.unmodifiable(samples);

  /// The global rectangle covered by the sampled target.
  final Rect searchArea;

  /// Pixel distance between sampled points.
  ///
  /// Describes the search that produced this result: [samples] holds one entry
  /// per point of a uniform grid with this step size, covering [searchArea].
  /// A future spot version may search differently.
  final int spacing;

  /// All sampled hit-test points, see [spacing].
  ///
  /// Prefer [blockers] and [hittablePercent] to answer what is in the way and
  /// how much of the target is reachable. They stay meaningful no matter how
  /// the points were picked.
  final List<TapHitSample> samples;

  /// Best tap position selected from [hittablePositions].
  final Offset? bestTapPosition;

  /// Samples that reached the target render object.
  List<TapHitSample> get hittableSamples {
    return samples.where((it) => it.hitsTarget).toList();
  }

  /// Samples that did not reach the target render object.
  List<TapHitSample> get blockedSamples {
    return samples.where((it) => !it.hitsTarget).toList();
  }

  /// Global positions that reached the target render object.
  List<Offset> get hittablePositions {
    return hittableSamples.map((it) => it.globalPosition).toList();
  }

  /// Global positions that did not reach the target render object.
  List<Offset> get blockedPositions {
    return blockedSamples.map((it) => it.globalPosition).toList();
  }

  /// Percentage of sampled points that reached the target render object.
  double get hittablePercent {
    if (samples.isEmpty) {
      return 0;
    }
    return hittableSamples.length / samples.length * 100;
  }

  /// Whether every sampled point reached the target.
  bool get isFullyHittable {
    return samples.isNotEmpty && blockedSamples.isEmpty;
  }

  /// Whether no sampled point reached the target.
  bool get isUnreachable {
    return hittableSamples.isEmpty;
  }

  /// The area of [searchArea] that actually reacts to pointer events.
  ///
  /// `null` when nothing was reachable. Derived from sampled points, so it is
  /// accurate to [spacing] rather than to the pixel.
  Rect? get hittableBounds {
    final positions = hittablePositions;
    if (positions.isEmpty) {
      return null;
    }
    return Rect.fromLTRB(
      positions.map((it) => it.dx).reduce(min),
      positions.map((it) => it.dy).reduce(min),
      positions.map((it) => it.dx).reduce(max),
      positions.map((it) => it.dy).reduce(max),
    );
  }

  /// The widgets that received pointer events instead of the target, the one
  /// covering the most of it first.
  ///
  /// Answers what is in the way without walking [samples]:
  ///
  /// ```dart
  /// final blocker = act.inspectTap(spot<MyButton>()).search!.blockers.first;
  /// print('${blocker.widget.widgetName} covers ${blocker.percent}%');
  /// ```
  List<TapBlocker> get blockers {
    final counts = <Element, int>{};
    final widgets = <Element, TapWidgetInfo>{};
    for (final sample in blockedSamples) {
      final receiver = sample.blockedBy;
      if (receiver == null) {
        continue;
      }
      counts[receiver.element] = (counts[receiver.element] ?? 0) + 1;
      widgets[receiver.element] ??= receiver;
    }
    final blockers = counts.entries.map((entry) {
      return TapBlocker(
        widget: widgets[entry.key]!,
        sampleCount: entry.value,
        percent: samples.isEmpty ? 0 : entry.value / samples.length * 100,
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
    required this.widget,
    required this.sampleCount,
    required this.percent,
  });

  /// The widget that received the pointer events.
  final TapWidgetInfo widget;

  /// How many sampled points this widget intercepted.
  final int sampleCount;

  /// Percentage of the target this widget covers, measured in sampled points.
  final double percent;

  @override
  String toString() {
    return '${widget.widgetName} (${percent.round()}%)';
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
    required this.hitReceiver,
    required this.hitTest,
  });

  /// The [AbsorbPointer] that absorbs pointer events.
  final TapWidgetInfo absorbPointer;

  /// The widget that received the inspected hit-test first.
  final TapWidgetInfo? hitReceiver;

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;
}

/// An [IgnorePointer] prevents the target from receiving pointer events.
class TapIgnoredReason {
  /// Creates an ignored tap failure reason.
  TapIgnoredReason({
    required this.ignorePointer,
    required this.introducedBy,
    required this.hitReceiver,
    required this.hitTest,
  });

  /// The [IgnorePointer] that removes the target subtree from hit testing.
  final TapWidgetInfo ignorePointer;

  /// The user-relevant widget that introduced [ignorePointer], if known.
  final TapWidgetInfo? introducedBy;

  /// The widget that received the inspected hit-test first.
  final TapWidgetInfo? hitReceiver;

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;
}

/// Another widget covers the target.
class TapCoveredReason {
  /// Creates a covered tap failure reason.
  TapCoveredReason({
    required this.hitTest,
    required List<TapWidgetInfo> coveringWidgets,
    required List<TapWidgetInfo> relevantCoveringWidgets,
    required this.commonAncestor,
    required this.userRelevantAncestor,
    required List<TapWidgetInfo> targetChain,
    required List<TapWidgetInfo> coverChain,
  })  : coveringWidgets = List.unmodifiable(coveringWidgets),
        relevantCoveringWidgets = List.unmodifiable(relevantCoveringWidgets),
        targetChain = List.unmodifiable(targetChain),
        coverChain = List.unmodifiable(coverChain);

  /// Hit-test path at the inspected position.
  final TapHitTestInfo hitTest;

  /// Widgets that cover the target before the common ancestor.
  final List<TapWidgetInfo> coveringWidgets;

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
    if (coveringWidgets.isEmpty) {
      return null;
    }
    return coveringWidgets.first;
  }
}

/// No known reason explains why the target cannot be tapped.
class TapUnknownReason {
  /// Creates an unknown tap failure reason.
  TapUnknownReason({
    required this.position,
    required this.hitTest,
    required this.search,
  });

  /// Inspected global position.
  final Offset position;

  /// Hit-test path at [position].
  final TapHitTestInfo hitTest;

  /// Sampled tap search data.
  final TapTargetSearch search;
}

/// The target is tappable but only partially reacts to tap events.
class TapPartialCoverageReason {
  /// Creates a partial-coverage tap warning reason.
  TapPartialCoverageReason({
    required this.search,
  });

  /// Sampled tap search data.
  final TapTargetSearch search;
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
