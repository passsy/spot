import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

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
    final tree = currentWidgetTreeSnapshot();
    final List<WidgetSnapshot<Widget>> parentSnapshots =
        parents.map((selector) {
      final WidgetSnapshot<Widget> widgetSnapshot = snapshot(selector);
      widgetSnapshot.validateQuantity();
      return widgetSnapshot;
    }).toList();

    // Take a snapshot from each parent and get the snapshots of all nodes that match
    final List<Map<WidgetTreeNode, List<WidgetSnapshot>>> discoveryByParent =
        parentSnapshots.map((WidgetSnapshot<Widget> parentSnapshot) {
      final Map<WidgetTreeNode, List<WidgetSnapshot>> groups = {};
      if (parentSnapshot.discovered.isEmpty) {
        return groups;
      }

      for (final WidgetTreeNode node in parentSnapshot.discovered) {
        final subtree = tree.scope(node);
        final snapshot = WidgetSnapshot(
          selector: WidgetSelector.all.withParent(parentSnapshot.selector),
          discovered: subtree.allNodes,
          scope: subtree,
          debugCandidates: candidates.map((it) => it.element).toList(),
        );
        groups[node] ??= [];
        groups[node]!.add(snapshot);
      }

      return groups;
    }).toList();

    final List<WidgetSnapshot> discoveredSnapshots =
        discoveryByParent.map((it) => it.values).flatten().flatten().toList();

    final List<WidgetTreeNode> allDiscoveredNodes =
        discoveredSnapshots.map((it) => it.discovered).flatten().toList();

    final List<Element> distinctElements =
        allDiscoveredNodes.map((e) => e.element).toSet().toList();

    // find nodes that exist in all parents
    final List<Element> elementsInAllParents =
        distinctElements.where((element) {
      return discoveryByParent.all((
        Map<WidgetTreeNode, List<WidgetSnapshot>> discovered,
      ) {
        return discovered.values.any((List<WidgetSnapshot> list) {
          return list.any((node) {
            return node.discovered.map((e) => e.element).contains(element);
          });
        });
      });
    }).toList();

    return elementsInAllParents.mapNotNull((e) {
      return candidates.firstOrNullWhere((node) => node.element == e);
    }).toList();
  }

  @override
  String toString() {
    return 'ParentFilter $description';
  }
}
