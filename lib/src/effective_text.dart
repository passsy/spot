// ignore_for_file: require_trailing_commas

import 'package:checks/checks.dart';
import 'package:checks/context.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// Matchers for [Text] auto-generated by spot
///
/// ```dart
/// spot<Text>().printMatchers(propNameOverrides: (MapEntry('data': 'text')));
/// ```
extension EffectiveTextMatcher on WidgetMatcher<Text> {
  WidgetMatcher<Text> hasEffectiveMaxLinesWhere(MatchProp<int> match) {
    return hasProp<int>('maxLines', match);
  }

  WidgetMatcher<Text> hasEffectiveMaxLines(int? value) {
    final richTextElement =
        element.children.firstWhere((e) => e.widget is RichText);
    final richText = richTextElement.widget as RichText;
    final actual = richText.maxLines;

    final ConditionSubject<int?> conditionSubject = it<int?>();
    final Subject<int?> subject = conditionSubject.context.nest<int?>(
      () => ['with prop "maxLines"'],
      (value) => Extracted.value(actual),
    );
    subject.equals(value);
    final failure = softCheck(actual, conditionSubject);
    if (failure != null) {
      final errorMessage =
          describe(conditionSubject).map((it) => it.trim()).toList().join(' ');
      throw TestFailure(
        'Failed to match widget: $errorMessage, actual: ${literal(actual).joinToString()}',
      );
    }
    return this;
  }
}

extension EffectiveTextSelector on WidgetSelector<Text> {
  WidgetSelector<Text> withEffectiveMaxLinesMatching(MatchProp<int> match) {
    return withProp<int>('maxLines', match);
  }

  WidgetSelector<Text> withEffectiveMaxLines(int value) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<int?> subject = conditionSubject.context.nest<int?>(
      () => ['with prop "maxLines"'],
      (Element element) {
        final richTextElement =
            element.children.firstWhere((e) => e.widget is RichText);
        final richText = richTextElement.widget as RichText;
        return Extracted.value(richText.maxLines);
      },
    );
    subject.equals(value);
    final name =
        describe(conditionSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final failure = softCheck(element, conditionSubject);
        return failure == null;
      },
      description: name,
    );
  }
}