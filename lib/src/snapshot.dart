import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/tree_snapshot.dart';

MultiWidgetSnapshot<W> snapshot<W extends Widget>(WidgetSelector<W> selector) {
  final treeSnapshot = snapshotWidgetTree();

  if (selector.parents.isEmpty) {
    final MultiWidgetSnapshot<W> snapshot =
        findWithinScope(treeSnapshot, selector);

    if (selector.expectedQuantity == ExpectedQuantity.single) {
      if (snapshot.discovered.length > 1) {
        throw TestFailure(
          'Found ${snapshot.discovered.length} elements matching $selector in widget tree, '
          'expected only one\n'
          '${_findCommonAncestor(snapshot.discovered.map((e) => e.element)).toStringDeep()}'
          'Found ${snapshot.discovered.length} elements matching $selector in widget tree, '
          'expected only one',
        );
      }
    }
    return snapshot;
  }

  final List<WidgetTreeNode> candidates =
      selector.createCandidateGenerator().generateCandidates().toList();
  final distinctCandidateElements =
      candidates.map((e) => e.element).toSet().toList();

  final filters = selector.createElementFilters();
  final discovered =
      filters.fold<Iterable<WidgetTreeNode>>(candidates, (list, filter) {
    return filter.filter(list);
  }).toList();

  if (selector.expectedQuantity == ExpectedQuantity.single) {
    if (discovered.length > 1) {
      throw TestFailure(
        'Found ${discovered.length} elements matching $selector in widget tree, '
        'expected only one\n'
        '${_findCommonAncestor(distinctCandidateElements).toStringDeep()} '
        'Found ${discovered.length} elements matching $selector in widget tree, '
        'expected only one',
      );
    }
  }

  return MultiWidgetSnapshot<W>(
    selector: selector,
    discovered: discovered,
    scope: treeSnapshot,
    debugCandidates: candidates.map((element) => element.element).toList(),
  );
}

class CandidateGeneratorFromParents<W extends Widget>
    implements CandidateGenerator<W> {
  final WidgetSelector<W> selector;

  CandidateGeneratorFromParents(this.selector);

  @override
  Iterable<WidgetTreeNode> generateCandidates() {
    final tree = snapshotWidgetTree();
    final List<MultiWidgetSnapshot<Widget>> parentSnapshots =
        selector.parents.map((selector) {
      final MultiWidgetSnapshot<Widget> widgetSnapshot = snapshot(selector);

      if (selector.expectedQuantity == ExpectedQuantity.single) {
        if (widgetSnapshot.discovered.length > 1) {
          throw TestFailure(
            'Found ${widgetSnapshot.discovered.length} elements matching $selector in widget tree, '
            'expected only one\n'
            '${_findCommonAncestor(widgetSnapshot.discovered.map((e) => e.element)).toStringDeep()}'
            'Found ${widgetSnapshot.discovered.length} elements matching $selector in widget tree, '
            'expected only one',
          );
        }
      }

      return widgetSnapshot;
    }).toList();

    final selectorWithoutParents = selector.copyWith(parents: []);

    // Take a snapshot from each parent and get the snapshots of all nodes that match
    final List<Map<WidgetTreeNode, List<MultiWidgetSnapshot<W>>>>
        discoveryByParent =
        parentSnapshots.map((MultiWidgetSnapshot<Widget> parentSnapshot) {
      final Map<WidgetTreeNode, List<MultiWidgetSnapshot<W>>> groups = {};
      if (parentSnapshot.discovered.isEmpty) {
        return groups;
      }

      for (final WidgetTreeNode node in parentSnapshot.discovered) {
        final MultiWidgetSnapshot<W> group =
            findWithinScope(tree.scope(node), selectorWithoutParents);
        final list = groups[node];
        if (list == null) {
          groups[node] = [group];
        } else {
          list.add(group);
        }
      }

      return groups;
    }).toList();

    final List<MultiWidgetSnapshot<W>> discoveredSnapshots =
        discoveryByParent.map((it) => it.values).flatten().flatten().toList();

    final List<WidgetTreeNode> allDiscoveredNodes =
        discoveredSnapshots.map((it) => it.discovered).flatten().toList();

    final List<Element> distinctElements =
        allDiscoveredNodes.map((e) => e.element).toSet().toList();

    // find nodes that exist in all parents
    final List<Element> elementsInAllParents =
        distinctElements.where((element) {
      return discoveryByParent.all((
        Map<WidgetTreeNode, List<MultiWidgetSnapshot<W>>> discovered,
      ) {
        return discovered.values.any((List<MultiWidgetSnapshot<W>> list) {
          return list.any((node) {
            return node.discovered.map((e) => e.element).contains(element);
          });
        });
      });
    }).toList();

    final List<WidgetTreeNode> allNodes = tree.allNodes;
    return elementsInAllParents
        .map((e) => allNodes.firstWhere((node) => node.element == e))
        .toList();
  }
}

