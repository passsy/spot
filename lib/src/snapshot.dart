import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

SpotSnapshot<W> snapshot<W extends Widget>(WidgetSelector<W> selector) {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement!;
  final origin = SpotNode(
    selector: WidgetSelector.all,
    parents: [],
    element: rootElement,
    debugCandidates: [rootElement],
  );

  if (selector.parents.isEmpty) {
    final snapshot = takeScopedSnapshot(selector, origin);

    if (selector.expectSingle == true) {
      if (snapshot.discovered.length > 1) {
        throw TestFailure(
          'Found ${snapshot.discovered.length} elements matching $selector in widget tree, '
          'expected only one\n'
          '${_findCommonAncestor(snapshot.discoveredElements).toStringDeep()}'
          'Found ${snapshot.discovered.length} elements matching $selector in widget tree, '
          'expected only one',
        );
      }
    }
    return snapshot;
  }

  final List<SpotNode<W>> candidates =
      selector.createCandidateGenerator().generateCandidates().toList();
  final distinctCandidateElements =
      candidates.map((e) => e.element).toSet().toList();

  final discovered =
      selector.filters.fold<Iterable<SpotNode<W>>>(candidates, (list, filter) {
    return filter.filter(selector, list);
  }).toList();

  if (selector.expectSingle == true) {
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

  return SpotSnapshot<W>(
    selector: selector,
    discovered: discovered,
    debugCandidates:
        candidates.expand((element) => element.debugCandidates).toList(),
  );
}

SpotSnapshot<W> takeScopedSnapshot<W extends Widget>(
  WidgetSelector<W> selector,
  SpotNode origin,
) {
  final List<Element> allElementCandidates = [origin.element] +
      collectAllElementsFrom(origin.element, skipOffstage: true).toList();
  final List<SpotNode> candidates = allElementCandidates.map((e) {
    return SpotNode(
      selector: selector,
      parents: [origin],
      element: e,
      debugCandidates: allElementCandidates,
    );
  }).toList();

  final discovered = selector.filters
      .fold<Iterable<SpotNode>>(candidates, (list, filter) {
        return filter.filter(selector, list);
      })
      .map((node) => node.cast<W>())
      .toList();

  return SpotSnapshot<W>(
    selector: selector,
    discovered: discovered,
    debugCandidates: candidates.map((e) => e.element).toList(),
  );
}

extension SingleWidgetSelectorMatcher<W extends Widget>
    on SingleSpotSnapshot<W> {
  SingleSpotSnapshot<W> existsOnce() {
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

extension WidgetSelectorMatcher<W extends Widget> on SpotSnapshot<W> {
  void doesNotExist() => _exists(max: 0);

  SingleSpotSnapshot<W> existsOnce() => _exists(min: 1, max: 1).single;

  SpotSnapshot<W> existsAtLeastOnce() => _exists(min: 1);

  SpotSnapshot<W> existsExactlyNTimes(int n) => _exists(min: n, max: n);

  SpotSnapshot<W> existsAtLeastNTimes(int n) => _exists(min: n);

  SpotSnapshot<W> _exists({int? min, int? max}) {
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
    late final SpotSnapshot<W> lessSpecificSnapshot;
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
      yield _buildSelector(subset);
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

Element _findCommonAncestor(List<Element> elements) =>
    IterableSortedBy(elements)
        .sortedBy((element) => element.depth)
        .first
        .parent ??
// ignore: deprecated_member_use
    WidgetsBinding.instance.renderViewElement!;
