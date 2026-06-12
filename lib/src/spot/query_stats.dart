/// The amount of work the query engine performed to evaluate a selector,
/// available via `WidgetSnapshot.queryStats`.
///
/// Useful to detect and debug slow queries:
///
/// ```dart
/// final snapshot = spot<AppBar>().spotText('Home').snapshot();
/// print(snapshot.queryStats); // QueryStats(..., total: 15637)
/// ```
///
/// The exact numbers are an implementation detail of the query engine and
/// may change between spot versions. Only ever use them for debugging and
/// relative comparisons, like guarding against performance regressions.
class QueryStats {
  /// Creates immutable [QueryStats].
  const QueryStats({
    required this.nodesTraversed,
    required this.candidateChecks,
    required this.relationChecks,
    required this.snapshotCalls,
    required this.cacheHits,
    required this.cacheHitChecks,
  });

  /// Stats of a query that did no work at all.
  static const QueryStats zero = QueryStats(
    nodesTraversed: 0,
    candidateChecks: 0,
    relationChecks: 0,
    snapshotCalls: 0,
    cacheHits: 0,
    cacheHitChecks: 0,
  );

  /// Number of `WidgetTreeNode`s materialized while traversing the widget
  /// tree.
  final int nodesTraversed;

  /// Number of candidates evaluated by primitive filters
  /// (type checks, predicates, text matches, onstage checks).
  final int candidateChecks;

  /// Number of node/element comparisons performed while resolving
  /// parent/child relationships between selectors.
  final int relationChecks;

  /// Number of selector evaluations, including the recursive evaluations of
  /// parent and child selectors.
  final int snapshotCalls;

  /// Number of stage-prefix results reused from cache.
  final int cacheHits;

  /// [totalChecks] avoided by cache hits.
  final int cacheHitChecks;

  /// Sum of [nodesTraversed], [candidateChecks] and [relationChecks].
  int get totalChecks {
    return nodesTraversed + candidateChecks + relationChecks;
  }

  /// Ratio of avoided checks to the uncached checks.
  double get cacheRatio {
    final uncachedChecks = totalChecks + cacheHitChecks;
    if (uncachedChecks == 0) {
      return 0;
    }
    return cacheHitChecks / uncachedChecks;
  }

  /// Returns the difference between two measurements.
  QueryStats operator -(QueryStats other) {
    return QueryStats(
      nodesTraversed: nodesTraversed - other.nodesTraversed,
      candidateChecks: candidateChecks - other.candidateChecks,
      relationChecks: relationChecks - other.relationChecks,
      snapshotCalls: snapshotCalls - other.snapshotCalls,
      cacheHits: cacheHits - other.cacheHits,
      cacheHitChecks: cacheHitChecks - other.cacheHitChecks,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QueryStats &&
            runtimeType == other.runtimeType &&
            nodesTraversed == other.nodesTraversed &&
            candidateChecks == other.candidateChecks &&
            relationChecks == other.relationChecks &&
            snapshotCalls == other.snapshotCalls &&
            cacheHits == other.cacheHits &&
            cacheHitChecks == other.cacheHitChecks;
  }

  @override
  int get hashCode {
    return Object.hash(
      nodesTraversed,
      candidateChecks,
      relationChecks,
      snapshotCalls,
      cacheHits,
      cacheHitChecks,
    );
  }

  @override
  String toString() {
    return 'QueryStats('
        'nodesTraversed: $nodesTraversed, '
        'candidateChecks: $candidateChecks, '
        'relationChecks: $relationChecks, '
        'snapshotCalls: $snapshotCalls, '
        'cacheHits: $cacheHits, '
        'cacheHitChecks: $cacheHitChecks, '
        'cacheRatio: ${(cacheRatio * 100).toStringAsFixed(0)}%, '
        'total: $totalChecks)';
  }
}

/// Internal counters the query engine increments while evaluating selectors.
///
/// `snapshot()` reads [total] before and after evaluating a selector and
/// attaches the difference to the created `WidgetSnapshot` as [QueryStats].
/// The absolute values are meaningless, only differences are reported.
class QueryStatsCounter {
  QueryStatsCounter._();

  /// See [QueryStats.nodesTraversed]
  static int nodesTraversed = 0;

  /// See [QueryStats.candidateChecks]
  static int candidateChecks = 0;

  /// See [QueryStats.relationChecks]
  static int relationChecks = 0;

  /// See [QueryStats.snapshotCalls]
  static int snapshotCalls = 0;

  /// See [QueryStats.cacheHits]
  static int cacheHits = 0;

  /// See [QueryStats.cacheHitChecks]
  static int cacheHitChecks = 0;

  /// The current totals since process start.
  static QueryStats get total {
    return QueryStats(
      nodesTraversed: nodesTraversed,
      candidateChecks: candidateChecks,
      relationChecks: relationChecks,
      snapshotCalls: snapshotCalls,
      cacheHits: cacheHits,
      cacheHitChecks: cacheHitChecks,
    );
  }
}
