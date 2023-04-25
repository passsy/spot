// ignore_for_file: require_trailing_commas

import 'package:checks/checks.dart';
 import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Matchers for [Wrap] auto-generated by spot
///
/// ```dart
/// spot<Wrap>().printMatchers();
/// ```
extension WrapMatcher on WidgetMatcher<Wrap> {

  WidgetMatcher<Wrap> hasDirectionWhere(MatchProp<Axis> match) {
    return hasProp<Axis>('direction', match);
  }
  
  WidgetMatcher<Wrap> hasDirection(Axis value) {
    return hasProp<Axis>('direction', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasAlignmentWhere(MatchProp<WrapAlignment> match) {
    return hasProp<WrapAlignment>('alignment', match);
  }
  
  WidgetMatcher<Wrap> hasAlignment(WrapAlignment value) {
    return hasProp<WrapAlignment>('alignment', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasSpacingWhere(MatchProp<double> match) {
    return hasProp<double>('spacing', match);
  }
  
  WidgetMatcher<Wrap> hasSpacing(double value) {
    return hasProp<double>('spacing', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasRunAlignmentWhere(MatchProp<WrapAlignment> match) {
    return hasProp<WrapAlignment>('runAlignment', match);
  }
  
  WidgetMatcher<Wrap> hasRunAlignment(WrapAlignment value) {
    return hasProp<WrapAlignment>('runAlignment', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasRunSpacingWhere(MatchProp<double> match) {
    return hasProp<double>('runSpacing', match);
  }
  
  WidgetMatcher<Wrap> hasRunSpacing(double value) {
    return hasProp<double>('runSpacing', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasCrossAxisAlignmentWhere(MatchProp<WrapCrossAlignment> match) {
    return hasProp<WrapCrossAlignment>('crossAxisAlignment', match);
  }
  
  WidgetMatcher<Wrap> hasCrossAxisAlignment(WrapCrossAlignment value) {
    return hasProp<WrapCrossAlignment>('crossAxisAlignment', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasTextDirectionWhere(MatchProp<TextDirection> match) {
    return hasProp<TextDirection>('textDirection', match);
  }
  
  WidgetMatcher<Wrap> hasTextDirection(TextDirection value) {
    return hasProp<TextDirection>('textDirection', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasVerticalDirectionWhere(MatchProp<VerticalDirection> match) {
    return hasProp<VerticalDirection>('verticalDirection', match);
  }
  
  WidgetMatcher<Wrap> hasVerticalDirection(VerticalDirection value) {
    return hasProp<VerticalDirection>('verticalDirection', (it) => it.equals(value));
  }

  WidgetMatcher<Wrap> hasRenderObjectWhere(MatchProp<RenderWrap> match) {
    return hasProp<RenderWrap>('renderObject', match);
  }
  
  WidgetMatcher<Wrap> hasRenderObject(RenderWrap value) {
    return hasProp<RenderWrap>('renderObject', (it) => it.equals(value));
  }

}

extension WrapSelector on WidgetSelector<Wrap> {
  WidgetSelector<Wrap> withDirectionMatching(MatchProp<Axis> match) {
    return withProp<Axis>('direction', match);
  }
  
  WidgetSelector<Wrap> withDirection(Axis value) {
    return withProp<Axis>('direction', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withAlignmentMatching(MatchProp<WrapAlignment> match) {
    return withProp<WrapAlignment>('alignment', match);
  }
  
  WidgetSelector<Wrap> withAlignment(WrapAlignment value) {
    return withProp<WrapAlignment>('alignment', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withSpacingMatching(MatchProp<double> match) {
    return withProp<double>('spacing', match);
  }
  
  WidgetSelector<Wrap> withSpacing(double value) {
    return withProp<double>('spacing', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withRunAlignmentMatching(MatchProp<WrapAlignment> match) {
    return withProp<WrapAlignment>('runAlignment', match);
  }
  
  WidgetSelector<Wrap> withRunAlignment(WrapAlignment value) {
    return withProp<WrapAlignment>('runAlignment', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withRunSpacingMatching(MatchProp<double> match) {
    return withProp<double>('runSpacing', match);
  }
  
  WidgetSelector<Wrap> withRunSpacing(double value) {
    return withProp<double>('runSpacing', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withCrossAxisAlignmentMatching(MatchProp<WrapCrossAlignment> match) {
    return withProp<WrapCrossAlignment>('crossAxisAlignment', match);
  }
  
  WidgetSelector<Wrap> withCrossAxisAlignment(WrapCrossAlignment value) {
    return withProp<WrapCrossAlignment>('crossAxisAlignment', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withTextDirectionMatching(MatchProp<TextDirection> match) {
    return withProp<TextDirection>('textDirection', match);
  }
  
  WidgetSelector<Wrap> withTextDirection(TextDirection value) {
    return withProp<TextDirection>('textDirection', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withVerticalDirectionMatching(MatchProp<VerticalDirection> match) {
    return withProp<VerticalDirection>('verticalDirection', match);
  }
  
  WidgetSelector<Wrap> withVerticalDirection(VerticalDirection value) {
    return withProp<VerticalDirection>('verticalDirection', (it) => it.equals(value));
  }

  WidgetSelector<Wrap> withRenderObjectMatching(MatchProp<RenderWrap> match) {
    return withProp<RenderWrap>('renderObject', match);
  }
  
  WidgetSelector<Wrap> withRenderObject(RenderWrap value) {
    return withProp<RenderWrap>('renderObject', (it) => it.equals(value));
  }

}
    
    