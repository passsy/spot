import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Filters widgets that are hit at a given global [position].
class PositionFilter implements ElementFilter {
  /// Creates a filter that keeps widgets hit by a hit test at [position].
  PositionFilter(this.position);

  /// The global screen position used for hit testing.
  final Offset position;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final HitTestResult result = HitTestResult();
    // Flutter 3.10 does not expose the view-aware hitTestInView API yet.
    // When support for Flutter 3.10 is dropped, use
    // RendererBinding.instance.hitTestInView() so the hit test can target the
    // intended FlutterView explicitly instead of relying on the implicit view.
    // ignore: deprecated_member_use
    WidgetsBinding.instance.hitTest(result, position);
    final hits = result.path
        .map((entry) => _elementFromHitTarget(entry.target))
        .whereType<Element>()
        .toList();
    final hitElements = <Element>[];
    final hitElementSet = <Element>{};
    for (final element in hits) {
      if (!hitElementSet.add(element)) {
        continue;
      }
      hitElements.add(element);
    }

    final matchedByElement = <Element, WidgetTreeNode>{};
    for (final node in candidates) {
      if (!hitElementSet.contains(node.element)) {
        continue;
      }
      matchedByElement[node.element] = node;
    }

    return hitElements
        .map((element) => matchedByElement[element])
        .whereType<WidgetTreeNode>();
  }

  @override
  String get description => 'at position $position';

  @override
  String toString() => 'PositionFilter($position)';
}

Element? _elementFromHitTarget(HitTestTarget target) {
  if (target is! RenderObject) {
    return null;
  }
  final debugCreator = target.debugCreator;
  if (debugCreator is! DebugCreator) {
    return null;
  }
  return debugCreator.element;
}
