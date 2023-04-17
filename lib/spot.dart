library spot;

import 'package:spot/spot.dart';

export 'package:spot/src/snapshot.dart';
export 'package:spot/src/spotters.dart';

/// Creates a widget/element selectors that search the widget and element tree
/// for matching elements.
///
/// Spots [WidgetSelector] are chainable to quickly narrow down the candidates
/// for fast assertions.
///
/// Similar to [find] from `package:flutter_test`, but with a more fluent API.
final Spot spot = Spot();
