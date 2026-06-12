import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/query_stats.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// A filter that checks if the candidates are children of all [parents]
class ParentFilter implements ElementFilter {
  /// Creates a [ParentFilter] with a list of [parents]
  ParentFilter(this.parents) : assert(parents.isNotEmpty);

  /// The list of [WidgetSelector] that are checked to be parents of the candidates
  final List<WidgetSelector> parents;

  @override
  String get description {
    if (parents.length == 1) {
      return parents.first.toStringBreadcrumb();
    }
    return '[${parents.map((e) => e.toStringBreadcrumb()).join(', ')}]';
  }

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    // The elements each parent selector discovered. A candidate matches a
    // parent selector when the candidate itself, or one of its ancestors,
    // was discovered by that selector.
    final List<Set<Element>> parentSets = [];
    for (final selector in parents) {
      final WidgetSnapshot<Widget> widgetSnapshot =
          snapshot(selector, validateQuantity: false);

      // handle negates
      if (selector.quantityConstraint.max == 0) {
        throw UnimplementedError(
          'Parents can not be negated, yet. Please upvote https://github.com/passsy/spot/issues/49',
        );
      }
      widgetSnapshot.validateQuantity();
      parentSets.add(
        widgetSnapshot.discovered.map((node) => node.element).toSet(),
      );
    }

    // Instead of searching downwards from every discovered parent (which
    // visits whole subtrees), walk from each candidate up to the root. The
    // path to the root is short (the tree depth), and each step is a single
    // hash lookup per parent selector.
    final List<WidgetTreeNode> remaining = [];
    for (final candidate in candidates) {
      if (_isWithinAllParents(candidate, parentSets)) {
        remaining.add(candidate);
      }
    }
    return remaining;
  }

  @override
  String toString() {
    return 'ParentFilter which keeps $description Widget';
  }
}

/// Returns true when, for every parent selector, [candidate] or one of its
/// ancestors was discovered by that selector ([parentSets]).
///
/// Different parent selectors may be satisfied by different ancestors.
bool _isWithinAllParents(
  WidgetTreeNode candidate,
  List<Set<Element>> parentSets,
) {
  final List<Set<Element>> unsatisfied = parentSets.toList();
  WidgetTreeNode? node = candidate;
  while (node != null && unsatisfied.isNotEmpty) {
    final element = node.element;
    QueryStatsCounter.relationChecks += unsatisfied.length;
    unsatisfied.removeWhere((parentSet) => parentSet.contains(element));
    node = node.parent;
  }
  return unsatisfied.isEmpty;
}
