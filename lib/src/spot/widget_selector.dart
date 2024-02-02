import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:spot/src/spot/filters/child_filter.dart';
import 'package:spot/src/spot/filters/parent_filter.dart';
import 'package:spot/src/spot/filters/predicate_filter.dart';
import 'package:spot/src/spot/filters/widget_type_filter.dart';
import 'package:spot/src/spot/selectors.dart' show ChainableSelectors;
import 'package:spot/src/spot/tree_snapshot.dart';

export 'package:spot/src/spot/tree_snapshot.dart';

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with ChainableSelectors<W> {
  /// Matches any widget currently mounted
  static final WidgetSelector all = WidgetSelector(
    stages: [
      PredicateFilter(
        predicate: (e) => true,
        description: 'any Widget',
      ),
    ],
  );

  /// Separator indicating a parent-child relationship between selectors
  ///
  /// ```
  /// MaterialApp ᗕ Scaffold
  /// ```
  ///
  /// MaterialApp is parent of Scaffold
  static const String inheritanceSeparator = ' ᗕ ';

  /// Separator splitting stages of a selector
  ///
  /// ```
  /// IconButton ❯ (at index 1) ❯ with prop "color" equals <MaterialColor(primary value: Color(0xff4caf50))>
  /// ```
  ///
  /// IconButton is stage 1, taking the second item is stage 2, and matching the color is stage 3
  static const String stageSeparator = ' ❯ ';

  /// Constructor for creating a [WidgetSelector].
  ///
  /// Allows specifying various parameters for customizing the selection criteria.
  WidgetSelector({
    required List<ElementFilter> stages,
    @Deprecated('Use quantityConstraint instead')
    ExpectedQuantity expectedQuantity = ExpectedQuantity.multi,
    QuantityConstraint? quantityConstraint,
    W Function(Element element)? mapElementToWidget,
  })  : stages = List.unmodifiable(stages),
        quantityConstraint = quantityConstraint ??
            // ignore: deprecated_member_use_from_same_package
            (expectedQuantity == ExpectedQuantity.single
                ? QuantityConstraint.single
                : QuantityConstraint.unconstrained),
        mapElementToWidget = mapElementToWidget ?? defaultMapElementToWidget<W>;

  /// The list of filters which are used to narrow down the selection of widgets in the tree
  ///
  /// Each filter is applied in sequence (order is important for filters like `.atIndex(1)`)
  ///
  /// Usual filters are:
  /// - [ParentFilter]
  /// - [ChildFilter]
  /// - [PredicateFilter]
  /// - [WidgetTypeFilter]
  final List<ElementFilter> stages;

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

  @override
  String toString() {
    final sb = StringBuffer();
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      if (stage is ParentFilter) {
        var desc = stage.parents.first.toString();
        if (desc.contains(' with parent ') || desc.contains(' with child ')) {
          desc = '($desc)';
        }
        sb.write('with parent $desc');
      } else if (stage is ChildFilter) {
        if (stage.childSelectors.length == 1) {
          var desc = stage.childSelectors.first.toString();
          if (desc.contains(' with parent ') || desc.contains(' with child ')) {
            desc = '($desc)';
          }
          sb.write('with child $desc');
        } else {
          var desc = stage.childSelectors.map((e) => e.toString()).join(', ');
          if (desc.contains(' with parent ') || desc.contains(' with child ')) {
            desc = '($desc)';
          }
          sb.write('with children [$desc]');
        }
      } else {
        final desc = stage.description;
        if (desc.contains(' with parent ') || desc.contains(' with child ')) {
          sb.write('($desc)');
        } else {
          sb.write(desc);
        }
      }

      final isLast = i == stages.length - 1;
      if (stage is WidgetTypeFilter) {
        sb.write(' ');
      } else if (!isLast) {
        sb.write(stageSeparator);
      }
    }
    final parts =
        [sb.toString().trim(), _quantityToString()].where((e) => e != null);
    return parts.join(' ');
  }

  /// Generates a breadcrumb-like string representation of this selector.
  ///
  /// This method includes parent selectors in the output, showing the full
  /// hierarchy of the selection.
  String toStringBreadcrumb() {
    var sb = StringBuffer();
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      if (stage is ParentFilter) {
        var child = sb.toString();
        if (child.endsWith(stageSeparator)) {
          // Remove stage separator from the end
          child = child.substring(0, child.length - stageSeparator.length);
        }
        sb = StringBuffer();
        final String desc;
        if (stage.parents.length == 1) {
          desc = stage.parents.first.toStringBreadcrumb();
        } else {
          desc =
              '[${stage.parents.map((e) => e.toStringBreadcrumb()).join(', ')}]';
        }
        if (desc.contains(inheritanceSeparator) ||
            desc.contains(stageSeparator)) {
          sb.write('($desc)');
        } else {
          sb.write(desc);
        }
        sb.write(inheritanceSeparator);
        sb.write(child);
      } else if (stage is ChildFilter) {
        if (stage.childSelectors.length == 1) {
          var desc = stage.childSelectors.first.toStringBreadcrumb();
          if (desc.contains(inheritanceSeparator) ||
              desc.contains(stageSeparator)) {
            desc = '($desc)';
          }
          sb.write('with child $desc');
        } else {
          var desc = stage.childSelectors
              .map((e) => e.toStringBreadcrumb())
              .join(', ');
          if (desc.contains(inheritanceSeparator) ||
              desc.contains(stageSeparator)) {
            desc = '($desc)';
          }
          sb.write('with children [$desc]');
        }
      } else {
        final desc = stage.description;
        if (desc.contains(inheritanceSeparator) ||
            desc.contains(stageSeparator)) {
          sb.write('($desc)');
        } else {
          sb.write(desc);
        }
      }

      final isLast = i == stages.length - 1;
      if (stage is WidgetTypeFilter) {
        if (!sb.toString().endsWith(' ')) {
          sb.write(' ');
        }
      } else if (!isLast) {
        if (!sb.toString().endsWith(stageSeparator)) {
          sb = StringBuffer(sb.toString().trimRight());
          sb.write(stageSeparator);
        }
      }
    }

    final parts =
        [sb.toString().trim(), _quantityToString()].where((e) => e != null);
    return parts.join(' ');
  }

  /// Generates a string representation of the quantity constraints.
  String? _quantityToString() {
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
    List<ElementFilter>? stages,
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
}

/// Allows modification of stages of a [WidgetSelector]
extension MutateStages<W extends Widget> on WidgetSelector<W> {
  /// Adds a new [stage] to at the end to further narrow down the selection of widgets
  @useResult
  WidgetSelector<W> addStage(ElementFilter newStage) {
    return copyWith(stages: [...stages, newStage]);
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
/// - [PredicateFilter]
/// - [ChildFilter]
/// - [WidgetTypeFilter]
/// - [ParentFilter]
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