/// Finds elements inside scope, completely ignores parents
MultiWidgetSnapshot<W> findWithinScope<W extends Widget>(
  ScopedWidgetTreeSnapshot scope,
  WidgetSelector<W> selector,
) {
  if (selector.parents.isNotEmpty) {
    throw "Don't use findWithinScope with a selector that has parents. "
        "Either remove the mor use snapshot() instead";
  }
  final candidates = scope.allNodes;
  final List<ElementFilter> filters = selector.createElementFilters();

  final List<WidgetTreeNode> discovered = filters
      .fold<Iterable<WidgetTreeNode>>(candidates, (list, ElementFilter filter) {
    final Iterable<WidgetTreeNode> result = filter.filter(list);
    return result;
  }).toList();

  return MultiWidgetSnapshot<W>(
    selector: selector,
    discovered: discovered,
    scope: scope,
    debugCandidates: candidates.map((it) => it.element).toList(),
  );
}

extension SingleWidgetSelectorMatcher<W extends Widget>
    on SingleWidgetSnapshot<W> {
  SingleWidgetSnapshot<W> existsOnce() {
    if (discovered == null) {
      // try finding similar selectors (less specific)
      // if one is found, fail with a more specific error message
      _tryMatchingLessSpecificCriteria(selector, min: 1);

      // else fail with default message
      final errorBuilder = StringBuffer();
      errorBuilder.writeln('Could not find $selector in widget tree');
      _dumpWidgetTree(errorBuilder);
      errorBuilder.writeln('Could not find $selector in widget tree');
      fail(errorBuilder.toString());
    }

    return this;
  }

  void doesNotExist() {
    if (discovered != null) {
      final errorBuilder = StringBuffer();
      errorBuilder.writeln('Found $selector in widget tree, expected none');
      errorBuilder.writeln(discovered!.element.toStringDeep());
      errorBuilder.writeln('Found $selector in widget tree, expected none');
      fail(errorBuilder.toString());
    }
  }
}

extension WidgetSelectorMatcher<W extends Widget> on MultiWidgetSnapshot<W> {
  void doesNotExist() => _exists(max: 0);

  SingleWidgetSnapshot<W> existsOnce() => _exists(min: 1, max: 1).single;

  MultiWidgetSnapshot<W> existsAtLeastOnce() => _exists(min: 1);

  MultiWidgetSnapshot<W> existsExactlyNTimes(int n) => _exists(min: n, max: n);

  MultiWidgetSnapshot<W> existsAtLeastNTimes(int n) => _exists(min: n);

  MultiWidgetSnapshot<W> _exists({int? min, int? max}) {
    assert(min != null || max != null);
    assert(min == null || min > 0);
    assert(max == null || max >= 0);
    assert(min == null || max == null || min <= max);

    final count = discovered.length;

    if (min != null) {
      if (count < min) {
        // try finding similar selectors (less specific)
        // if one is found, fail with a more specific error message
        _tryMatchingLessSpecificCriteria(selector, min: min);

        // else fail with default message
        final errorBuilder = StringBuffer();
        errorBuilder.writeln('Could not find $selector in widget tree');

        _dumpWidgetTree(errorBuilder);
        errorBuilder.writeln('Could not find $selector in widget tree');
        fail(errorBuilder.toString());
      }
    }

    if (max != null) {
      if (count > max) {
        final errorBuilder = StringBuffer();
        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector in widget tree, '
          'expected at most $max',
        );

        discovered.forEachIndexed((index, candidate) {
          errorBuilder.writeln("Possible match #$index:");
          errorBuilder.writeln(candidate.element.widget.toStringDeep());
        });

        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector in widget tree, '
          'expected at most $max',
        );

        fail(errorBuilder.toString());
      }
    }

    return this;
  }
}

