import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

extension SpotFinder on Finder {
  WidgetSelector get spot {
    final elements = evaluate();

    return allWidgets.whereElement(
      (e) => elements.contains(e),
      description: 'Finder $description',
    );
  }
}
