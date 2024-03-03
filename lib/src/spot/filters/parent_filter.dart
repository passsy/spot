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
      // TODO unnecessary? snapshot does this by default already
      widgetSnapshot.validateQuantity();
      return widgetSnapshot;
    }).toList();

    final List<Map<WidgetTreeNode, List<WidgetSnapshot>>> discoveryByParent =
        [];

    for (final parentSnapshot in parentSnapshots) {
      final Map<WidgetTreeNode, List<WidgetSnapshot>> groups = {};
      if (parentSnapshot.discovered.isEmpty) {
        discoveryByParent.add(groups);
        continue;
      }

      for (final WidgetTreeNode node in parentSnapshot.discovered) {
        groups[node] ??= [];
        // final s2 =
        //     snapshot(spotAllWidgets().withParent(parentSnapshot.selector));
        // groups[node]!.add(s2);

        // TODO what's the difference between s1 and s2?
        // s2 works but is slow, s1 is fast but doesn't work

        final root = node.isOffstage ? spotOffstage() : spotAllWidgets();

        final subtree = tree.scope(node);
        final s1 = WidgetSnapshot(
          selector: root.withParent(parentSnapshot.selector),
          discovered: [
            // TODO is returning the root correct?
            node,
            ...subtree.allNodes,
          ],
          scope: subtree,
          debugCandidates: candidates.map((it) => it.element).toList(),
        );
        groups[node]!.add(s1);
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
