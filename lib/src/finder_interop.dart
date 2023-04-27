import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

extension FinderToSpot on Finder {
  MultiWidgetSelector<W> spot<W extends Widget>() {
    return _FinderSelector<W>(this);
  }
}

extension SpotToFinder<W extends Widget> on WidgetSelector<W> {
  Finder get finder => _FinderFromWidgetSelector(this);

  WidgetSelector<T> spotFinder<T extends Widget>(Finder finder) {
    return _FinderSelector<T>(finder, parent: this);
  }
}

class _FinderSelector<W extends Widget> extends MultiWidgetSelector<W> {
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
    return 'widget with ${finder.description}'
        '${overridden.isNotEmpty ? ' $overridden' : ''}';
  }

  @override
  String toStringWithoutParents() {
    final overridden = super.toStringWithoutParents();
    return 'widget with ${finder.description}'
        '${overridden.isNotEmpty ? ' $overridden' : ''}';
  }
}

class _FinderFilter extends ElementFilter {
  final Finder finder;

  _FinderFilter(this.finder);

  @override
  Iterable<SpotNode<Widget>> filter(Iterable<SpotNode<Widget>> candidates) {
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
