import 'package:checks/context.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/element_extensions.dart';

extension EffectiveTextMatcher on WidgetMatcher<Text> {
  WidgetMatcher<Text> hasEffectiveMaxLinesWhere(MatchProp<int?> match) {
    return hasProp(
      selector: (subject) => subject.context.nest<int?>(
        () => ['has "maxLines"'],
        (Element element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match,
    );
  }

  WidgetMatcher<Text> hasEffectiveMaxLines(int? value) {
    return hasEffectiveMaxLinesWhere((it) => it.equals(value));
  }

  WidgetMatcher<Text> hasEffectiveTextStyleWhere(MatchProp<TextStyle> match) {
    return hasProp(
      selector: (subject) => subject.context.nest<TextStyle>(
        () => ['has "textStyle"'],
        (Element element) => Extracted.value(_extractTextStyle(element)),
      ),
      match: match,
    );
  }
}

extension TextStyleSubject on Subject<TextStyle> {
  Subject<double> get fontSize {
    return context.nest(
      () => ['has fontSize'],
      (it) => Extracted.value(it.fontSize ?? 14),
    );
  }

  Subject<FontWeight> get fontWeight {
    return context.nest(
      () => ['has fontWeight'],
      (it) => Extracted.value(it.fontWeight ?? FontWeight.normal),
    );
  }

  Subject<FontStyle> get fontStyle {
    return context.nest(
      () => ['has fontStyle'],
      (it) => Extracted.value(it.fontStyle ?? FontStyle.normal),
    );
  }

  Subject<double> get letterSpacing {
    return context.nest(
      () => ['has letterSpacing'],
      (it) => Extracted.value(it.letterSpacing ?? 0),
    );
  }
}

extension EffectiveTextSelector on WidgetSelector<Text> {
  WidgetSelector<Text> withEffectiveMaxLinesMatching(MatchProp<int?> match) {
    return withProp(
      selector: (subject) => subject.context.nest<int?>(
        () => ['with "maxLines"'],
        (Element element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match,
    );
  }

  WidgetSelector<Text> withEffectiveMaxLines(int? value) {
    return withEffectiveMaxLinesMatching((it) => it.equals(value));
  }
}

int? _extractMaxLines(Element element) {
  element.requireWidgetType<Text>();
  // every Text widget has a RichText child where the effective maxLines are set
  final richTextElement =
      element.children.firstWhere((e) => e.widget is RichText);
  final richText = richTextElement.widget as RichText;
  return richText.maxLines;
}

TextStyle _extractTextStyle(Element element) {
  element.requireWidgetType<Text>();
  // every Text widget has a RichText child where
  final richTextElement =
      element.children.firstWhere((e) => e.widget is RichText);
  final richText = richTextElement.widget as RichText;
  return richText.text.style!;
}

extension on Element {
  void requireWidgetType<W extends Widget>() {
    if (widget is! W) {
      throw 'Require widget of type $W but got ${widget.runtimeType} from Element $this';
    }
  }
}
