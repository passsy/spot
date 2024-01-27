import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/element_extensions.dart';

/// Matchers for the [Text] widget to make assertions about:
/// - [Text.maxLines]
/// - [Text.style]
extension EffectiveTextMatcher on WidgetMatcher<Text> {
  /// A [WidgetMatcher] for [Text] widgets that performs specific assertions by
  /// applying a custom matcher function to the `maxLines` property.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withText('foo').existsOnce()
  ///   .hasEffectiveMaxLinesWhere((it) => it.isNotNull().isGreaterThan(1));
  /// ```
  /// #### See also:
  /// - [hasEffectiveMaxLines], for matching [Text] widgets by performing a
  ///   singular assertion against a fixed `maxLines` value.
  WidgetMatcher<Text> hasEffectiveMaxLinesWhere(MatchProp<int> match) {
    return hasProp(
      elementSelector: (subject) => subject.context.nest<int?>(
        () => ['has "maxLines"'],
        (Element element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match.hideNullability(),
    );
  }

  /// A [WidgetMatcher] for [Text] widgets that performs a singular assertion
  /// against a fixed `maxLines` value.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withText('foo').existsOnce()
  ///   .hasEffectiveMaxLines(1);
  /// ```
  ///
  /// #### See also:
  /// - [hasEffectiveMaxLinesWhere], a matcher that performs specific assertions
  /// by applying a custom matcher function to the `maxLines` property.
  WidgetMatcher<Text> hasEffectiveMaxLines(int? value) {
    return hasEffectiveMaxLinesWhere((it) {
      if (value == null) {
        it.isNull();
      } else {
        it.equals(value);
      }
    });
  }

  /// A [WidgetMatcher] for [Text] widgets that performs specific assertions by
  /// applying a custom matcher function to [TextStyle] properties.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withText('foo').existsOnce()
  ///   .hasEffectiveTextStyleWhere(
  ///             (style) => style
  ///               ..fontSize.isGreaterOrEqual(14)
  ///               ..letterSpacing.isNotNull()
  ///               ..fontStyle.equals(FontStyle.italic),
  ///           );
  /// ```
  /// #### See also:
  /// - [hasEffectiveTextStyle], for matching [Text] widgets by performing a
  ///   singular assertion against a fixed [TextStyle] value.
  WidgetMatcher<Text> hasEffectiveTextStyleWhere(MatchProp<TextStyle> match) {
    return hasProp(
      elementSelector: (subject) => subject.context.nest<TextStyle?>(
        () => ['has "textStyle"'],
        (Element element) => Extracted.value(_extractTextStyle(element)),
      ),
      match: match.hideNullability(),
    );
  }

  /// A [WidgetMatcher] for [Text] widgets that performs a singular assertion
  /// against a fixed [TextStyle] value.
  ///
  /// #### Example:
  /// ```dart
  /// final style = TextStyle(
  ///   fontSize: 20,
  ///   fontStyle: FontStyle.italic,
  ///   fontWeight: FontWeight.bold,
  ///   letterSpacing: 2,
  /// );
  /// spot<Text>().withText('foo').existsOnce().hasEffectiveTextStyle(style);
  /// ```
  /// #### See also:
  /// - [hasEffectiveTextStyleWhere], a matcher that performs specific
  ///   assertions by applying a custom matcher function to [TextStyle]
  ///   properties.
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

/// Selectors for the [Text] widget based on properties like
/// - [Text.maxLines]
/// - [Text.style]
extension EffectiveTextSelector on WidgetSelector<Text> {
  /// A [WidgetSelector] for [Text] widgets that meet specified `maxLines`
  /// conditions, as defined by a custom matcher function.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withEffectiveMaxLinesMatching(
  ///             (it) => it.isNotNull().isGreaterThan(1)).existsOnce();
  /// ```
  ///
  /// #### See also:
  /// - [withEffectiveMaxLines], for selecting [Text] widgets that have a fixed
  ///   `maxLines` value.
  WidgetSelector<Text> withEffectiveMaxLinesMatching(MatchProp<int?> match) {
    return withProp(
      elementSelector: (subject) => subject.context.nest<int?>(
        () => ['with "maxLines"'],
        (Element element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match,
    );
  }

  /// A [WidgetSelector] for [Text] widgets with a fixed `maxLines` value.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withEffectiveMaxLines(2).existsOnce();
  /// ```
  ///
  /// #### See also:
  /// - [withEffectiveMaxLinesMatching], for selecting [Text] widgets that meet
  ///   specified `maxLines` conditions, as defined by a custom matcher
  ///   function.
  WidgetSelector<Text> withEffectiveMaxLines(int? value) {
    return withEffectiveMaxLinesMatching((it) => it.equals(value));
  }

  /// A [WidgetSelector] for [Text] widgets that meet specified [TextStyle]
  /// conditions, as defined by a custom matcher function.
  ///
  /// #### Example:
  /// ```dart
  /// spot<Text>().withText('foo').withEffectiveTextStyleMatching(
  ///   (style) {
  ///     style.fontSize.isGreaterOrEqual(20);
  ///     style.fontStyle.isNotNull();
  ///     style.fontWeight.equals(FontWeight.bold);
  ///   },
  /// ).existsOnce();
  /// ```
  ///
  /// #### See also:
  /// - [withEffectiveTextStyle], for selecting [Text] widgets widgets that have
  ///   a fixed [TextStyle] value.
  WidgetSelector<Text> withEffectiveTextStyleMatching(
    MatchProp<TextStyle> match,
  ) {
    return withProp(
      elementSelector: (subject) => subject.context.nest<TextStyle>(
        () => ['with "textStyle"'],
        (Element element) => Extracted.value(_extractTextStyle(element)),
      ),
      match: match,
    );
  }

  /// A [WidgetSelector] for [Text] widgets widgets that have a fixed
  /// [TextStyle] value.
  ///
  /// #### Example:
  /// ```dart
  /// final style = TextStyle(
  ///  fontSize: 20,
  ///  fontStyle: FontStyle.italic,
  ///  fontWeight: FontWeight.bold,
  ///  letterSpacing: 2,
  /// );
  /// spot<Text>().withText('foo').withEffectiveTextStyle(style).existsOnce();
  /// ```
  ///
  /// #### See also:
  /// - [withEffectiveTextStyleMatching], for selecting [Text] widgets that meet
  ///   specified [TextStyle] conditions, as defined by a custom matcher
  ///   function.
  WidgetSelector<Text> withEffectiveTextStyle(TextStyle? value) {
    return withEffectiveTextStyleMatching((it) {
      if (value == null) {
        it.isNull();
      } else {
        it.equals(value);
      }
    });
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
