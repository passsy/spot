// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart';

extension DefaultWidgetMatchers<W extends Widget> on WidgetMatcher<W> {
  WidgetMatcher<W> hasDepthWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('depth', match);
  }

  WidgetMatcher<W> hasDepth(int value) {
    return hasDiagnosticProp<int>('depth', (it) => it.equals(value));
  }

  WidgetMatcher<W> hasKeyWhere(MatchProp<Key> match) {
    return hasProp(
      widgetSelector: (subject) => subject.context.nest<Key?>(
        () => ['has key'],
        (W widget) => Extracted.value(widget.key),
      ),
      match: match.hideNullability(),
    );
  }

  WidgetMatcher<W> hasKey(Key? value) {
    return hasKeyWhere((it) => value == null ? it.isNull() : it.equals(value));
  }
}

extension DefaultWidgetSelectors<W extends Widget> on WidgetSelector<W> {
  WidgetSelector<W> whereDepth(MatchProp<int> match) {
    return withDiagnosticProp<int>('depth', match);
  }

  WidgetSelector<W> withDepth(int value) {
    return withDiagnosticProp<int>('depth', (it) => it.equals(value));
  }

  WidgetSelector<W> whereKey(MatchProp<Key> match) {
    return withProp(
      widgetSelector: (subject) => subject.context.nest<Key?>(
        () => ['has key'],
        (W widget) => Extracted.value(widget.key),
      ),
      match: match.hideNullability(),
    );
  }

  WidgetSelector<W> withKey(Key? value) {
    return whereKey((it) => value == null ? it.isNull() : it.equals(value));
  }
}
