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
    return WidgetSelector<W>(
      stages: [
        Stage(
          elementFilters: [_FinderFilter(this)],
        ),
      ],
    );
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
    return WidgetSelector<T>(
      stages: [
        Stage(
          parents: [this],
          elementFilters: [_FinderFilter(finder)],
        ),
      ],
    );
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

  @override
  String get description {
    // ignore: deprecated_member_use
    return finder.description;
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
