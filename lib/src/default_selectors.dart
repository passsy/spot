import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

extension DefaultWidgetMatchers<W extends Widget> on WidgetMatcher<W> {
  WidgetMatcher<W> hasDepthWhere(MatchProp<int> match) {
    return hasProp<int>('depth', match);
  }

  WidgetMatcher<W> hasDepth(int value) {
    return hasProp<int>('depth', (it) => it.equals(value));
  }

  WidgetMatcher<W> hasKeyWhere(MatchProp<Key> match) {
    return hasProp<Key>('key', match);
  }

  WidgetMatcher<W> hasKey(Key? value) {
    return hasProp<Key>(
      'key',
      (it) => value == null ? it.isNull() : it.equals(value),
    );
  }
}

extension DefaultWidgetSelectors<W extends Widget> on WidgetSelector<W> {
  WidgetSelector<W> whereDepth(MatchProp<int> match) {
    return withProp<int>('depth', match);
  }

  WidgetSelector<W> withDepth(int value) {
    return withProp<int>('depth', (it) => it.equals(value));
  }

  WidgetSelector<W> whereKey(MatchProp<Key> match) {
    return withProp<Key>('key', match);
  }

  WidgetSelector<W> withKey(Key? value) {
    return withProp<Key>(
      'key',
      (it) => value == null ? it.isNull() : it.equals(value),
    );
  }
}
