import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

/// Creates a snapshot of widgets that match the specified [selector].
///
/// This function captures the current state of widgets that match the criteria
/// defined in [selector] for further analysis or assertions.
///
/// Parameters:
///   [selector] - The [WidgetSelector] used to find the widgets.
///   [validateQuantity] - If `true`, validates that the number of discovered
///                        widgets matches the quantity constraint in the selector.
///
/// Returns:
///   A [WidgetSnapshot] containing the discovered widgets, their elements, and
///   the scope of the widget tree where the search was performed.
///
/// This function handles both simple selectors and selectors with parent
/// constraints. For parent-constrained selectors, it generates candidates
/// based on the parent selectors and applies additional filters as defined
/// in the selector.
WidgetSnapshot<W> snapshot<W extends Widget>(
  WidgetSelector<W> selector, {
  bool validateQuantity = true,
}) {
  TestAsyncUtils.guardSync();
  final treeSnapshot = currentWidgetTreeSnapshot();

  if (selector.parents.isEmpty) {
    final WidgetSnapshot<W> snapshot = findWithinScope(treeSnapshot, selector);
    if (validateQuantity) {
      snapshot.validateQuantity();
    }
    return snapshot;
  }

  final List<WidgetTreeNode> candidates =
      selector.createCandidateGenerator().generateCandidates().toList();

  final filters = selector.createElementFilters();
  final discovered =
      filters.fold<Iterable<WidgetTreeNode>>(candidates, (list, filter) {
    return filter.filter(list);
  }).toList();

  final snapshot = WidgetSnapshot<W>(
    selector: selector,
    discovered: discovered,
    scope: treeSnapshot,
    debugCandidates: candidates.map((element) => element.element).toList(),
  );

  if (validateQuantity) {
    snapshot.validateQuantity();
  }

  return snapshot;
}

