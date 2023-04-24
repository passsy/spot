import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

typedef MatchProp<T> = void Function(Subject<T>);

extension WrapMatcher on WidgetMatcher<Wrap> {
  WidgetMatcher<Wrap> hasDirection(MatchProp<Axis> predicate) {
    return hasProp<Axis>('direction', predicate);
  }
}

extension WrapSelector on WidgetSelector<Wrap> {
  WidgetSelector<Wrap> withDirection(MatchProp<Axis> predicate) {
    return withProp2<Axis>('direction', predicate);
  }
}
