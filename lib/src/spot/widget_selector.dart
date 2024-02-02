import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:spot/src/spot/child_element_filter.dart';
import 'package:spot/src/spot/prop_element_filter.dart';
import 'package:spot/src/spot/selectors.dart' show ChainableSelectors;
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

export 'package:spot/src/spot/tree_snapshot.dart';

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with ChainableSelectors<W> {
  /// Matches any widget currently mounted
  static final WidgetSelector all = WidgetSelector(
    stages: [
      Stage(
        props: [
          PredicateWithDescription(
            (e) => true,
            description: 'any Widget',
          ),
        ],
      ),
    ],
  );

  /// Constructor for creating a [WidgetSelector].
  ///
  /// Allows specifying various parameters for customizing the selection criteria.
  WidgetSelector({
    required this.stages,
    @Deprecated('Use quantityConstraint instead')
    ExpectedQuantity expectedQuantity = ExpectedQuantity.multi,
    QuantityConstraint? quantityConstraint,
    W Function(Element element)? mapElementToWidget,
  })  : quantityConstraint = quantityConstraint ??
            // ignore: deprecated_member_use_from_same_package
            (expectedQuantity == ExpectedQuantity.single
                ? QuantityConstraint.single
                : QuantityConstraint.unconstrained),
        mapElementToWidget = mapElementToWidget ?? defaultMapElementToWidget<W>;

  final List<Stage> stages;

  /// Whether this selector expects to find a single or multiple widgets
  @Deprecated('Use quantityConstraint instead')
  ExpectedQuantity get expectedQuantity => quantityConstraint.max == 1
      ? ExpectedQuantity.single
      : ExpectedQuantity.multi;

  /// The number of widgets that this selector expects to find
  final QuantityConstraint quantityConstraint;

  /// Default mapping function to convert an [Element] to a widget of type [W].
  ///
  /// This function is used when no custom mapping is provided in the constructor.
  static W defaultMapElementToWidget<W>(Element element) {
    return element.widget as W;
  }

  /// Overwrite this method when [W] is a synthetic widget like [AnyText] that
  /// combines multiple widgets of similar (but not exact) Type
  final W Function(Element element) mapElementToWidget;

  /// The runtime type of the widget this selector is intended for.
  Type get type => W;

  /// Returns a list of [ElementFilter] that is used to filter the widget tree
  /// (or subtrees of [parents]) for widgets that match this selectors criteria
  ///
  /// This method is intended to be overridden by subclasses to add additional
  /// filters that are not covered by this base implementation.
// List<ElementFilter> createElementFilters() {
//   return [
//     if (predecessor != null) ...predecessor!.createElementFilters(),
//     if (props.isNotEmpty) PropFilter(props),
//     if (children.isNotEmpty) ChildFilter(children),
//     ...elementFilters,
//   ];
// }

  @override
  String toString() {
    // final children = this.children.isNotEmpty
    //     ? 'with children: [${this.children.map((e) => e.toString()).join(', ')}]'
    //     : null;
    // final parents = this.parents.isNotEmpty
    //     ? 'with parents: [${this.parents.map((e) => e.toString()).join(', ')}]'
    //     : null;
    // final props = this.props.isNotEmpty
    //     ? this.props.map((e) => e.description).join(' ')
    //     : null;
    // final filters = elementFilters.isNotEmpty
    //     ? elementFilters.map((e) => e.description).join(' ')
    //     : null;
    final quantity = () {
      if (quantityConstraint.min == null && quantityConstraint.max == 0) {
        return '(amount: 0)';
      }
      if (quantityConstraint.min == 0 && quantityConstraint.max == 0) {
        return '(amount: 0)';
      }
      if (quantityConstraint.min != null &&
          quantityConstraint.min == quantityConstraint.max) {
        return '(amount: ${quantityConstraint.min})';
      }
      if (quantityConstraint.min != null && quantityConstraint.max != null) {
        return '(amount: ${quantityConstraint.min}...${quantityConstraint.max})';
      }
      if (quantityConstraint.min != null) {
        return '(amount: >=${quantityConstraint.min})';
      }
      if (quantityConstraint.max != null) {
        return '(amount: <=${quantityConstraint.max})';
      }
      return null;
    }();

    final constraints = [
      // props,
      quantity,
      // children,
      // parents,
      // filters,
    ].where((e) => e != null);
    if (constraints.isEmpty) {
      return '';
    }
    return constraints.join(' ');
  }

  /// Generates a string representation of this selector, excluding parents.
  ///
  /// This method is used internally for creating a more concise string output.
  String toStringWithoutParents() {
    // final children = this.children.isNotEmpty
    //     ? 'with children: [${this.children.map((e) => e.toString()).join(', ')}]'
    //     : null;
    // final props = this.props.isNotEmpty
    //     ? this.props.map((e) => e.description).join(' ')
    //     : null;
    // final filters = elementFilters.isNotEmpty
    //     ? elementFilters.map((e) => e.description).join(' ')
    //     : null;
    final quantity = () {
      if (quantityConstraint.min == null && quantityConstraint.max == 0) {
        return '(amount: 0)';
      }
      if (quantityConstraint.min == 0 && quantityConstraint.max == 0) {
        return '(amount: 0)';
      }
      if (quantityConstraint.min != null &&
          quantityConstraint.min == quantityConstraint.max) {
        return '(amount: ${quantityConstraint.min})';
      }
      if (quantityConstraint.min != null && quantityConstraint.max != null) {
        return '(amount: ${quantityConstraint.min}...${quantityConstraint.max})';
      }
      if (quantityConstraint.min != null) {
        return '(amount: >=${quantityConstraint.min})';
      }
      if (quantityConstraint.max != null) {
        return '(amount: <=${quantityConstraint.max})';
      }
      return null;
    }();

    final constraints = [
      // props,
      quantity,
      // children,
      // filters,
    ].where((e) => e != null);
    return constraints.join(' ');
  }

  /// Generates a breadcrumb-like string representation of this selector.
  ///
  /// This method includes parent selectors in the output, showing the full
  /// hierarchy of the selection.
  String toStringBreadcrumb() {
    return "";
    // final parents = this.parents;
    //
    // if (parents.isEmpty) {
    //   return toStringWithoutParents();
    // }
    //
    // final parentBreadcrumbs = parents.map((e) => e.toStringBreadcrumb());
    // if (parentBreadcrumbs.length == 1) {
    //   return '${parentBreadcrumbs.first} > ${toStringWithoutParents()}';
    // } else {
    //   return '[${parentBreadcrumbs.join(' && ')}] > ${toStringWithoutParents()}';
    // }
  }

  @override
  WidgetSelector<W> get self => this;

  /// Returns a new instance of [WidgetSelector] with some properties replaced
  /// with new values.
  ///
  /// This method is used for creating a new selector based on the current one
  /// but with some modified parameters.
  @useResult
  WidgetSelector<W> copyWith({
    List<Stage>? stages,
    // ignore: deprecated_member_use_from_same_package
    ExpectedQuantity? expectedQuantity,
    QuantityConstraint? quantityConstraint,
    W Function(Element element)? mapElementToWidget,
  }) {
    return WidgetSelector<W>(
      stages: stages ?? this.stages,
      quantityConstraint: quantityConstraint ?? this.quantityConstraint,
      mapElementToWidget: mapElementToWidget ?? this.mapElementToWidget,
    );
  }

  @useResult
  WidgetSelector<W> addStage(Stage stage) {
    return copyWith(stages: [...stages, stage]);
  }
}

