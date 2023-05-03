// ignore_for_file: require_trailing_commas

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/src/checks.dart';
import 'package:spot/src/element_extensions.dart';

extension EffectiveTextMatcher on WidgetMatcher<Text> {
  WidgetMatcher<Text> hasEffectiveMaxLinesWhere(MatchProp<int?> match) {
    return hasProp(
      match,
      (subject) => subject.context.nest<int?>(
        () => ['with prop "maxLines"'],
        (Element element) => Extracted.value(_maxLinesFromText(element)),
      ),
    );
  }

  WidgetMatcher<Text> hasEffectiveMaxLines(int? value) {
    return hasEffectiveMaxLinesWhere((it) => it.equals(value));
  }
}

extension EffectiveTextSelector on WidgetSelector<Text> {
  WidgetSelector<Text> withEffectiveMaxLinesMatching(MatchProp<int?> match) {
    return withProp(
      match,
      (subject) => subject.context.nest<int?>(
        () => ['with prop "maxLines"'],
        (Element element) => Extracted.value(_maxLinesFromText(element)),
      ),
    );
  }

  WidgetSelector<Text> withEffectiveMaxLines(int? value) {
    return withEffectiveMaxLinesMatching((it) => it.equals(value));
  }
}

int? _maxLinesFromText(Element element) {
  element.requireWidgetType<Text>();
  final richTextElement =
      element.children.firstWhere((e) => e.widget is RichText);
  final richText = richTextElement.widget as RichText;
  return richText.maxLines;
}

extension on Element {
  void requireWidgetType<W extends Widget>() {
    if (widget is! W) {
      throw 'Require widget of type $W but got ${widget.runtimeType} from Element $this';
    }
  }
}
