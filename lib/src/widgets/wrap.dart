import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

extension WrapMatcher on WidgetMatcher<Wrap> {
  WidgetMatcher<Wrap> hasDirection(Axis direction) {
    // TODO make this work
    // return withProp<Axis>('direction',
    //       (axis) => axis == direction,
    //   description: 'direction: $direction',
    // );
    return this;
  }
}

extension WrapSelector on WidgetSelector<Wrap> {
  WidgetSelector<Wrap> withDirection(Axis direction) {
    return withProp<Axis>(
      'direction',
      (axis) => axis == direction,
      description: 'direction: $direction',
    );
  }
}