class Stage {
  Stage({
    List<PredicateWithDescription>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    List<ElementFilter>? elementFilters,
  })  : props = List.unmodifiable(props ?? []),
        parents = List.unmodifiable(parents?.toSet().toList() ?? []),
        children = List.unmodifiable(children ?? []),
        elementFilters = List.unmodifiable(elementFilters ?? []);

  /// A list of predicates with descriptions used to filter the widget tree nodes.
  ///
  /// These predicates define various conditions that the nodes must satisfy
  /// to be included in the filtered set.
  final List<PredicateWithDescription> props;

  /// A list of parent selectors used to define a hierarchical
  /// context for the selection.
  ///
  /// These selectors specify the parent widgets in the tree that the current
  /// selector's widget must be a descendant of.
  final List<WidgetSelector> parents;

  /// A list of child selectors used to filter widgets based on their children.
  ///
  /// These selectors are applied to the children of the widget being matched,
  /// allowing for selection based on child widget properties.
  final List<WidgetSelector> children;

  /// A list of element filters used to apply additional custom filtering logic.
  ///
  /// These filters enable advanced selection criteria beyond the standard
  /// widget properties and hierarchy.
  final List<ElementFilter> elementFilters;

  List<ElementFilter> createElementFilter() {
    return [
      if (parents.isNotEmpty) ParentFilter(parents),
      if (props.isNotEmpty) PropFilter(props),
      if (children.isNotEmpty) ChildFilter(children),
      ...elementFilters,
    ];
  }
}

/// A [WidgetSelector] that intends to resolve to a single widget
@Deprecated('Use WidgetSelector')
typedef SingleWidgetSelector<W extends Widget> = WidgetSelector<W>;

/// A [WidgetSelector] that to 0..N widgets
@Deprecated('Use WidgetSelector')
typedef MultiWidgetSelector<W extends Widget> = WidgetSelector<W>;

/// Base class for defining filters on widget tree nodes.
///
/// Filters are used to narrow down the set of widget tree nodes based on
/// specific criteria.
///
/// Notable implementations:
/// - [PropFilter]
/// - [ChildFilter]
/// - [WidgetTypeFilter]
abstract class ElementFilter {
  /// Filters all candidates, retuning only a subset that matches
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates);

  /// A description to describe the filter
  String get description;
}

/// Defines the quantity constraints for the number of widgets
/// expected to be found.
///
/// This class specifies the minimum and maximum number of widgets that a
/// selector should match, enabling precise control over the selection criteria.
class QuantityConstraint {
  /// Constructs a [QuantityConstraint] with optional minimum and maximum values.
  ///
  /// The [min] value specifies the minimum number of widgets to match, and
  /// the [max] value specifies the maximum number of widgets to match.
  /// If both are provided, [min] must be less than or equal to [max].
  const QuantityConstraint({this.min, this.max})
      : assert(min == null || max == null || min <= max);

