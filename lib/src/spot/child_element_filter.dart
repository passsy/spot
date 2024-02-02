import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Keeps all [WidgetTreeNode] that have child elements that match
/// the [childSelectors] selectors
class ChildFilter implements ElementFilter {
  /// Constructs a [ChildFilter] with a list of
  /// [WidgetSelector]s for matching child elements.
  ChildFilter(this.childSelectors);

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
    final tree = currentWidgetTreeSnapshot();

    // First check all negate selectors (where maxQuantity == 0)
    final negates = childSelectors.where((e) => e.quantityConstraint.max == 0);
    for (final negate in negates) {
      final s = snapshot(negate, validateQuantity: false);
      if (s.discovered.isNotEmpty) {
        // this negate selector matches, which it shouldn't
        return [];
      }
    }

    final List<WidgetTreeNode> matchingChildNodes = [];

    // Then check for every queryMatch if the children and props match
    for (final WidgetTreeNode candidate in candidates) {
      final Map<WidgetSelector, List<WidgetTreeNode>> matchesPerChild = {};

      final ScopedWidgetTreeSnapshot subtree = tree.scope(candidate);
      final List<WidgetTreeNode> subtreeNodes = subtree.allNodes;
      for (final WidgetSelector<Widget> childSelector
          in childSelectors - negates) {
        matchesPerChild[childSelector] = [];
        // TODO instead of searching the children, starting from the root widget, find a way to reverse the search and
        //  start form the subtree.
        //  Keep in mind, each child selector might be defined with parents which are outside of the subtree
        final WidgetSnapshot ss =
            snapshot(childSelector, validateQuantity: false);

        final minConstraint = childSelector.quantityConstraint.min;
        final maxConstraint = childSelector.quantityConstraint.max;

        final discoveredInSubtree =
            ss.discovered.where((node) => subtreeNodes.contains(node)).toList();

        if (minConstraint == null &&
            maxConstraint == null &&
            discoveredInSubtree.isEmpty) {
          // This childSelector doesn't match any child
          continue;
        }

        if (minConstraint != null &&
            minConstraint > discoveredInSubtree.length) {
          // not a match found less than the minimum required
          continue;
        }
        if (maxConstraint != null &&
            maxConstraint < discoveredInSubtree.length) {
          // not a match because found more than the maximum allowed
          continue;
        }

        // consider it as a match
        matchesPerChild[childSelector] = discoveredInSubtree;
      }
      // TODO early exist the loop above instead of adding an empty list to the map
      if (matchesPerChild.values.any((list) => list.isEmpty)) {
        // not all children match
        continue;
      }
      matchingChildNodes.add(candidate);
    }
    return matchingChildNodes;
  }

  @override
  String get description {
    if (childSelectors.length == 1) {
      return 'with child ${childSelectors.first.toStringBreadcrumb()}';
    }
    return 'with children [${childSelectors.map((e) => e.toStringBreadcrumb()).join(', ')}]';
  }

  @override
  String toString() {
    return 'ChildFilter $description';
  }
}
