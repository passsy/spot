import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Removes all [WidgetTreeNode] that are offstage
class OnstageFilter implements ElementFilter {
  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final List<WidgetTreeNode> matchingChildNodes = [];

    for (final WidgetTreeNode candidate in candidates) {
      if (!candidate.isOffstage) {
        matchingChildNodes.add(candidate);
      }
    }
    return matchingChildNodes;
  }

  @override
  String get description {
    return 'removes all offstage elements';
  }

  @override
  String toString() {
    return 'OnstageFilter which $description';
  }
}
