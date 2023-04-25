// ignore_for_file: require_trailing_commas

import 'package:checks/checks.dart';
 import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Matchers for [Opacity] auto-generated by spot
///
/// ```dart
/// spot<Opacity>().printMatchers();
/// ```
extension OpacityMatcher on WidgetMatcher<Opacity> {

  WidgetMatcher<Opacity> hasOpacityWhere(MatchProp<double> match) {
    return hasProp<double>('opacity', match);
  }
  
  WidgetMatcher<Opacity> hasOpacity(double value) {
    return hasProp<double>('opacity', (it) => it.equals(value));
  }

  WidgetMatcher<Opacity> hasAlwaysIncludeSemanticsWhere(MatchProp<bool> match) {
    return hasProp<bool>('alwaysIncludeSemantics', match);
  }
  
  WidgetMatcher<Opacity> hasAlwaysIncludeSemantics(bool value) {
    return hasProp<bool>('alwaysIncludeSemantics', (it) => it.equals(value));
  }

  WidgetMatcher<Opacity> hasRenderObjectWhere(MatchProp<RenderOpacity> match) {
    return hasProp<RenderOpacity>('renderObject', match);
  }
  
  WidgetMatcher<Opacity> hasRenderObject(RenderOpacity value) {
    return hasProp<RenderOpacity>('renderObject', (it) => it.equals(value));
  }

}

extension OpacitySelector on WidgetSelector<Opacity> {
  WidgetSelector<Opacity> withOpacityMatching(MatchProp<double> match) {
    return withProp<double>('opacity', match);
  }
  
  WidgetSelector<Opacity> withOpacity(double value) {
    return withProp<double>('opacity', (it) => it.equals(value));
  }

  WidgetSelector<Opacity> withAlwaysIncludeSemanticsMatching(MatchProp<bool> match) {
    return withProp<bool>('alwaysIncludeSemantics', match);
  }
  
  WidgetSelector<Opacity> withAlwaysIncludeSemantics(bool value) {
    return withProp<bool>('alwaysIncludeSemantics', (it) => it.equals(value));
  }

  WidgetSelector<Opacity> withRenderObjectMatching(MatchProp<RenderOpacity> match) {
    return withProp<RenderOpacity>('renderObject', match);
  }
  
  WidgetSelector<Opacity> withRenderObject(RenderOpacity value) {
    return withProp<RenderOpacity>('renderObject', (it) => it.equals(value));
  }

}
    
    