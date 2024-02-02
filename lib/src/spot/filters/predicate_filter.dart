import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Filters widget tree nodes based on a predicate
class PredicateFilter implements ElementFilter {
  /// The predicate function to evaluate.
  final bool Function(Element) predicate;

  /// Creates a super generic filter that filters based on a predicate.
  ///
  /// The [description] is used to describe the filter in error messages.
  PredicateFilter({required this.predicate, required this.description});

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates.where((node) {
      return predicate(node.element);
    });
  }

  @override
  final String description;

  @override
  String toString() {
    return 'PredicateFilter of $description';
  }
}
