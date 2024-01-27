import 'package:dartx/dartx.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Filters widget tree nodes based on a set of properties.
///
/// Applies multiple [PredicateWithDescription] objects to filter nodes.
/// Nodes must meet all property conditions to be included in the result.
class PropFilter implements ElementFilter {
  /// A list of predicates with descriptions used to filter the widget tree nodes.
  ///
  /// Each predicate defines a condition that the node must satisfy to be included
  /// in the filtered set.
  final List<PredicateWithDescription> props;

  /// Constructs a [PropFilter] with a list of [PredicateWithDescription].
  ///
  /// The [props] parameter takes a list of predicates, each with a description,
  /// which are used to filter the widget tree nodes.
  PropFilter(this.props);

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates.where((node) {
      return props.all((prop) {
        return prop.predicate(node.element);
      });
    }).toList();
  }

  @override
  String get description {
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;
    return props ?? 'any Widget';
  }

  @override
  String toString() {
    return 'PropFilter of $description';
  }
}
