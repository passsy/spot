import 'package:spot/src/spot/query_stats.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Removes all [WidgetTreeNode] that are offstage
class OnstageFilter implements ElementFilter {
  @override
  Object get cacheKey => OnstageFilter;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final List<WidgetTreeNode> onstage = [];

    for (final WidgetTreeNode candidate in candidates) {
      QueryStatsCounter.candidateChecks++;
      if (!candidate.isOffstage) {
        onstage.add(candidate);
      }
    }
    return onstage;
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

/// Removes all [WidgetTreeNode] that are onstage
class OffstageFilter implements ElementFilter {
  @override
  Object get cacheKey => OffstageFilter;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final List<WidgetTreeNode> offstage = [];

    for (final WidgetTreeNode candidate in candidates) {
      QueryStatsCounter.candidateChecks++;
      if (candidate.isOffstage) {
        offstage.add(candidate);
      }
    }
    return offstage;
  }

  @override
  String get description {
    return 'keeps only offstage elements';
  }

  @override
  String toString() {
    return 'OffstageFilter which $description';
  }
}
