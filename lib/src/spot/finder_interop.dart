import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// Extensions that convert from the [Finder] API to spot
extension FinderToSpot on Finder {
  /// Converts the [Finder] to a [WidgetSelector]
  ///
  /// Like a [Finder], [WidgetSelector] can return 0, 1, or N widgets
  @useResult
  WidgetSelector<W> spot<W extends Widget>() {
    return _FinderSelector<W>(this);
  }
}

/// Extensions that convert the spot API to the [Finder] API
extension SpotToFinder<W extends Widget> on WidgetSelector<W> {
  /// Converts the [WidgetSelector] from spot to a [Finder]
  ///
  /// ```dart
  /// await tester.tap(spot<RaisedButton>().finder);
  /// ```
  Finder get finder => _FinderFromWidgetSelector(this);

  /// Finds all elements that match [finder] and converts them to a [WidgetSelector].
  ///
  /// Use [T] to specify the type of [Widget] to match.
  @useResult
  WidgetSelector<T> spotFinder<T extends Widget>(Finder finder) {
    return _FinderSelector<T>(finder, parent: this);
  }
}

class _FinderSelector<W extends Widget> extends WidgetSelector<W> {
  final Finder finder;

  _FinderSelector(
    this.finder, {
    WidgetSelector? parent,
  }) : super(parents: parent != null ? [parent] : []);

  @override
  List<ElementFilter> createElementFilters() {
    return [...super.createElementFilters(), _FinderFilter(finder)];
  }

  @override
  String toString() {
    final overridden = super.toString();
    // ignore: deprecated_member_use
    return 'widget with ${finder.description}'
        '${overridden.isNotEmpty ? ' $overridden' : ''}';
  }

  @override
  String toStringWithoutParents() {
    final overridden = super.toStringWithoutParents();
    // ignore: deprecated_member_use
    return 'widget with ${finder.description}'
        '${overridden.isNotEmpty ? ' $overridden' : ''}';
  }
}

class _FinderFilter extends ElementFilter {
  final Finder finder;

  _FinderFilter(this.finder);

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    // ignore: deprecated_member_use
    return candidates.filter((it) => finder.apply([it.element]).isNotEmpty);
  }
}

class _FinderFromWidgetSelector extends Finder {
  final WidgetSelector selector;

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final found = selector.snapshot().discovered.map((it) => it.element);
    return candidates.where((element) => found.contains(element));
  }

  @override
  String get description => 'Finder from $selector';

  _FinderFromWidgetSelector(this.selector);
}
