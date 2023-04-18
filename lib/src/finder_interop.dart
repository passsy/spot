import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

extension FinderToSpot on Finder {
  WidgetSelector get spot {
    final elements = evaluate();

    return allWidgets.whereElement(
      (e) => elements.contains(e),
      description: 'Finder $description',
    );
  }
}

extension SpotToFinder<W extends Widget> on WidgetSelector<W> {
  Finder get finder => FinderFromWidgetSelector(this);

  WidgetSelector<W> spotFinder(Finder finder) {
    return WidgetSelector<W>(
      props: [
        PredicateWithDescription(
          (element) {
            // TODO This executes the finder on each element, there should be a better way
            return finder.apply([element]).isNotEmpty;
          },
          description: 'Spot from Finder $finder',
        ),
      ],
      parents: [self],
    );
  }
}

class FinderFromWidgetSelector extends Finder {
  final WidgetSelector selector;

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final found = selector.snapshot().discovered.map((it) => it.value);
    return candidates.where((element) => found.contains(element));
  }

  @override
  String get description => 'Finder from $selector';

  FinderFromWidgetSelector(this.selector);
}
