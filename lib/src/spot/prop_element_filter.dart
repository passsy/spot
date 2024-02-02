import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Filters widget tree nodes based on a predicate
class PropFilter implements ElementFilter {
  /// The predicate function to evaluate.
  final bool Function(Element) predicate;

  /// Which property to match
  PropFilter({required this.predicate, required this.description});

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
    return 'PropFilter of $description';
  }
}
