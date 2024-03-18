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

    final List<WidgetSnapshot<Widget>> parentSnapshots = [];
    for (final selector in parents) {
      final WidgetSnapshot<Widget> widgetSnapshot =
          snapshot(selector, validateQuantity: false);

      // handle negates
      if (selector.quantityConstraint.max == 0) {
        if (widgetSnapshot.discovered.isNotEmpty) {
          // found items
          // TODO what if the items are found, but are part of a different subtree?
          return [];
        }
      } else {
        widgetSnapshot.validateQuantity();
        parentSnapshots.add(widgetSnapshot);
      }
    }

    final List<Map<WidgetTreeNode, List<WidgetSnapshot>>> discoveryByParent =
        [];

    for (final parentSnapshot in parentSnapshots) {
      final Map<WidgetTreeNode, List<WidgetSnapshot>> groups = {};
      final isNegate = parentSnapshot.selector.quantityConstraint.max == 0;

      if (parentSnapshot.discovered.isEmpty) {
        discoveryByParent.add(groups);
        continue;
      }

      // remove elements when the parent is already in the list. This prevents searching all element of a subtree, resulting in always the same items
      final rootNodes = parentSnapshot.discovered
          .whereNot(
            (element) => parentSnapshot.discovered.contains(element.parent),
          )
          .toList();

      for (final WidgetTreeNode node in rootNodes) {
        groups[node] ??= [];

        if (isNegate) {
          final List<WidgetTreeNode> subtree = tree.scope(node).allNodes;
          final List<WidgetTreeNode> all = tree.allNodes;
          final remaining = all - subtree - [node];

          final snapshot = WidgetSnapshot(
            selector: spotAllWidgets().withChild(parentSnapshot.selector),
            discovered: remaining,
            scope: tree,
            debugCandidates: candidates.map((it) => it.element).toList(),
          );
          groups[node]!.add(snapshot);
        } else {
          final root = node.isOffstage ? spotOffstage() : spotAllWidgets();
          final subtree = tree.scope(node);
          final snapshot = WidgetSnapshot(
            selector: root.withParent(spotElement(node.element)),
            discovered: [
              node,
              ...subtree.allNodes,
            ],
            scope: subtree,
            debugCandidates: candidates.map((it) => it.element).toList(),
          );
          groups[node]!.add(snapshot);
        }
      }

      discoveryByParent.add(groups);
    }

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

    final remaining = elementsInAllParents.mapNotNull((e) {
      return candidates.firstOrNullWhere((node) {
        return node.element == e;
      });
    }).toList();

    return remaining;
  }

  @override
  String toString() {
    return 'ParentFilter which keeps $description Widget';
  }
}
