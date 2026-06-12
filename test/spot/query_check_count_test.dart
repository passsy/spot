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
  void measureSpot(
    String label,
    int maxChecks,
    WidgetSnapshot<Widget> Function() query,
  ) {
    final snapshot = query();
    print('$label\n  ${snapshot.queryStats}');
    // Guards against performance regressions of the query engine. The
    // bounds have ~3x headroom over the currently measured numbers.
    expect(
      snapshot.queryStats.totalChecks,
      lessThan(maxChecks),
      reason: 'Query engine did more checks than expected for: $label',
    );
  }

  void measureFinder(
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
    print('$label\n  finderChecks: $total '
        '(nodesVisited: $_simNodesVisited, '
        'predicateChecks: $_simPredicateChecks, '
        'comparisons: $_simComparisons, '
        'matched: ${matches.length})');
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

    measureSpot('Q1 spot: spotText("Item 99") [no relationship]', 12000, () {
      return spotText('Item 99').snapshot()..existsOnce();
    });
    measureFinder(
      'Q1 finder: find.text("Item 99")',
      () => _simLeaf(_textPredicate('Item 99')),
      find.byElementPredicate(_textPredicate('Item 99')),
    );

    measureSpot(
        'Q2 spot: spot<MaterialApp>().spot<Scaffold>().spot<AppBar>().spotText("Home")',
        50000, () {
      return spot<MaterialApp>()
          .spot<Scaffold>()
          .spot<AppBar>()
          .spotText('Home')
          .snapshot()
        ..existsOnce();
    });
    measureFinder(
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

    measureSpot(
        'Q3 spot: spotText("Item 99").withParent(spot<Row>().withParent(spot<Container>()))',
        40000, () {
      return spotText('Item 99')
          .withParent(spot<Row>().withParent(spot<Container>()))
          .snapshot()
        ..existsOnce();
    });
    measureFinder(
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
    measureFinder(
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

    measureSpot(
        'Q4 spot: spot<Container>().withChild(spotIcon(Icons.star))', 80000,
        () {
      return spot<Container>().withChild(spotIcon(Icons.star)).snapshot()
        ..existsExactlyNTimes(100);
    });
    measureFinder(
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

    measureSpot(
        'Q5 spot: spot<Row>().withParent(spot<MaterialApp>()) [wide parent]',
        75000, () {
      return spot<Row>().withParent(spot<MaterialApp>()).snapshot()
        ..existsAtLeastNTimes(100);
    });
    measureFinder(
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

    measureSpot(
        'M1 spot: spot<_GridTile>().withChild(spotIcon(Icons.star)) -> 4 of 100',
        60000, () {
      return spot<_GridTile>().withChild(spotIcon(Icons.star)).snapshot()
        ..existsExactlyNTimes(4);
    });
    measureFinder(
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

    measureSpot(
        'M2 spot: spotIcon(Icons.star).withParent(spot<_GridTile>()) -> 4 of 100',
        60000, () {
      return spotIcon(Icons.star).withParent(spot<_GridTile>()).snapshot()
        ..existsExactlyNTimes(4);
    });
    measureFinder(
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

    measureSpot('N1 spot: spotText("leaf").withParent(spot<SizedBox>())', 10000,
        () {
      return spotText('leaf').withParent(spot<SizedBox>()).snapshot()
        ..existsOnce();
    });
    measureFinder(
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

    measureSpot(
        'N2 spot: spotText("leaf").withParent(spot<SizedBox>().withParent(spot<SizedBox>()))',
        10000, () {
      return spotText('leaf')
          .withParent(spot<SizedBox>().withParent(spot<SizedBox>()))
          .snapshot()
        ..existsOnce();
    });
    measureFinder(
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
    measureFinder(
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
  });
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
