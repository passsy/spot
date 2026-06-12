// ignore_for_file: avoid_unnecessary_containers, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

/// Measures the number of checks the spot query engine performs for typical
/// and pathological queries, and compares them with the number of checks the
/// flutter_test finder API needs for equivalent queries.
///
/// Spot checks = nodesTraversed + candidateChecks + relationChecks
/// (see QueryStats).
///
/// Finder checks are measured with a 1:1 simulation of the finder evaluation
/// in flutter_test (finders.dart, _DescendantFinderMixin/_AncestorFinderMixin)
/// that counts element tree walks, predicate evaluations and the element
/// comparisons of the linear `Iterable.contains` calls. Each simulation
/// asserts that it discovers exactly the same elements as the real finder.
void main() {
  testWidgets('measure wall clock time for simple type queries with timeline',
      (tester) async {
    const warmups = 3;
    const runs = 20;
    timeline.mode = TimelineMode.reportOnError;
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            _BenchWidgetA(),
            _BenchWidgetB(),
            _BenchWidgetC(),
            _BenchWidgetD(),
            _BenchWidgetE(),
          ],
        ),
      ),
    );

    print('timeline mode: ${timeline.mode}');

    final spotWithScreenshotsElapsed = await _measureWallClockAverage(
      tester: tester,
      warmups: warmups,
      runs: runs,
      measure: _runFiveSpotTypeQueries,
    );

    final finderElapsed = await _measureWallClockAverage(
      tester: tester,
      warmups: warmups,
      runs: runs,
      measure: _runFiveFinderTypeQueries,
    );

    _printWallClockSummary(
      label: '5 simple type queries with timeline screenshots',
      warmups: warmups,
      runs: runs,
      spot: spotWithScreenshotsElapsed,
      finder: finderElapsed,
    );

    timeline.mode = TimelineMode.off;
    print('timeline mode: ${timeline.mode}');

    final spotWithoutScreenshotsElapsed = await _measureWallClockAverage(
      tester: tester,
      warmups: warmups,
      runs: runs,
      measure: _runFiveSpotTypeQueries,
    );

    final finderWithoutScreenshotsElapsed = await _measureWallClockAverage(
      tester: tester,
      warmups: warmups,
      runs: runs,
      measure: _runFiveFinderTypeQueries,
    );

    _printWallClockSummary(
      label: '5 simple type queries without timeline screenshots',
      warmups: warmups,
      runs: runs,
      spot: spotWithoutScreenshotsElapsed,
      finder: finderWithoutScreenshotsElapsed,
    );

    _printWallClockScreenshotOverhead(
      withScreenshots: spotWithScreenshotsElapsed,
      withoutScreenshots: spotWithoutScreenshotsElapsed,
    );
  });

  _Measurement measureSpot(
    String label,
    int maxChecks,
    WidgetSnapshot<Widget> Function() query,
  ) {
    final snapshot = query();
    final measurement = _Measurement(
      engine: 'spot',
      total: snapshot.queryStats.totalChecks,
      treeWalks: snapshot.queryStats.nodesTraversed,
      filters: snapshot.queryStats.candidateChecks,
      relations: snapshot.queryStats.relationChecks,
      snapshots: snapshot.queryStats.snapshotCalls.toString(),
      cacheHits: snapshot.queryStats.cacheHits.toString(),
      cacheHitChecks: snapshot.queryStats.cacheHitChecks.toString(),
      cacheRatio: _formatPercent(snapshot.queryStats.cacheRatio),
      matched: snapshot.discovered.length,
    );
    _printMeasurement(label, measurement);
    // Guards against performance regressions of the query engine. The
    // bounds have ~3x headroom over the currently measured numbers.
    expect(
      snapshot.queryStats.totalChecks,
      lessThan(maxChecks),
      reason: 'Query engine did more checks than expected for: $label',
    );
    return measurement;
  }

  _Measurement measureFinder(
    String label,
    _SimResult Function() build,
    Finder realEquivalent,
  ) {
    _resetSimStats();
    final simulation = build();
    final matches = simulation.matches;
    expect(
      matches,
      realEquivalent.evaluate().toList(),
      reason: 'Finder simulation must discover the same elements '
          'as the real finder for: $label',
    );
    final total = _simNodesVisited + _simPredicateChecks + _simComparisons;
    final measurement = _Measurement(
      engine: 'finder',
      total: total,
      treeWalks: _simNodesVisited,
      filters: _simPredicateChecks,
      relations: _simComparisons,
      snapshots: '-',
      cacheHits: '-',
      cacheHitChecks: '-',
      cacheRatio: '-',
      matched: matches.length,
    );
    _printMeasurement(label, measurement);
    return measurement;
  }

  testWidgets('count checks for common query shapes', (tester) async {
    // No timeline events/screenshots, only measure the pure query work
    timeline.mode = TimelineMode.off;
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: ListView(
            itemExtent: 6,
            children: [
              for (int i = 0; i < 100; i++)
                Container(
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 4),
                      Text('Item $i', style: const TextStyle(fontSize: 4)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Walks the tree once, so that all queries below operate on the
    // cached per-frame tree snapshot (like consecutive assertions in a test)
    final treeSize = currentWidgetTreeSnapshot().allNodes.length;
    print('tree size: $treeSize nodes');

    final q1Spot = measureSpot(
      'Q1 spot: spotText("Item 99") [no relationship]',
      treeSize * 6,
      () {
        return spotText('Item 99').snapshot()..existsOnce();
      },
    );
    final q1Finder = measureFinder(
      'Q1 finder: find.text("Item 99")',
      () => _simLeaf(_textPredicate('Item 99')),
      find.byElementPredicate(_textPredicate('Item 99')),
    );

    final q2Spot = measureSpot(
        'Q2 spot: spot<MaterialApp>().spot<Scaffold>().spot<AppBar>().spotText("Home")',
        treeSize * 10, () {
      return spot<MaterialApp>()
          .spot<Scaffold>()
          .spot<AppBar>()
          .spotText('Home')
          .snapshot()
        ..existsOnce();
    });
    final q2Finder = measureFinder(
      'Q2 finder: find.descendant(MaterialApp > Scaffold > AppBar > "Home")',
      () {
        return _simDescendant(
          of: _simDescendant(
            of: _simDescendant(
              of: _simLeaf(_typePredicate(MaterialApp)),
              matching: _simLeaf(_typePredicate(Scaffold)),
            ),
            matching: _simLeaf(_typePredicate(AppBar)),
          ),
          matching: _simLeaf(_textPredicate('Home')),
        );
      },
      find.descendant(
        of: find.descendant(
          of: find.descendant(
            of: find.byElementPredicate(_typePredicate(MaterialApp)),
            matching: find.byElementPredicate(_typePredicate(Scaffold)),
          ),
          matching: find.byElementPredicate(_typePredicate(AppBar)),
        ),
        matching: find.byElementPredicate(_textPredicate('Home')),
      ),
    );

    final q3Spot = measureSpot(
        'Q3 spot: spotText("Item 99").withParent(spot<Row>().withParent(spot<Container>()))',
        treeSize * 10, () {
      return spotText('Item 99')
          .withParent(spot<Row>().withParent(spot<Container>()))
          .snapshot()
        ..existsOnce();
    });
    final q3aFinder = measureFinder(
      'Q3a finder: find.descendant(of: find.descendant(of: Container, matching: Row), matching: "Item 99")',
      () {
        return _simDescendant(
          of: _simDescendant(
            of: _simLeaf(_typePredicate(Container)),
            matching: _simLeaf(_typePredicate(Row)),
          ),
          matching: _simLeaf(_textPredicate('Item 99')),
        );
      },
      find.descendant(
        of: find.descendant(
          of: find.byElementPredicate(_typePredicate(Container)),
          matching: find.byElementPredicate(_typePredicate(Row)),
        ),
        matching: find.byElementPredicate(_textPredicate('Item 99')),
      ),
    );
    final q3bFinder = measureFinder(
      'Q3b finder: find.descendant(of: Container, matching: find.descendant(of: Row, matching: "Item 99"))',
      () {
        return _simDescendant(
          of: _simLeaf(_typePredicate(Container)),
          matching: _simDescendant(
            of: _simLeaf(_typePredicate(Row)),
            matching: _simLeaf(_textPredicate('Item 99')),
          ),
        );
      },
      find.descendant(
        of: find.byElementPredicate(_typePredicate(Container)),
        matching: find.descendant(
          of: find.byElementPredicate(_typePredicate(Row)),
          matching: find.byElementPredicate(_textPredicate('Item 99')),
        ),
      ),
    );

    final q4Spot = measureSpot(
        'Q4 spot: spot<Container>().withChild(spotIcon(Icons.star))',
        treeSize * 20, () {
      return spot<Container>().withChild(spotIcon(Icons.star)).snapshot()
        ..existsExactlyNTimes(100);
    });
    final q4Finder = measureFinder(
      'Q4 finder: find.ancestor(of: icon, matching: Container)',
      () {
        return _simAncestor(
          of: _simLeaf(_iconPredicate(Icons.star)),
          matching: _simLeaf(_typePredicate(Container)),
        );
      },
      find.ancestor(
        of: find.byElementPredicate(_iconPredicate(Icons.star)),
        matching: find.byElementPredicate(_typePredicate(Container)),
      ),
    );

    final q5Spot = measureSpot(
        'Q5 spot: spot<Row>().withParent(spot<MaterialApp>()) [wide parent]',
        treeSize * 20, () {
      return spot<Row>().withParent(spot<MaterialApp>()).snapshot()
        ..existsAtLeastNTimes(100);
    });
    final q5Finder = measureFinder(
      'Q5 finder: find.descendant(of: MaterialApp, matching: Row)',
      () {
        return _simDescendant(
          of: _simLeaf(_typePredicate(MaterialApp)),
          matching: _simLeaf(_typePredicate(Row)),
        );
      },
      find.descendant(
        of: find.byElementPredicate(_typePredicate(MaterialApp)),
        matching: find.byElementPredicate(_typePredicate(Row)),
      ),
    );

    _printSummary('common query shapes', [
      _Comparison(query: 'Q1', spot: q1Spot, finder: q1Finder),
      _Comparison(query: 'Q2', spot: q2Spot, finder: q2Finder),
      _Comparison(query: 'Q3a', spot: q3Spot, finder: q3aFinder),
      _Comparison(query: 'Q3b', spot: q3Spot, finder: q3bFinder),
      _Comparison(query: 'Q4', spot: q4Spot, finder: q4Finder),
      _Comparison(query: 'Q5', spot: q5Spot, finder: q5Finder),
    ]);
  });

  testWidgets('count checks for multi-result queries (4 of 100 grid tiles)',
      (tester) async {
    // No timeline events/screenshots, only measure the pure query work
    timeline.mode = TimelineMode.off;
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: GridView.count(
          crossAxisCount: 10,
          children: [
            for (int i = 0; i < 100; i++)
              _GridTile(
                child: Column(
                  children: [
                    // 4 tiles are highlighted with a star
                    Icon(i % 25 == 0 ? Icons.star : Icons.circle, size: 8),
                    Text('Tile $i', style: const TextStyle(fontSize: 8)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    final treeSize = currentWidgetTreeSnapshot().allNodes.length;
    print('tree size: $treeSize nodes');

    final m1Spot = measureSpot(
        'M1 spot: spot<_GridTile>().withChild(spotIcon(Icons.star)) -> 4 of 100',
        treeSize * 8, () {
      return spot<_GridTile>().withChild(spotIcon(Icons.star)).snapshot()
        ..existsExactlyNTimes(4);
    });
    final m1Finder = measureFinder(
      'M1 finder: find.ancestor(of: star icon, matching: _GridTile)',
      () {
        return _simAncestor(
          of: _simLeaf(_iconPredicate(Icons.star)),
          matching: _simLeaf(_typePredicate(_GridTile)),
        );
      },
      find.ancestor(
        of: find.byElementPredicate(_iconPredicate(Icons.star)),
        matching: find.byElementPredicate(_typePredicate(_GridTile)),
      ),
    );

    final m2Spot = measureSpot(
        'M2 spot: spotIcon(Icons.star).withParent(spot<_GridTile>()) -> 4 of 100',
        treeSize * 8, () {
      return spotIcon(Icons.star).withParent(spot<_GridTile>()).snapshot()
        ..existsExactlyNTimes(4);
    });
    final m2Finder = measureFinder(
      'M2 finder: find.descendant(of: _GridTile, matching: star icon)',
      () {
        return _simDescendant(
          of: _simLeaf(_typePredicate(_GridTile)),
          matching: _simLeaf(_iconPredicate(Icons.star)),
        );
      },
      find.descendant(
        of: find.byElementPredicate(_typePredicate(_GridTile)),
        matching: find.byElementPredicate(_iconPredicate(Icons.star)),
      ),
    );

    _printSummary('multi-result queries', [
      _Comparison(query: 'M1', spot: m1Spot, finder: m1Finder),
      _Comparison(query: 'M2', spot: m2Spot, finder: m2Finder),
    ]);
  });

  testWidgets('count checks in deeply nested same-type tree', (tester) async {
    // No timeline events/screenshots, only measure the pure query work
    timeline.mode = TimelineMode.off;
    // 50 nested SizedBox widgets, the worst case for find.descendant:
    // every nesting level matches and its whole subtree is enumerated again
    Widget tree = const Text('leaf');
    for (int i = 0; i < 50; i++) {
      tree = SizedBox(child: tree);
    }
    await tester.pumpWidget(MaterialApp(home: tree));

    final treeSize = currentWidgetTreeSnapshot().allNodes.length;
    print('tree size: $treeSize nodes');

    final n1Spot = measureSpot(
      'N1 spot: spotText("leaf").withParent(spot<SizedBox>())',
      treeSize * 10,
      () {
        return spotText('leaf').withParent(spot<SizedBox>()).snapshot()
          ..existsOnce();
      },
    );
    final n1Finder = measureFinder(
      'N1 finder: find.descendant(of: SizedBox, matching: "leaf")',
      () {
        return _simDescendant(
          of: _simLeaf(_typePredicate(SizedBox)),
          matching: _simLeaf(_textPredicate('leaf')),
        );
      },
      find.descendant(
        of: find.byElementPredicate(_typePredicate(SizedBox)),
        matching: find.byElementPredicate(_textPredicate('leaf')),
      ),
    );

    final n2Spot = measureSpot(
        'N2 spot: spotText("leaf").withParent(spot<SizedBox>().withParent(spot<SizedBox>()))',
        treeSize * 10, () {
      return spotText('leaf')
          .withParent(spot<SizedBox>().withParent(spot<SizedBox>()))
          .snapshot()
        ..existsOnce();
    });
    final n2aFinder = measureFinder(
      'N2a finder: find.descendant(of: find.descendant(of: SizedBox, matching: SizedBox), matching: "leaf")',
      () {
        return _simDescendant(
          of: _simDescendant(
            of: _simLeaf(_typePredicate(SizedBox)),
            matching: _simLeaf(_typePredicate(SizedBox)),
          ),
          matching: _simLeaf(_textPredicate('leaf')),
        );
      },
      find.descendant(
        of: find.descendant(
          of: find.byElementPredicate(_typePredicate(SizedBox)),
          matching: find.byElementPredicate(_typePredicate(SizedBox)),
        ),
        matching: find.byElementPredicate(_textPredicate('leaf')),
      ),
    );
    final n2bFinder = measureFinder(
      'N2b finder: find.descendant(of: SizedBox, matching: find.descendant(of: SizedBox, matching: "leaf"))',
      () {
        return _simDescendant(
          of: _simLeaf(_typePredicate(SizedBox)),
          matching: _simDescendant(
            of: _simLeaf(_typePredicate(SizedBox)),
            matching: _simLeaf(_textPredicate('leaf')),
          ),
        );
      },
      find.descendant(
        of: find.byElementPredicate(_typePredicate(SizedBox)),
        matching: find.descendant(
          of: find.byElementPredicate(_typePredicate(SizedBox)),
          matching: find.byElementPredicate(_textPredicate('leaf')),
        ),
      ),
    );

    _printSummary('deeply nested same-type tree', [
      _Comparison(query: 'N1', spot: n1Spot, finder: n1Finder),
      _Comparison(query: 'N2a', spot: n2Spot, finder: n2aFinder),
      _Comparison(query: 'N2b', spot: n2Spot, finder: n2bFinder),
    ]);
  });
}

Future<Duration> _measureWallClockAverage({
  required WidgetTester tester,
  required int warmups,
  required int runs,
  required void Function() measure,
}) async {
  for (int i = 0; i < warmups; i++) {
    await tester.pump();
    measure();
  }

  int totalMicros = 0;
  for (int i = 0; i < runs; i++) {
    await tester.pump();
    final stopwatch = Stopwatch()..start();
    measure();
    stopwatch.stop();
    totalMicros += stopwatch.elapsedMicroseconds;
  }

  return Duration(microseconds: totalMicros ~/ runs);
}

void _runFiveSpotTypeQueries() {
  spot<_BenchWidgetA>().existsOnce();
  spot<_BenchWidgetB>().existsOnce();
  spot<_BenchWidgetC>().existsOnce();
  spot<_BenchWidgetD>().existsOnce();
  spot<_BenchWidgetE>().existsOnce();
}

void _runFiveFinderTypeQueries() {
  expect(find.byType(_BenchWidgetA), findsOneWidget);
  expect(find.byType(_BenchWidgetB), findsOneWidget);
  expect(find.byType(_BenchWidgetC), findsOneWidget);
  expect(find.byType(_BenchWidgetD), findsOneWidget);
  expect(find.byType(_BenchWidgetE), findsOneWidget);
}

class _Measurement {
  const _Measurement({
    required this.engine,
    required this.total,
    required this.treeWalks,
    required this.filters,
    required this.relations,
    required this.snapshots,
    required this.cacheHits,
    required this.cacheHitChecks,
    required this.cacheRatio,
    required this.matched,
  });

  final String engine;
  final int total;
  final int treeWalks;
  final int filters;
  final int relations;
  final String snapshots;
  final String cacheHits;
  final String cacheHitChecks;
  final String cacheRatio;
  final int matched;
}

class _Comparison {
  const _Comparison({
    required this.query,
    required this.spot,
    required this.finder,
  });

  final String query;
  final _Measurement spot;
  final _Measurement finder;
}

void _printMeasurement(String label, _Measurement measurement) {
  final header = _formatMeasurementRow(
    engine: 'engine',
    total: 'total',
    treeWalks: 'tree',
    filters: 'filter',
    relations: 'relation',
    snapshots: 'snapshots',
    cacheHits: 'cache',
    cacheHitChecks: 'saved',
    cacheRatio: 'cached',
    matched: 'matched',
  );
  final values = _formatMeasurementRow(
    engine: measurement.engine,
    total: measurement.total.toString(),
    treeWalks: measurement.treeWalks.toString(),
    filters: measurement.filters.toString(),
    relations: measurement.relations.toString(),
    snapshots: measurement.snapshots,
    cacheHits: measurement.cacheHits,
    cacheHitChecks: measurement.cacheHitChecks,
    cacheRatio: measurement.cacheRatio,
    matched: measurement.matched.toString(),
  );
  print('$label\n  $header\n  $values');
}

void _printSummary(String label, List<_Comparison> comparisons) {
  final header = _formatSummaryRow(
    query: 'query',
    winner: 'winner',
    factor: 'better by',
    fewer: 'fewer checks',
    spot: 'spot',
    finder: 'finder',
    cacheHitChecks: 'saved',
    cacheRatio: 'cached',
  );
  final rows = comparisons.map(_formatSummaryComparison).join('\n  ');
  print('Summary: $label\n  $header\n  $rows');
}

String _formatSummaryComparison(_Comparison comparison) {
  final winner = _winner(comparison);
  final fewerChecks = _fewerChecks(comparison);
  final factor = _factor(comparison);
  return _formatSummaryRow(
    query: comparison.query,
    winner: winner,
    factor: factor,
    fewer: _formatInt(fewerChecks),
    spot: _formatInt(comparison.spot.total),
    finder: _formatInt(comparison.finder.total),
    cacheHitChecks: comparison.spot.cacheHitChecks,
    cacheRatio: comparison.spot.cacheRatio,
  );
}

String _winner(_Comparison comparison) {
  if (comparison.spot.total < comparison.finder.total) {
    return 'spot';
  }
  if (comparison.finder.total < comparison.spot.total) {
    return 'finder';
  }
  return 'tie';
}

int _fewerChecks(_Comparison comparison) {
  return (comparison.spot.total - comparison.finder.total).abs();
}

String _factor(_Comparison comparison) {
  final lower = _lowerTotal(comparison);
  final higher = _higherTotal(comparison);
  if (lower == higher) {
    return '1.0x';
  }
  return '${(higher / lower).toStringAsFixed(1)}x';
}

int _lowerTotal(_Comparison comparison) {
  if (comparison.spot.total < comparison.finder.total) {
    return comparison.spot.total;
  }
  return comparison.finder.total;
}

int _higherTotal(_Comparison comparison) {
  if (comparison.spot.total > comparison.finder.total) {
    return comparison.spot.total;
  }
  return comparison.finder.total;
}

String _formatSummaryRow({
  required String query,
  required String winner,
  required String factor,
  required String fewer,
  required String spot,
  required String finder,
  required String cacheHitChecks,
  required String cacheRatio,
}) {
  return [
    query.padRight(5),
    winner.padRight(6),
    factor.padLeft(9),
    fewer.padLeft(13),
    spot.padLeft(10),
    finder.padLeft(10),
    cacheHitChecks.padLeft(8),
    cacheRatio.padLeft(6),
  ].join('  ');
}

String _formatInt(int value) {
  final text = value.toString();
  final chars = text.split('').reversed.toList();
  final buffer = StringBuffer();
  for (int i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}

void _printWallClockSummary({
  required String label,
  required int warmups,
  required int runs,
  required Duration spot,
  required Duration finder,
}) {
  final spotMicros = spot.inMicroseconds;
  final finderMicros = finder.inMicroseconds;
  final winner = _wallClockWinner(spotMicros, finderMicros);
  final factor = _wallClockFactor(spotMicros, finderMicros);
  final difference = (spotMicros - finderMicros).abs();
  print('Wall clock summary: $label ($warmups warmups, $runs runs, avg/run)\n'
      '  winner  better by  difference       spot     finder\n'
      '  ${winner.padRight(6)}  ${factor.padLeft(9)}  '
      '${_formatDurationMicros(difference).padLeft(10)}  '
      '${_formatDurationMicros(spotMicros).padLeft(9)}  '
      '${_formatDurationMicros(finderMicros).padLeft(9)}');
}

void _printWallClockScreenshotOverhead({
  required Duration withScreenshots,
  required Duration withoutScreenshots,
}) {
  final withScreenshotMicros = withScreenshots.inMicroseconds;
  final withoutScreenshotMicros = withoutScreenshots.inMicroseconds;
  final overhead = withScreenshotMicros - withoutScreenshotMicros;
  final factor =
      _wallClockFactor(withScreenshotMicros, withoutScreenshotMicros);
  print('Spot screenshot overhead\n'
      '  extra time  slower by  with screenshots  without screenshots\n'
      '  ${_formatDurationMicros(overhead).padLeft(10)}  '
      '${factor.padLeft(9)}  '
      '${_formatDurationMicros(withScreenshotMicros).padLeft(16)}  '
      '${_formatDurationMicros(withoutScreenshotMicros).padLeft(19)}');
}

String _wallClockWinner(int spotMicros, int finderMicros) {
  if (spotMicros < finderMicros) {
    return 'spot';
  }
  if (finderMicros < spotMicros) {
    return 'finder';
  }
  return 'tie';
}

String _wallClockFactor(int spotMicros, int finderMicros) {
  final lower = spotMicros < finderMicros ? spotMicros : finderMicros;
  final higher = spotMicros > finderMicros ? spotMicros : finderMicros;
  if (lower == higher) {
    return '1.0x';
  }
  return '${(higher / lower).toStringAsFixed(1)}x';
}

String _formatDurationMicros(int micros) {
  if (micros < 1000) {
    return '${micros}us';
  }
  final millis = micros / 1000;
  return '${millis.toStringAsFixed(1)}ms';
}

String _formatMeasurementRow({
  required String engine,
  required String total,
  required String treeWalks,
  required String filters,
  required String relations,
  required String snapshots,
  required String cacheHits,
  required String cacheHitChecks,
  required String cacheRatio,
  required String matched,
}) {
  return [
    engine.padRight(6),
    total.padLeft(8),
    treeWalks.padLeft(8),
    filters.padLeft(8),
    relations.padLeft(9),
    snapshots.padLeft(9),
    cacheHits.padLeft(5),
    cacheHitChecks.padLeft(8),
    cacheRatio.padLeft(6),
    matched.padLeft(7),
  ].join('  ');
}

String _formatPercent(double value) {
  return '${(value * 100).toStringAsFixed(0)}%';
}

/// A grid tile of the multi-result query test
class _GridTile extends StatelessWidget {
  const _GridTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _BenchWidgetA extends StatelessWidget {
  const _BenchWidgetA();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BenchWidgetB extends StatelessWidget {
  const _BenchWidgetB();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BenchWidgetC extends StatelessWidget {
  const _BenchWidgetC();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BenchWidgetD extends StatelessWidget {
  const _BenchWidgetD();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _BenchWidgetE extends StatelessWidget {
  const _BenchWidgetE();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

bool Function(Element) _typePredicate(Type type) {
  return (el) => el.widget.runtimeType == type;
}

bool Function(Element) _textPredicate(String text) {
  return (el) {
    final widget = el.widget;
    if (widget is Text) {
      return widget.data?.contains(text) ?? false;
    }
    return false;
  };
}

bool Function(Element) _iconPredicate(IconData icon) {
  return (el) {
    final widget = el.widget;
    return widget is Icon && widget.icon == icon;
  };
}

int _simNodesVisited = 0;
int _simPredicateChecks = 0;
int _simComparisons = 0;

void _resetSimStats() {
  _simNodesVisited = 0;
  _simPredicateChecks = 0;
  _simComparisons = 0;
}

List<Element> _collectCounted(Element root) {
  final elements = collectAllElementsFrom(root, skipOffstage: true).toList();
  _simNodesVisited += elements.length;
  return elements;
}

/// The (lazy) result of a simulated finder, mirroring `FinderResult` of
/// flutter_test.
abstract class _SimResult {
  List<Element>? _matchesCache;

  /// The matched elements, computed once on first access like the
  /// `CachingIterable` based evaluation of flutter_test finders.
  List<Element> get matches => _matchesCache ??= computeMatches();

  List<Element> computeMatches();

  /// Simulates `Iterable.contains(target)` on this finder result, the way
  /// `_DescendantFinderMixin.findInCandidates` and
  /// `_AncestorFinderMixin.findInCandidates` use it.
  bool scanContains(Element target);
}

/// Result of a leaf finder like `find.byType` or `find.text`.
///
/// The element tree walk and the predicate evaluations are cached by
/// `CachingIterable`, repeated `contains` calls only scan the already
/// computed matches.
class _SimLeafResult extends _SimResult {
  _SimLeafResult(this.predicate);

  final bool Function(Element) predicate;

  @override
  List<Element> computeMatches() {
    final all = _collectCounted(WidgetsBinding.instance.rootElement!);
    final found = <Element>[];
    for (final element in all) {
      _simPredicateChecks++;
      if (predicate(element)) {
        found.add(element);
      }
    }
    return found;
  }

  @override
  bool scanContains(Element target) {
    // `this.` because flutter_test exports a top-level `matches()` Matcher
    // that shadows the inherited getter
    for (final match in this.matches) {
      _simComparisons++;
      if (identical(match, target)) {
        return true;
      }
    }
    return false;
  }
}

/// Result of `find.descendant`/`find.ancestor`.
///
/// flutter_test wraps `candidates.where((c) => matching.contains(c))` in a
/// plain lazy `WhereIterable`. It is NOT cached, every `contains` call
/// re-runs the filter chain over all candidates.
class _SimRelationResult extends _SimResult {
  _SimRelationResult({required this.candidates, required this.matching});

  final List<Element> candidates;
  final _SimResult matching;

  @override
  List<Element> computeMatches() {
    final found = <Element>[];
    for (final candidate in candidates) {
      if (matching.scanContains(candidate)) {
        found.add(candidate);
      }
    }
    return found;
  }

  @override
  bool scanContains(Element target) {
    for (final candidate in candidates) {
      if (matching.scanContains(candidate)) {
        _simComparisons++;
        if (identical(candidate, target)) {
          return true;
        }
      }
    }
    return false;
  }
}

/// Simulates evaluating `find.byElementPredicate(predicate)`.
_SimResult _simLeaf(bool Function(Element) predicate) {
  return _SimLeafResult(predicate);
}

/// Simulates evaluating `find.descendant(of: of, matching: matching)`,
/// mirroring `_DescendantFinderMixin` (flutter_test finders.dart).
///
/// The `of` finder is evaluated eagerly and the subtree of every match is
/// enumerated (`allCandidates`).
_SimResult _simDescendant({
  required _SimResult of,
  required _SimResult matching,
}) {
  final seen = <Element>{};
  final candidates = <Element>[];
  for (final ancestor in of.matches) {
    for (final element in _collectCounted(ancestor)) {
      if (seen.add(element)) {
        candidates.add(element);
      }
    }
  }
  return _SimRelationResult(candidates: candidates, matching: matching);
}

/// Simulates evaluating `find.ancestor(of: of, matching: matching)`,
/// mirroring `_AncestorFinderMixin` (flutter_test finders.dart).
///
/// The candidates are the ancestor chains of all `of` matches (not deduped).
_SimResult _simAncestor({
  required _SimResult of,
  required _SimResult matching,
}) {
  final candidates = <Element>[];
  for (final leaf in of.matches) {
    leaf.visitAncestorElements((element) {
      _simNodesVisited++;
      candidates.add(element);
      return true;
    });
  }
  return _SimRelationResult(candidates: candidates, matching: matching);
}
