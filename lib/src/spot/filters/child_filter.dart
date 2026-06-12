import 'package:dartx/dartx.dart';
import 'package:spot/src/spot/query_stats.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Keeps all [WidgetTreeNode] that have child elements that match
/// the [childSelectors] selectors
class ChildFilter implements ElementFilter {
  /// Constructs a [ChildFilter] with a list of
  /// [WidgetSelector]s for matching child elements.
  ChildFilter(this.childSelectors) : assert(childSelectors.isNotEmpty);

  /// A list of [WidgetSelector]s used to match child elements of the widget
  /// tree nodes.
  ///
  /// The filter checks each candidate node to see if its children satisfy the
  /// conditions defined in these selectors.
  final List<WidgetSelector> childSelectors;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    if (childSelectors.isEmpty) {
      return candidates;
    }

    // First check all negate selectors (where maxQuantity == 0)
    final negates =
        childSelectors.where((e) => e.quantityConstraint.max == 0).toList();
    for (final negate in negates) {
      final s = snapshot(negate, validateQuantity: false);
      if (s.discovered.isNotEmpty) {
        // this negate selector matches, which it shouldn't
        return [];
      }
    }

    final List<WidgetSelector> matchSelectors = childSelectors - negates;

    // Snapshot each child selector once (the result is independent of the
    // candidates). Then walk from every discovered child up to the root and
    // count the matches below each ancestor, instead of searching the
    // subtree of every candidate over and over again.
    final List<Map<WidgetTreeNode, int>> matchCountsPerSelector = [];
    for (final WidgetSelector childSelector in matchSelectors) {
      final WidgetSnapshot childSnapshot =
          snapshot(childSelector, validateQuantity: false);

      final Map<WidgetTreeNode, int> matchesBelowNode = Map.identity();
      for (final WidgetTreeNode match in childSnapshot.discovered) {
        // Start above the match, a widget is not its own child
        WidgetTreeNode? ancestor = match.parent;
        while (ancestor != null) {
          QueryStatsCounter.relationChecks++;
          matchesBelowNode[ancestor] = (matchesBelowNode[ancestor] ?? 0) + 1;
          ancestor = ancestor.parent;
        }
      }
      matchCountsPerSelector.add(matchesBelowNode);
    }

    final List<WidgetTreeNode> matchingChildNodes = [];
    for (final WidgetTreeNode candidate in candidates) {
      bool allChildrenMatch = true;
      for (int i = 0; i < matchSelectors.length; i++) {
        QueryStatsCounter.relationChecks++;
        final int matchCount = matchCountsPerSelector[i][candidate] ?? 0;
        if (!_matchesQuantityConstraint(matchSelectors[i], matchCount)) {
          allChildrenMatch = false;
          break;
        }
      }
      if (allChildrenMatch) {
        matchingChildNodes.add(candidate);
      }
    }
    return matchingChildNodes;
  }

  @override
  String get description {
    if (childSelectors.length == 1) {
      return childSelectors.first.toStringBreadcrumb();
    }
    return '[${childSelectors.map((e) => e.toStringBreadcrumb()).join(', ')}]';
  }

  @override
  String toString() {
    return 'ChildFilter $description';
  }
}

/// Whether [matchCount] children found below a candidate satisfy the
/// [QuantityConstraint] of [childSelector].
///
/// At least one child has to match, even when the constraint allows zero
/// matches (e.g. `atMost(2)`).
bool _matchesQuantityConstraint(
  WidgetSelector childSelector,
  int matchCount,
) {
  if (matchCount == 0) {
    return false;
  }
  final minConstraint = childSelector.quantityConstraint.min;
  if (minConstraint != null && minConstraint > matchCount) {
    // found less than the minimum required
    return false;
  }
  final maxConstraint = childSelector.quantityConstraint.max;
  if (maxConstraint != null && maxConstraint < matchCount) {
    // found more than the maximum allowed
    return false;
  }
  return true;
}
