import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';

class ParentFilter implements ElementFilter {
  ParentFilter(this.parents);

  final List<WidgetSelector> parents;

  @override
  String get description {
    if (parents.length == 1) {
      return 'with parent ${parents.first.toStringBreadcrumb()}';
    }
    return 'with parents [${parents.map((e) => e.toStringBreadcrumb()).join(', ')}]';
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
        final WidgetSnapshot group =
            findWithinScope(tree.scope(node), WidgetSelector.all);
        final list = groups[node];
        if (list == null) {
          groups[node] = [group];
        } else {
          list.add(group);
        }
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
