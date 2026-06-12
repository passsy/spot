/// Counters tracking how much work the spot query engine performs.
///
/// Only ever use this for debugging and performance regression tests.
/// The exact numbers are an implementation detail of the query engine and
/// may change between spot versions.
class QueryStats {
  QueryStats._();

  /// Number of `WidgetTreeNode`s materialized while traversing the widget
  /// tree (full tree walks and subtree walks).
  static int nodesTraversed = 0;

  /// Number of candidates evaluated by primitive filters
  /// (type checks, predicates, text matches, onstage checks).
  static int candidateChecks = 0;

  /// Number of node/element comparisons performed while resolving
  /// parent/child relationships between selectors.
  static int relationChecks = 0;

  /// Number of `snapshot()` invocations, including recursive invocations for
  /// parent and child selectors.
  static int snapshotCalls = 0;

  /// Resets all counters to zero.
  static void reset() {
    nodesTraversed = 0;
    candidateChecks = 0;
    relationChecks = 0;
    snapshotCalls = 0;
  }

  /// Sum of all counters, the total work done by the query engine.
  static int get totalChecks {
    return nodesTraversed + candidateChecks + relationChecks;
  }

  /// A human readable summary of all counters.
  static String summary() {
    return 'QueryStats('
        'nodesTraversed: $nodesTraversed, '
        'candidateChecks: $candidateChecks, '
        'relationChecks: $relationChecks, '
        'snapshotCalls: $snapshotCalls, '
        'total: $totalChecks)';
  }
}
