import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/element_extensions.dart';
import 'package:spot/src/spot/selectors.dart';

/// Matchers for the [Text] widget like
/// [hasMaxLines], [hasTextStyle], [hasText].
extension EffectiveTextMatcher on WidgetMatcher<Text> {
  /// Matches the [Text] widget when it has the given [maxLines].
  ///
  /// ```dart
  /// spot<Text>().withText('foo').existsOnce()
  ///   .hasEffectiveMaxLinesWhere((it) => it.equals(1));
  /// ```
  WidgetMatcher<Text> hasEffectiveMaxLinesWhere(MatchProp<int> match) {
    return hasProp(
      elementSelector: (subject) => subject.context.nest<int?>(
        () => ['has "maxLines"'],
        (Element element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match.hideNullability(),
    );
  }

  /// Matches the [Text] widget against given [maxLines].
  WidgetMatcher<Text> hasEffectiveMaxLines(int? value) {
    return hasEffectiveMaxLinesWhere((it) {
      if (value == null) {
        it.isNull();
      } else {
        it.equals(value);
      }
    });
  }

  /// Matches the [Text] widget's [TextStyle] properties.
  WidgetMatcher<Text> hasEffectiveTextStyleWhere(MatchProp<TextStyle> match) {
    return hasProp(
      elementSelector: (subject) => subject.context.nest<TextStyle?>(
        () => ['has "textStyle"'],
        (Element element) => Extracted.value(_extractTextStyle(element)),
      ),
      match: match.hideNullability(),
    );
  }

  /// Matches the style of a [Text] against a given [TextStyle].
  WidgetMatcher<Text> hasEffectiveTextStyle(TextStyle? value) {
    return hasEffectiveTextStyleWhere((it) {
      if (value == null) {
        it.isNull();
      } else {
        it.equals(value);
      }
    });
  }
}

/// Allows accessing various properties of [TextStyle].
extension TextStyleSubject on Subject<TextStyle> {
  /// A [Subject<double>] representing the `fontSize` of the [TextStyle].
  /// If the `fontSize` is not explicitly set, it defaults to 14.
  Subject<double> get fontSize {
    return context.nest(
      () => ['has fontSize'],
      (it) => Extracted.value(it.fontSize ?? 14),
    );
  }

  /// A [Subject<FontWeight>] representing the `fontWeight`
  /// of the [TextStyle]. If the `fontWeight` is not
  /// explicitly set, it defaults to [FontWeight.normal].
  Subject<FontWeight> get fontWeight {
    return context.nest(
      () => ['has fontWeight'],
      (it) => Extracted.value(it.fontWeight ?? FontWeight.normal),
    );
  }

  /// A [Subject<FontStyle>] representing the `fontStyle`
  /// of the [TextStyle]. If the `fontStyle` is not explicitly set,
  /// it defaults to [FontStyle.normal].
  Subject<FontStyle> get fontStyle {
    return context.nest(
      () => ['has fontStyle'],
      (it) => Extracted.value(it.fontStyle ?? FontStyle.normal),
    );
  }

  /// Gets a [Subject<double>] representing the `letterSpacing`
  /// of the [TextStyle]. If the `letterSpacing` is not explicitly set,
  /// it defaults to 0.
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
      elementSelector: (subject) => subject.context.nest<int?>(
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