/// Throws when an elements are found which match less specific criteria
///
/// Uses all permutations of the criteria (props/parents/children)
void _tryMatchingLessSpecificCriteria<W extends Widget>(
  WidgetSelector<W> selector, {
  int? min,
}) {
  final errorBuilder = StringBuffer();
  for (final lessSpecificSelector in selector._lessSpecificSelectors()) {
    late final MultiWidgetSnapshot<W> lessSpecificSnapshot;
    try {
      lessSpecificSnapshot = lessSpecificSelector.snapshot();
    } catch (e) {
      continue;
    }
    // error that selector could not be found, but instead spot detected lessSpecificSnapshot, which might be useful
    if (lessSpecificSnapshot.discoveredElements.isNotEmpty) {
      errorBuilder.writeln(
        'Could not find ${min != null ? 'at least $min ' : ''}matches for '
        '${selector.toStringBreadcrumb()} in widget tree, but found '
        '${lessSpecificSnapshot.discoveredElements.length} matches '
        'when searching for $lessSpecificSelector',
      );
      errorBuilder.writeln(
          'Please check the ${lessSpecificSnapshot.discoveredElements.length} '
          'matches for ${lessSpecificSelector.toStringBreadcrumb()} and adjust the constraints of the selector $selector accordingly:');
      int index = 0;
      for (final Widget match in lessSpecificSnapshot.discoveredWidgets) {
        index++;
        errorBuilder.writeln('Possible match #$index: ${match.toStringDeep()}');
      }
      fail(errorBuilder.toString());
    }
  }
}

void _dumpWidgetTree(StringBuffer buffer) {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement;
  if (rootElement != null) {
    buffer.writeln(rootElement.toStringDeep());
  } else {
    buffer.writeln('<no tree currently mounted>');
  }
}

extension ElementParent on Element {
  Element? get parent {
    Element? parent;
    visitAncestorElements((element) {
      parent = element;
      return false;
    });
    return parent;
  }

  Iterable<Element> get parents sync* {
    Element? element = this;
    while (element != null) {
      yield element;
      element = element.parent;
    }
  }

  Iterable<Element> get children sync* {
    final List<Element> found = [];
    visitChildren(found.add);
    yield* found;
  }
}

extension _LessSpecificSelectors<W extends Widget> on WidgetSelector<W> {
  /// Returns all less specific selectors, removing one criteria at a time until
  /// the selector is empty.
  ///
  /// The selectors are sorted by specificity, so the first selector filters the most
  ///
  /// For example, if the selector matches for type Center and parent SizedBox it will return
  /// - selector which only matches for type Center
  /// - selector which only matches for parent SizedBox
  Iterable<WidgetSelector<W>> _lessSpecificSelectors() sync* {
    final List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria = [
      for (final prop in props) (s) => s.copyWith(props: [prop]),
      for (final parent in parents)
        (s) => s.copyWith(parents: [...s.parents, parent]),
      for (final child in children)
        (s) => s.copyWith(children: [...s.children, child]),
    ];

    for (final subset in getAllSubsets(criteria)) {
      final selector = _buildSelector(subset);
      // do not yield selectors which match any widgets
      if (selector.children.isNotEmpty ||
          selector.parents.isNotEmpty ||
          selector.props.isNotEmpty ||
          selector.type != Widget) {
        yield selector;
      }
    }
  }

  WidgetSelector<W> _buildSelector(
    List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria,
  ) {
    WidgetSelector<W> s = copyWith(
      props: props,
      parents: [],
      children: [],
    );
    for (final criteria in criteria) {
      s = criteria(s);
    }
    return s;
  }
}

@visibleForTesting
List<List<T>> getAllSubsets<T>(List<T> list) {
  final List<List<T>> result = [[]];
  for (final element in list) {
    final List<List<T>> newSubsets = [];
    for (final subset in result) {
      newSubsets.add([...subset, element]);
    }
    result.addAll(newSubsets);
  }
  result.remove(result.firstWhere((it) => it.length == list.length));
  return result.sortedByDescending((element) => element.length).toList();
}

Element _findCommonAncestor(Iterable<Element> elements) =>
    IterableSortedBy(elements)
        .sortedBy((element) => element.depth)
        .first
        .parent ??
// ignore: deprecated_member_use
    WidgetsBinding.instance.renderViewElement!;
