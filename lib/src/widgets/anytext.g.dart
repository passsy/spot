// ignore_for_file: require_trailing_commas
// coverage:ignore-file

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Matchers for [AnyText] auto-generated by spot
///
/// ```dart
/// spot<AnyText>().printMatchers();
/// ```
/// Matchers for the properties of [AnyText] provided via [Diagnosticable.debugFillProperties]
extension AnyTextMatcher on WidgetMatcher<AnyText> {
  /// Expects that text of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasTextWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('text', match);
  }

  /// Expects that text of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasText(String? value) {
    return hasDiagnosticProp<String>(
        'text', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textDirection of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasTextDirectionWhere(MatchProp<TextDirection> match) {
    return hasDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Expects that textDirection of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasTextDirection(TextDirection? value) {
    return hasDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textAlign of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasTextAlignWhere(MatchProp<TextAlign> match) {
    return hasDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Expects that textAlign of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasTextAlign(TextAlign? value) {
    return hasDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that selectionColor of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasSelectionColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('selectionColor', match);
  }

  /// Expects that selectionColor of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasSelectionColor(Color? value) {
    return hasDiagnosticProp<Color>('selectionColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that softWrap of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasSoftWrapWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('softWrap', match);
  }

  /// Expects that softWrap of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasSoftWrap(bool? value) {
    return hasDiagnosticProp<bool>(
        'softWrap', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that overflow of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasOverflowWhere(MatchProp<TextOverflow> match) {
    return hasDiagnosticProp<TextOverflow>('overflow', match);
  }

  /// Expects that overflow of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasOverflow(TextOverflow? value) {
    return hasDiagnosticProp<TextOverflow>(
        'overflow', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that maxLines of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasMaxLinesWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('maxLines', match);
  }

  /// Expects that maxLines of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasMaxLines(int? value) {
    return hasDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that locale of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasLocaleWhere(MatchProp<Locale> match) {
    return hasDiagnosticProp<Locale>('locale', match);
  }

  /// Expects that locale of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasLocale(Locale? value) {
    return hasDiagnosticProp<Locale>(
        'locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that minLines of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasMinLinesWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('minLines', match);
  }

  /// Expects that minLines of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasMinLines(int? value) {
    return hasDiagnosticProp<int>(
        'minLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontInherit of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontInheritWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('font_inherit', match);
  }

  /// Expects that fontInherit of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontInherit(bool? value) {
    return hasDiagnosticProp<bool>(
        'font_inherit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontColor of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('font_color', match);
  }

  /// Expects that fontColor of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'font_color', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontBackgroundColor of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontBackgroundColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('font_backgroundColor', match);
  }

  /// Expects that fontBackgroundColor of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontBackgroundColor(Color? value) {
    return hasDiagnosticProp<Color>('font_backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontFamily of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontFamilyWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('font_family', match);
  }

  /// Expects that fontFamily of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontFamily(String? value) {
    return hasDiagnosticProp<String>(
        'font_family', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontFamilyFallback of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontFamilyFallbackWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('font_familyFallback', match);
  }

  /// Expects that fontFamilyFallback of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontFamilyFallback(String? value) {
    return hasDiagnosticProp<String>('font_familyFallback',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontWeight of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontWeightWhere(MatchProp<FontWeight> match) {
    return hasDiagnosticProp<FontWeight>('font_weight', match);
  }

  /// Expects that fontWeight of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontWeight(FontWeight? value) {
    return hasDiagnosticProp<FontWeight>(
        'font_weight', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontStyle of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontStyleWhere(MatchProp<FontStyle> match) {
    return hasDiagnosticProp<FontStyle>('font_style', match);
  }

  /// Expects that fontStyle of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontStyle(FontStyle? value) {
    return hasDiagnosticProp<FontStyle>(
        'font_style', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontLetterSpacing of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontLetterSpacingWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('font_letterSpacing', match);
  }

  /// Expects that fontLetterSpacing of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontLetterSpacing(double? value) {
    return hasDiagnosticProp<double>('font_letterSpacing',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontWordSpacing of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontWordSpacingWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('font_wordSpacing', match);
  }

  /// Expects that fontWordSpacing of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontWordSpacing(double? value) {
    return hasDiagnosticProp<double>('font_wordSpacing',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontBaseline of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontBaselineWhere(MatchProp<TextBaseline> match) {
    return hasDiagnosticProp<TextBaseline>('font_baseline', match);
  }

  /// Expects that fontBaseline of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontBaseline(TextBaseline? value) {
    return hasDiagnosticProp<TextBaseline>('font_baseline',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontHeight of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontHeightWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('font_height', match);
  }

  /// Expects that fontHeight of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontHeight(double? value) {
    return hasDiagnosticProp<double>(
        'font_height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontLeadingDistribution of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontLeadingDistributionWhere(
      MatchProp<TextLeadingDistribution> match) {
    return hasDiagnosticProp<TextLeadingDistribution>(
        'font_leadingDistribution', match);
  }

  /// Expects that fontLeadingDistribution of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontLeadingDistribution(
      TextLeadingDistribution? value) {
    return hasDiagnosticProp<TextLeadingDistribution>(
        'font_leadingDistribution',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontLocale of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontLocaleWhere(MatchProp<Locale> match) {
    return hasDiagnosticProp<Locale>('font_locale', match);
  }

  /// Expects that fontLocale of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontLocale(Locale? value) {
    return hasDiagnosticProp<Locale>(
        'font_locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontForeground of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontForegroundWhere(MatchProp<Paint> match) {
    return hasDiagnosticProp<Paint>('font_foreground', match);
  }

  /// Expects that fontForeground of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontForeground(Paint? value) {
    return hasDiagnosticProp<Paint>('font_foreground',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontBackground of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontBackgroundWhere(MatchProp<Paint> match) {
    return hasDiagnosticProp<Paint>('font_background', match);
  }

  /// Expects that fontBackground of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontBackground(Paint? value) {
    return hasDiagnosticProp<Paint>('font_background',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that inherit of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasInheritWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('inherit', match);
  }

  /// Expects that inherit of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasInherit(bool? value) {
    return hasDiagnosticProp<bool>(
        'inherit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fontSize of [AnyText] matches the condition in [match]
  WidgetMatcher<AnyText> hasFontSizeWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('font_size', match);
  }

  /// Expects that fontSize of [AnyText] equals (==) [value]
  WidgetMatcher<AnyText> hasFontSize(double? value) {
    return hasDiagnosticProp<double>(
        'font_size', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [AnyText] by the properties provided via [Diagnosticable.debugFillProperties]
extension AnyTextSelector on WidgetSelector<AnyText> {
  /// Creates a [WidgetSelector] that finds all [AnyText] where text matches the condition
  @useResult
  WidgetSelector<AnyText> whereText(MatchProp<String> match) {
    return withDiagnosticProp<String>('text', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where text equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withText(String? value) {
    return withDiagnosticProp<String>(
        'text', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where textDirection matches the condition
  @useResult
  WidgetSelector<AnyText> whereTextDirection(MatchProp<TextDirection> match) {
    return withDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where textDirection equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withTextDirection(TextDirection? value) {
    return withDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where textAlign matches the condition
  @useResult
  WidgetSelector<AnyText> whereTextAlign(MatchProp<TextAlign> match) {
    return withDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where textAlign equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withTextAlign(TextAlign? value) {
    return withDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where selectionColor matches the condition
  @useResult
  WidgetSelector<AnyText> whereSelectionColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('selectionColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where selectionColor equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withSelectionColor(Color? value) {
    return withDiagnosticProp<Color>('selectionColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where softWrap matches the condition
  @useResult
  WidgetSelector<AnyText> whereSoftWrap(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('softWrap', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where softWrap equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withSoftWrap(bool? value) {
    return withDiagnosticProp<bool>(
        'softWrap', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where overflow matches the condition
  @useResult
  WidgetSelector<AnyText> whereOverflow(MatchProp<TextOverflow> match) {
    return withDiagnosticProp<TextOverflow>('overflow', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where overflow equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withOverflow(TextOverflow? value) {
    return withDiagnosticProp<TextOverflow>(
        'overflow', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where maxLines matches the condition
  @useResult
  WidgetSelector<AnyText> whereMaxLines(MatchProp<int> match) {
    return withDiagnosticProp<int>('maxLines', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where maxLines equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withMaxLines(int? value) {
    return withDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where locale matches the condition
  @useResult
  WidgetSelector<AnyText> whereLocale(MatchProp<Locale> match) {
    return withDiagnosticProp<Locale>('locale', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where locale equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withLocale(Locale? value) {
    return withDiagnosticProp<Locale>(
        'locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where minLines matches the condition
  @useResult
  WidgetSelector<AnyText> whereMinLines(MatchProp<int> match) {
    return withDiagnosticProp<int>('minLines', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where minLines equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withMinLines(int? value) {
    return withDiagnosticProp<int>(
        'minLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontInherit matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontInherit(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('font_inherit', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontInherit equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontInherit(bool? value) {
    return withDiagnosticProp<bool>(
        'font_inherit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontColor matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('font_color', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontColor equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontColor(Color? value) {
    return withDiagnosticProp<Color>(
        'font_color', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBackgroundColor matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontBackgroundColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('font_backgroundColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBackgroundColor equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontBackgroundColor(Color? value) {
    return withDiagnosticProp<Color>('font_backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontFamily matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontFamily(MatchProp<String> match) {
    return withDiagnosticProp<String>('font_family', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontFamily equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontFamily(String? value) {
    return withDiagnosticProp<String>(
        'font_family', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontFamilyFallback matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontFamilyFallback(MatchProp<String> match) {
    return withDiagnosticProp<String>('font_familyFallback', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontFamilyFallback equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontFamilyFallback(String? value) {
    return withDiagnosticProp<String>('font_familyFallback',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontWeight matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontWeight(MatchProp<FontWeight> match) {
    return withDiagnosticProp<FontWeight>('font_weight', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontWeight equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontWeight(FontWeight? value) {
    return withDiagnosticProp<FontWeight>(
        'font_weight', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontStyle matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontStyle(MatchProp<FontStyle> match) {
    return withDiagnosticProp<FontStyle>('font_style', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontStyle equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontStyle(FontStyle? value) {
    return withDiagnosticProp<FontStyle>(
        'font_style', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLetterSpacing matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontLetterSpacing(MatchProp<double> match) {
    return withDiagnosticProp<double>('font_letterSpacing', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLetterSpacing equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontLetterSpacing(double? value) {
    return withDiagnosticProp<double>('font_letterSpacing',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontWordSpacing matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontWordSpacing(MatchProp<double> match) {
    return withDiagnosticProp<double>('font_wordSpacing', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontWordSpacing equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontWordSpacing(double? value) {
    return withDiagnosticProp<double>('font_wordSpacing',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBaseline matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontBaseline(MatchProp<TextBaseline> match) {
    return withDiagnosticProp<TextBaseline>('font_baseline', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBaseline equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontBaseline(TextBaseline? value) {
    return withDiagnosticProp<TextBaseline>('font_baseline',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontHeight matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontHeight(MatchProp<double> match) {
    return withDiagnosticProp<double>('font_height', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontHeight equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontHeight(double? value) {
    return withDiagnosticProp<double>(
        'font_height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLeadingDistribution matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontLeadingDistribution(
      MatchProp<TextLeadingDistribution> match) {
    return withDiagnosticProp<TextLeadingDistribution>(
        'font_leadingDistribution', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLeadingDistribution equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontLeadingDistribution(
      TextLeadingDistribution? value) {
    return withDiagnosticProp<TextLeadingDistribution>(
        'font_leadingDistribution',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLocale matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontLocale(MatchProp<Locale> match) {
    return withDiagnosticProp<Locale>('font_locale', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontLocale equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontLocale(Locale? value) {
    return withDiagnosticProp<Locale>(
        'font_locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontForeground matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontForeground(MatchProp<Paint> match) {
    return withDiagnosticProp<Paint>('font_foreground', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontForeground equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontForeground(Paint? value) {
    return withDiagnosticProp<Paint>('font_foreground',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBackground matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontBackground(MatchProp<Paint> match) {
    return withDiagnosticProp<Paint>('font_background', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontBackground equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontBackground(Paint? value) {
    return withDiagnosticProp<Paint>('font_background',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where inherit matches the condition
  @useResult
  WidgetSelector<AnyText> whereInherit(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('inherit', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where inherit equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withInherit(bool? value) {
    return withDiagnosticProp<bool>(
        'inherit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontSize matches the condition
  @useResult
  WidgetSelector<AnyText> whereFontSize(MatchProp<double> match) {
    return withDiagnosticProp<double>('font_size', match);
  }

  /// Creates a [WidgetSelector] that finds all [AnyText] where fontSize equals (==) [value]
  @useResult
  WidgetSelector<AnyText> withFontSize(double? value) {
    return withDiagnosticProp<double>(
        'font_size', (it) => value == null ? it.isNull() : it.equals(value));
  }
}
