import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart';

/// A type alias for a snapshot that can contain multiple widgets.
@Deprecated('Use WidgetSnapshot')
typedef MultiWidgetSnapshot<W extends Widget> = WidgetSnapshot<W>;

/// A type alias for a snapshot that contains a single widget.
@Deprecated('Use WidgetSnapshot')
typedef SingleWidgetSnapshot<W extends Widget> = WidgetSnapshot<W>;

/// Represents a snapshot of widgets that have been discovered
/// by a [WidgetSelector].
///
/// This class encapsulates the result of a widget selection process, containing
/// information about the widgets that matched the selector's criteria.
class WidgetSnapshot<W extends Widget> {
  /// Constructs a [WidgetSnapshot].
  WidgetSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
    required this.scope,
  }) : _widgets = Map.fromEntries(
          discovered
              .map((e) => MapEntry(e, selector.mapElementToWidget(e.element))),
        );

  /// The widgets at the point when the snapshot was taken
  ///
  /// [Element] is a mutable object that might have changed since the snapshot
  /// was taken. This is a reference to the widget that was found at the time
  /// the snapshot was taken. This allows to compare the widget with the current
  /// widget in the tree.
  final Map<WidgetTreeNode, Widget> _widgets;

  /// The [WidgetSelector] that was used to search/filter elements in [scope]
  final WidgetSelector<W> selector;

  /// A widget tree (not necessarily the whole tree) that was used to
  /// match elements with [selector]
  final ScopedWidgetTreeSnapshot scope;

  /// All widgets from [scope] that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  /// All elements in [scope] that match [selector]
  final List<WidgetTreeNode> discovered;

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${discoveredElements.length} matches)}';
  }
}

/// Extension on [WidgetSnapshot<W>] to convert it to [WidgetMatcher] types.
///
/// Provides convenience methods to transform a widget snapshot into matchers
/// for single or multiple widgets.
// TODO make WidgetSnapshot implement WidgetMatcher and MultiWidgetMatcher
extension ToWidgetMatcher<W extends Widget> on WidgetSnapshot<W> {
  /// Converts the snapshot to a [MultiWidgetMatcher],
  /// which can match multiple widgets.
  ///
  /// This method is used when you want to perform assertions or operations
  /// on multiple widgets discovered by the snapshot.
  @useResult
  MultiWidgetMatcher<W> get multi {
    return MultiWidgetMatcher.fromSnapshot(this);
  }

  /// Converts the snapshot to a [WidgetMatcher],
  /// ensuring it matches at most one widget.
  ///
  /// This method is used for assertions or operations on a single widget.
  /// It asserts that the snapshot contains at most one widget.
  @useResult
  WidgetMatcher<W> get single {
    assert(discovered.length <= 1);
    return existsAtMostOnce();
  }
}

/// Extension on [WidgetSnapshot]<W> providing shorthand accessors
/// to the discovered widgets and elements.
///
/// Offers convenient methods to retrieve single widgets or elements
/// and lists of discovered widgets and elements.
extension WidgetSnapshotShorthands<W extends Widget> on WidgetSnapshot<W> {
  /// Gets the first discovered widget of type [W], if any.
  /// Returns `null` if no such widget was discovered.
  W? get discoveredWidget => discoveredWidgets.firstOrNull;

  /// Deprecated: Use [discoveredWidget] instead.
  @Deprecated('Use discoveredWidget')
  W? get widget => discoveredWidget;

  /// Gets the first discovered [Element], if any.
  /// Returns `null` if no element was discovered.
  Element? get discoveredElement => discoveredElements.firstOrNull;

  /// Deprecated: Use [discoveredElement] instead.
  @Deprecated('Use discoveredElement')
  Element? get element => discoveredElement;

  /// Shorthand to get the widgets of all discovered elements
  /// (see [discovered] or [discoveredElements])
  ///
  /// This list may be incomplete for synthetic widgets like [AnyText],
  /// when the widgets are not of type [W].
  ///
  /// To check the number of discovered elements, always use [discovered]
  /// or [discoveredElements]. Use [discoveredWidgets] only when you need
  /// to access any properties of the widgets.
  List<W> get discoveredWidgets => _widgets.values.whereType<W>().toList();

  /// A list of all elements that were discovered.
  /// Use this list to access elements corresponding to the discovered widgets.
  List<Element> get discoveredElements =>
      discovered.map((e) => e.element).toList();
}

/// Creates a snapshot of widgets that match the specified [selector].
///
/// This function captures the current state of widgets that match the criteria
/// defined in [selector] for further analysis or assertions. It handles both
/// simple selectors and selectors with parent constraints. For
/// parent-constrained selectors, it generates candidates based on the parent
/// selectors and applies additional filters as defined in the selector.
WidgetSnapshot<W> snapshot<W extends Widget>(
  WidgetSelector<W> selector, {
  bool validateQuantity = true,
}) {
  TestAsyncUtils.guardSync();
  final treeSnapshot = currentWidgetTreeSnapshot();
  final List<WidgetTreeNode> candidates = treeSnapshot.allNodes;
  final filters = selector.stages;

  // an easy to debug list of all filters and their individual results
  final List<({ElementFilter filter, List<WidgetTreeNode> candidates})>
      results = [];

  final discovered =
      filters.fold<Iterable<WidgetTreeNode>>(candidates, (list, filter) {
    if (list.isEmpty) {
      return [];
    }
    final before = list.toList();
    final after = filter.filter(before).toList();
    results.add((filter: filter, candidates: after));
    return after;
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

/// Finds elements inside scope, completely ignores parents
WidgetSnapshot<W> findWithinScope<W extends Widget>(
  ScopedWidgetTreeSnapshot scope,
  WidgetSelector<W> selector,
) {
  // if (selector.parents.isNotEmpty) {
  //   throw "Don't use findWithinScope with a selector that has parents. "
  //       "Either remove them or use snapshot() instead";
  // }
  final candidates = scope.allNodes;
  final List<ElementFilter> filters = selector.stages;

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

/// Extension on [WidgetSnapshot]<W> providing methods to validate the quantity of discovered widgets.
extension ValidateQuantity<W extends Widget> on WidgetSnapshot<W> {
  /// Validates the quantity of [discovered] to match [WidgetSelector.quantityConstraint]
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

        discovered.forEachIndexed((candidate, index) {
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
      for (final stage in stages)
        (s) => s.copyWith(stages: [...s.stages, stage]),
    ];

    for (final subset in getAllSubsets(criteria)) {
      final selector = _buildSelector(subset);
      // do not yield selectors which match any widgets
      if (selector.stages.isNotEmpty || selector.type != Widget) {
        yield selector;
      }
    }
  }

  WidgetSelector<W> _buildSelector(
    List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria,
  ) {
    WidgetSelector<W> s = copyWith(
      stages: [],
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

  final commonAncestor = highestElement.parents.firstOrNullWhere(
    (parent) => allOtherParents.every((parents) => parents.contains(parent)),
  );

  return commonAncestor ?? rootElement;
}