  /// Constructs a [QuantityConstraint] where exactly [n] widgets should match.
  const QuantityConstraint.exactly(int n)
      : min = n,
        max = n;

  /// Constructs a [QuantityConstraint] where at least [n] widgets should match.
  const QuantityConstraint.atLeast(int n)
      : min = n,
        max = null;

  /// Constructs a [QuantityConstraint] where at most [n] widgets should match.
  const QuantityConstraint.atMost(int n)
      : min = null,
        max = n;

  /// Represents an unconstrained quantity, allowing any number of widgets
  /// to match.
  static const QuantityConstraint unconstrained = QuantityConstraint();

  /// Represents a constraint where no widgets should match.
  static const QuantityConstraint zero = QuantityConstraint.atMost(0);

  /// Represents a constraint where exactly one widget should match.
  static const QuantityConstraint single = QuantityConstraint.atMost(1);

  /// The minimum number of widgets that should match. `null` for no minimum.
  final int? min;

  /// The maximum number of widgets that should match. `null` for no maximum.
  final int? max;

  @override
  String toString() {
    if (min == null && max == null) {
      return 'QuantityConstraint.unconstrained';
    }
    if (max == 0) {
      return 'QuantityConstraint.zero';
    }
    return 'QuantityConstraint{min: $min, max: $max}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantityConstraint &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;
}

/// Represents the expected quantity of widgets a selector should match.
@Deprecated('Use QuantityConstraint instead')
enum ExpectedQuantity {
  /// A selector that matches a single widget
  single,

  /// A selector that matches multiple widgets
  multi,
}

/// Represents a predicate with an associated description.
///
/// Used to create readable and descriptive predicates in widget testing.
class PredicateWithDescription {
  /// Constructs a [PredicateWithDescription] with a predicate function and
  /// a description.
  PredicateWithDescription(
    this.predicate, {
    required this.description,
  });

  /// The predicate function to evaluate.
  final bool Function(Element) predicate;

  /// Description of what this predicate checks.
  final String description;

  @override
  String toString() {
    return 'PredicateWithDescription{"$description"}';
  }
}

/// Filters candidates by widget type [W] comparing the runtime type.
///
/// Comparing the runtimeType makes sure that `spot<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
class WidgetTypeFilter<W extends Widget> implements ElementFilter {
  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final type = _typeOf<W>();
    return candidates
        .where((WidgetTreeNode node) => node.element.widget.runtimeType == type)
        .toList();
  }

  @override
  String get description => '$W';

  @override
  String toString() {
    return 'WidgetTypeFilter of $W';
  }
}

class ParentFilter implements ElementFilter {
  ParentFilter(this.parents);

  final List<WidgetSelector> parents;

  @override
  String get description => throw UnimplementedError();

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final tree = currentWidgetTreeSnapshot();
    final List<WidgetSnapshot<Widget>> parentSnapshots =
        parents.map((selector) {
      final WidgetSnapshot<Widget> widgetSnapshot = snapshot(selector);
      widgetSnapshot.validateQuantity();
      return widgetSnapshot;
    }).toList();

    // Take a snapshot from each parent and get the snapshots of all nodes that match
    final List<Map<WidgetTreeNode, List<WidgetSnapshot>>> discoveryByParent =
        parentSnapshots.map((WidgetSnapshot<Widget> parentSnapshot) {
      final Map<WidgetTreeNode, List<WidgetSnapshot>> groups = {};
      if (parentSnapshot.discovered.isEmpty) {
        return groups;
      }

      for (final WidgetTreeNode node in parentSnapshot.discovered) {
        final WidgetSnapshot group =
            findWithinScope(tree.scope(node), WidgetSelector.all);
        final list = groups[node];
        if (list == null) {
          groups[node] = [group];
        } else {
          list.add(group);
        }
      }

      return groups;
    }).toList();

    final List<WidgetSnapshot> discoveredSnapshots =
        discoveryByParent.map((it) => it.values).flatten().flatten().toList();

    final List<WidgetTreeNode> allDiscoveredNodes =
        discoveredSnapshots.map((it) => it.discovered).flatten().toList();

    final List<Element> distinctElements =
        allDiscoveredNodes.map((e) => e.element).toSet().toList();

    // find nodes that exist in all parents
    final List<Element> elementsInAllParents =
        distinctElements.where((element) {
      return discoveryByParent.all((
        Map<WidgetTreeNode, List<WidgetSnapshot>> discovered,
      ) {
        return discovered.values.any((List<WidgetSnapshot> list) {
          return list.any((node) {
            return node.discovered.map((e) => e.element).contains(element);
          });
        });
      });
    }).toList();

    return elementsInAllParents.mapNotNull((e) {
      return candidates.firstWhereOrNull((node) => node.element == e);
    }).toList();
  }
}

Type _typeOf<T>() => T;
