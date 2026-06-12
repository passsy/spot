import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/query_stats.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Filters candidates by widget type [W] comparing the runtime type.
///
/// Comparing the runtimeType makes sure that `spot<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
class WidgetTypeFilter<W extends Widget> implements ElementFilter {
  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    if (W == Widget) {
      // [W] is the broadest possible type, this filter is a no-op that keeps
      // all candidates.
      return candidates;
    }
    final type = _typeOf<W>();
    return candidates.where((WidgetTreeNode node) {
      QueryStats.candidateChecks++;
      return node.element.widget.runtimeType == type;
    }).toList();
  }

  @override
  String get description => '$W';

  @override
  String toString() {
    return 'WidgetTypeFilter of $W';
  }
}

Type _typeOf<T>() => T;
