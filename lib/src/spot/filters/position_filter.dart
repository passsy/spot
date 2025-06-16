import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
    // ignore: deprecated_member_use
    WidgetsBinding.instance.hitTest(result, position);
    final Set<Element> hits = result.path
        .map((entry) {
          if (entry.target is! RenderObject) return null;
          final t = entry.target as RenderObject;
          if (t.debugCreator is! DebugCreator?) return null;
          final debugCreator = t.debugCreator as DebugCreator?;
          return debugCreator?.element;
        })
        .whereType<Element>()
        .toSet();

    return candidates.where((node) => hits.contains(node.element));
  }

  @override
  String get description => 'at position $position';

  @override
  String toString() => 'PositionFilter($position)';
}