/// Generates candidate widget tree nodes based on parent selectors for a
/// given widget type [W].
///
/// This class is used to create a set of candidates by considering the
/// hierarchical context defined by parent selectors in a [WidgetSelector].
class CandidateGeneratorFromParents<W extends Widget>
    implements CandidateGenerator<W> {
  /// Constructs a [CandidateGeneratorFromParents] using the
  /// provided [selector].
  CandidateGeneratorFromParents(this.selector);

  /// The [WidgetSelector] whose parent selectors are used to generat
  /// candidates.
  final WidgetSelector<W> selector;

  @override
  Iterable<WidgetTreeNode> generateCandidates() {
    final tree = currentWidgetTreeSnapshot();
    final List<WidgetSnapshot<Widget>> parentSnapshots =
        selector.parents.map((selector) {
      final WidgetSnapshot<Widget> widgetSnapshot = snapshot(selector);
      widgetSnapshot.validateQuantity();
      return widgetSnapshot;
    }).toList();

    final WidgetSelector<W> selectorWithoutParents =
        selector.copyWith(parents: []);

    // Take a snapshot from each parent and get the snapshots of all nodes that match
    final List<Map<WidgetTreeNode, List<WidgetSnapshot<W>>>> discoveryByParent =
        parentSnapshots.map((WidgetSnapshot<Widget> parentSnapshot) {
      final Map<WidgetTreeNode, List<WidgetSnapshot<W>>> groups = {};
      if (parentSnapshot.discovered.isEmpty) {
        return groups;
      }

      for (final WidgetTreeNode node in parentSnapshot.discovered) {
        final WidgetSnapshot<W> group =
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

    final List<WidgetSnapshot<W>> discoveredSnapshots =
        discoveryByParent.map((it) => it.values).flatten().flatten().toList();

    final List<WidgetTreeNode> allDiscoveredNodes =
        discoveredSnapshots.map((it) => it.discovered).flatten().toList();

    final List<Element> distinctElements =
        allDiscoveredNodes.map((e) => e.element).toSet().toList();

    // find nodes that exist in all parents
    final List<Element> elementsInAllParents =
        distinctElements.where((element) {
      return discoveryByParent.all((
        Map<WidgetTreeNode, List<WidgetSnapshot<W>>> discovered,
      ) {
        return discovered.values.any((List<WidgetSnapshot<W>> list) {
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
WidgetSnapshot<W> findWithinScope<W extends Widget>(
  ScopedWidgetTreeSnapshot scope,
  WidgetSelector<W> selector,
) {
  if (selector.parents.isNotEmpty) {
    throw "Don't use findWithinScope with a selector that has parents. "
        "Either remove them or use snapshot() instead";
  }
  final candidates = scope.allNodes;
  final List<ElementFilter> filters = selector.createElementFilters();

  final List<WidgetTreeNode> discovered = filters
      .fold<Iterable<WidgetTreeNode>>(candidates, (list, ElementFilter filter) {
    final Iterable<WidgetTreeNode> result = filter.filter(list);
    return result;
  }).toList();

  return WidgetSnapshot<W>(
    selector: selector,
    discovered: discovered,
    scope: scope,
    debugCandidates: candidates.map((it) => it.element).toList(),
  );
}

extension _ValidateQuantity<W extends Widget> on WidgetSnapshot<W> {
  void validateQuantity() {
    final count = discovered.length;
    final minimumConstraint = selector.quantityConstraint.min;
    final maximumConstraint = selector.quantityConstraint.max;

    final unconstrainedSelector =
        selector.overrideQuantityConstraint(QuantityConstraint.unconstrained);

    String significantWidgetTree() {
      final set = discoveredElements.toSet();
      return findCommonAncestor(set).toStringDeep();
    }

    if (minimumConstraint != null && maximumConstraint == null) {
      if (count == 0) {
        _tryMatchingLessSpecificCriteria(this);
        throw TestFailure(
          'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at least $minimumConstraint\n'
          '${significantWidgetTree()}'
          'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at least $minimumConstraint',
        );
      }

      if (minimumConstraint > count) {
        _tryMatchingLessSpecificCriteria(this);
        throw TestFailure(
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at least $minimumConstraint\n'
          '${significantWidgetTree()}'
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at least $minimumConstraint',
        );
      }
    }

    if (maximumConstraint != null && minimumConstraint == null) {
      if (maximumConstraint < count) {
        throw TestFailure(
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at most $maximumConstraint\n'
          '${significantWidgetTree()}'
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected at most $maximumConstraint',
        );
      }
    }

    if (minimumConstraint != null && maximumConstraint != null) {
      if (minimumConstraint == maximumConstraint) {
        final exactCount = minimumConstraint;
        if (count == exactCount) {
          // exact match, all fine
          return;
        } else {
          if (count == 0) {
            _tryMatchingLessSpecificCriteria(this);
            throw TestFailure(
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $exactCount\n'
              '${significantWidgetTree()}'
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $exactCount',
            );
          } else {
            _tryMatchingLessSpecificCriteria(this);
            throw TestFailure(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $exactCount\n'
              '${significantWidgetTree()}'
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $exactCount',
            );
          }
        }
      } else {
        // out of range
        throw TestFailure(
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected between $minimumConstraint and $maximumConstraint\n'
          '${significantWidgetTree()}'
          'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
          'expected between $minimumConstraint and $maximumConstraint',
        );
      }
    }
  }
}

/// Extension on [WidgetSnapshot]<W> providing matchers for asserting
/// the existence of a specific number of widgets.
///
/// These matchers allow checking if a certain number of widgets of type [W]
/// exist in the widget tree based on the snapshot's selector.
extension MultiWidgetSelectorMatcher<W extends Widget> on WidgetSnapshot<W> {
  /// Asserts that no widgets of type [W] exist.
  void doesNotExist() => _exists(max: 0);

  /// Asserts that exactly one widget of type [W] exists.
  WidgetMatcher<W> existsOnce() =>
      WidgetMatcher.fromSnapshot(_exists(min: 1, max: 1));

  /// Asserts that at least one widget of type [W] exists.
  MultiWidgetMatcher<W> existsAtLeastOnce() => _exists(min: 1).multi;

  /// Asserts that at most one widget of type [W] exists.
  WidgetMatcher<W> existsAtMostOnce() =>
      WidgetMatcher.fromSnapshot(_exists(max: 1));

  /// Asserts that exactly [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsExactlyNTimes(int n) =>
      _exists(min: n, max: n).multi;

  /// Asserts that at least [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtLeastNTimes(int n) => _exists(min: n).multi;

  /// Asserts that at most [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtMostNTimes(int n) => _exists(max: n).multi;

  /// Internal method to check the existence of widgets with optional
  /// minimum and maximum limits.
  ///
  /// Validates the number of discovered widgets against the provided [min]
  /// and [max] constraints.
  /// Throws a descriptive error if the actual count of widgets does not meet
  /// the constraints.
  WidgetSnapshot<W> _exists({int? min, int? max}) {
    assert(min != null || max != null);
    assert(min == null || min > 0);
    assert(max == null || max >= 0);
    assert(min == null || max == null || min <= max);

    final count = discovered.length;

    if (min != null) {
      if (count < min) {
        // try finding similar selectors (less specific)
        // if one is found, fail with a more specific error message
        _tryMatchingLessSpecificCriteria(this);

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

        errorBuilder
            .writeln(findCommonAncestor(discoveredElements).toStringDeep());

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
void _tryMatchingLessSpecificCriteria(WidgetSnapshot snapshot) {
  final selector = snapshot.selector;
  final count = snapshot.discovered.length;
  final errorBuilder = StringBuffer();
  final unconstrainedSelector =
      selector.overrideQuantityConstraint(QuantityConstraint.unconstrained);
  for (final lessSpecificSelector
      in unconstrainedSelector._lessSpecificSelectors()) {
    late final WidgetSnapshot lessSpecificSnapshot;
    try {
      lessSpecificSnapshot = lessSpecificSelector.snapshot();
    } catch (e) {
      continue;
    }
    final lessSpecificCount = lessSpecificSnapshot.discovered.length;
    final minimumConstraint = selector.quantityConstraint.min;
    final maximumConstraint = selector.quantityConstraint.max;
    final unconstrainedSelector =
        selector.overrideQuantityConstraint(QuantityConstraint.unconstrained);

    // error that selector could not be found, but instead spot detected lessSpecificSnapshot, which might be useful
    if (lessSpecificCount > count) {
      if (minimumConstraint != null && maximumConstraint == null) {
        if (count == 0) {
          errorBuilder.writeln(
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $minimumConstraint');
        }

        if (minimumConstraint > count) {
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $minimumConstraint');
        }
      }

      if (maximumConstraint != null && minimumConstraint == null) {
        if (maximumConstraint < count) {
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at most $maximumConstraint');
        }
      }

      if (minimumConstraint != null && maximumConstraint != null) {
        if (minimumConstraint == maximumConstraint) {
          final exactCount = minimumConstraint;
          if (count == 0) {
            errorBuilder.writeln(
                'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected exactly $exactCount');
          } else {
            errorBuilder.writeln(
                'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected exactly $exactCount');
          }
        } else {
          // out of range
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected between $minimumConstraint and $maximumConstraint');
        }
      }

      errorBuilder.writeln(
        "A less specific search ($lessSpecificSelector) discovered $lessSpecificCount matches!",
      );
      errorBuilder.writeln(
        'Maybe you have to adjust your WidgetSelector ($unconstrainedSelector) to cover those missing elements.\n',
      );
      int index = 0;
      for (final Element match in lessSpecificSnapshot.discoveredElements) {
        index++;
        errorBuilder.writeln(
          'Possible match #$index:\n${match.toStringDeep(minLevel: DiagnosticLevel.info)}',
        );
      }
      final significantTree =
          findCommonAncestor(lessSpecificSnapshot.discoveredElements.toSet())
              .toStringDeep();
      errorBuilder.writeln('\nFound in widget Tree:\n$significantTree');
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

/// Extension on [Element] providing access to parent and child elements.
extension ElementParent on Element {
  /// Gets the immediate parent of this element.
  Element? get parent {
    Element? parent;
    visitAncestorElements((element) {
      parent = element;
      return false;
    });
    return parent;
  }

  /// Gets all parent elements of this element.
  Iterable<Element> get parents sync* {
    Element? element = this;
    while (element != null) {
      yield element;
      element = element.parent;
    }
  }

  /// Gets all immediate child elements of this element.
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
      props: [],
      parents: [],
      children: [],
      quantityConstraint: QuantityConstraint.unconstrained,
    );
    for (final criteria in criteria) {
      s = criteria(s);
    }
    return s;
  }
}

/// Generates all subsets of a given list.
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

/// Finds the common ancestor of a set of elements.
Element findCommonAncestor(Iterable<Element> elements) {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement!;
  if (elements.isEmpty) {
    return rootElement;
  } else if (elements.length == 1) {
    return elements.first.parent ?? rootElement;
  }

  // get element with smallest depth to reach common ancestor faster
  final highestElement =
      IterableSortedBy(elements).sortedBy((element) => element.depth).first;
  // save all other parents
  final allOtherParents =
      elements.exceptElement(highestElement).map((e) => e.parents);

  final commonAncestor = highestElement.parents.firstWhereOrNull(
    (parent) => allOtherParents.every((parents) => parents.contains(parent)),
  );

  return commonAncestor ?? rootElement;
}
