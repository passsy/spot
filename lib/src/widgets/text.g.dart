// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [Text] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<Text>().printMatchers(propNameOverrides: {'data': 'text'});
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Allows filtering [Text] by the properties provided via [Diagnosticable.debugFillProperties]
extension TextSelector on WidgetSelector<Text> {
  /// Creates a [WidgetSelector] that finds all [Text] where text matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereText((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereText(MatchProp<String> match) {
    return withDiagnosticProp<String>('data', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where text equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withText('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withText(String? value) {
    return withDiagnosticProp<String>(
        'data', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textAlign matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereTextAlign((it) => it.equals(TextAlign.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereTextAlign(MatchProp<TextAlign> match) {
    return withDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textAlign equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withTextAlign(TextAlign.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withTextAlign(TextAlign? value) {
    return withDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textDirection matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereTextDirection((it) => it.equals(TextDirection.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereTextDirection(MatchProp<TextDirection> match) {
    return withDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textDirection equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withTextDirection(TextDirection.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withTextDirection(TextDirection? value) {
    return withDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where locale matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereLocale((it) => it.equals(Locale('en', 'US'))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereLocale(MatchProp<Locale> match) {
    return withDiagnosticProp<Locale>('locale', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where locale equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withLocale(Locale('en', 'US')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withLocale(Locale? value) {
    return withDiagnosticProp<Locale>(
        'locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where softWrap matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereSoftWrap((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereSoftWrap(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('softWrap', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where softWrap equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withSoftWrap(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withSoftWrap(bool? value) {
    return withDiagnosticProp<bool>(
        'softWrap', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where overflow matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereOverflow((it) => it.equals(TextOverflow.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereOverflow(MatchProp<TextOverflow> match) {
    return withDiagnosticProp<TextOverflow>('overflow', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where overflow equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withOverflow(TextOverflow.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withOverflow(TextOverflow? value) {
    return withDiagnosticProp<TextOverflow>(
        'overflow', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textScaleFactor matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereTextScaleFactor((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereTextScaleFactor(MatchProp<double> match) {
    return withDiagnosticProp<double>('textScaleFactor', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textScaleFactor equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withTextScaleFactor(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withTextScaleFactor(double? value) {
    return withDiagnosticProp<double>('textScaleFactor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where maxLines matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereMaxLines((it) => it.isGreaterThan(10)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereMaxLines(MatchProp<int> match) {
    return withDiagnosticProp<int>('maxLines', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where maxLines equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withMaxLines(10).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withMaxLines(int? value) {
    return withDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textWidthBasis matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereTextWidthBasis((it) => it.equals(TextWidthBasis.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereTextWidthBasis(MatchProp<TextWidthBasis> match) {
    return withDiagnosticProp<TextWidthBasis>('textWidthBasis', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textWidthBasis equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withTextWidthBasis(TextWidthBasis.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withTextWidthBasis(TextWidthBasis? value) {
    return withDiagnosticProp<TextWidthBasis>('textWidthBasis',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textHeightBehavior matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().whereTextHeightBehavior((it) => it.equals(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> whereTextHeightBehavior(
      MatchProp<TextHeightBehavior> match) {
    return withDiagnosticProp<TextHeightBehavior>('textHeightBehavior', match);
  }

  /// Creates a [WidgetSelector] that finds all [Text] where textHeightBehavior equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().withTextHeightBehavior(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Text> withTextHeightBehavior(TextHeightBehavior? value) {
    return withDiagnosticProp<TextHeightBehavior>('textHeightBehavior',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [Text] provided via [Diagnosticable.debugFillProperties]
extension TextMatcher on WidgetMatcher<Text> {
  /// Expects that text of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Text> hasTextWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('data', match);
  }

  /// Expects that text of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasText('foo');
  /// ```
  WidgetMatcher<Text> hasText(String? value) {
    return hasDiagnosticProp<String>(
        'data', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textAlign of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextAlignWhere((it) => it.equals(TextAlign.values.first));
  /// ```
  WidgetMatcher<Text> hasTextAlignWhere(MatchProp<TextAlign> match) {
    return hasDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Expects that textAlign of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextAlign(TextAlign.values.first);
  /// ```
  WidgetMatcher<Text> hasTextAlign(TextAlign? value) {
    return hasDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textDirection of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextDirectionWhere((it) => it.equals(TextDirection.values.first));
  /// ```
  WidgetMatcher<Text> hasTextDirectionWhere(MatchProp<TextDirection> match) {
    return hasDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Expects that textDirection of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextDirection(TextDirection.values.first);
  /// ```
  WidgetMatcher<Text> hasTextDirection(TextDirection? value) {
    return hasDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that locale of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasLocaleWhere((it) => it.equals(Locale('en', 'US')));
  /// ```
  WidgetMatcher<Text> hasLocaleWhere(MatchProp<Locale> match) {
    return hasDiagnosticProp<Locale>('locale', match);
  }

  /// Expects that locale of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasLocale(Locale('en', 'US'));
  /// ```
  WidgetMatcher<Text> hasLocale(Locale? value) {
    return hasDiagnosticProp<Locale>(
        'locale', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that softWrap of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasSoftWrapWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Text> hasSoftWrapWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('softWrap', match);
  }

  /// Expects that softWrap of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasSoftWrap(true);
  /// ```
  WidgetMatcher<Text> hasSoftWrap(bool? value) {
    return hasDiagnosticProp<bool>(
        'softWrap', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that overflow of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasOverflowWhere((it) => it.equals(TextOverflow.values.first));
  /// ```
  WidgetMatcher<Text> hasOverflowWhere(MatchProp<TextOverflow> match) {
    return hasDiagnosticProp<TextOverflow>('overflow', match);
  }

  /// Expects that overflow of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasOverflow(TextOverflow.values.first);
  /// ```
  WidgetMatcher<Text> hasOverflow(TextOverflow? value) {
    return hasDiagnosticProp<TextOverflow>(
        'overflow', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textScaleFactor of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextScaleFactorWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<Text> hasTextScaleFactorWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('textScaleFactor', match);
  }

  /// Expects that textScaleFactor of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextScaleFactor(10.5);
  /// ```
  WidgetMatcher<Text> hasTextScaleFactor(double? value) {
    return hasDiagnosticProp<double>('textScaleFactor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that maxLines of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasMaxLinesWhere((it) => it.isGreaterThan(10));
  /// ```
  WidgetMatcher<Text> hasMaxLinesWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('maxLines', match);
  }

  /// Expects that maxLines of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasMaxLines(10);
  /// ```
  WidgetMatcher<Text> hasMaxLines(int? value) {
    return hasDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textWidthBasis of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextWidthBasisWhere((it) => it.equals(TextWidthBasis.values.first));
  /// ```
  WidgetMatcher<Text> hasTextWidthBasisWhere(MatchProp<TextWidthBasis> match) {
    return hasDiagnosticProp<TextWidthBasis>('textWidthBasis', match);
  }

  /// Expects that textWidthBasis of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextWidthBasis(TextWidthBasis.values.first);
  /// ```
  WidgetMatcher<Text> hasTextWidthBasis(TextWidthBasis? value) {
    return hasDiagnosticProp<TextWidthBasis>('textWidthBasis',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textHeightBehavior of [Text] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextHeightBehaviorWhere((it) => it.equals(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)));
  /// ```
  WidgetMatcher<Text> hasTextHeightBehaviorWhere(
      MatchProp<TextHeightBehavior> match) {
    return hasDiagnosticProp<TextHeightBehavior>('textHeightBehavior', match);
  }

  /// Expects that textHeightBehavior of [Text] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Text>().existsOnce().hasTextHeightBehavior(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false));
  /// ```
  WidgetMatcher<Text> hasTextHeightBehavior(TextHeightBehavior? value) {
    return hasDiagnosticProp<TextHeightBehavior>('textHeightBehavior',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension TextGetter on WidgetMatcher<Text> {
  /// Returns the text of the matched [Text] via [Widget.toDiagnosticsNode]
  String getText() {
    return getDiagnosticProp<String>('data');
  }

  /// Returns the textAlign of the matched [Text] via [Widget.toDiagnosticsNode]
  TextAlign getTextAlign() {
    return getDiagnosticProp<TextAlign>('textAlign');
  }

  /// Returns the textDirection of the matched [Text] via [Widget.toDiagnosticsNode]
  TextDirection getTextDirection() {
    return getDiagnosticProp<TextDirection>('textDirection');
  }

  /// Returns the locale of the matched [Text] via [Widget.toDiagnosticsNode]
  Locale getLocale() {
    return getDiagnosticProp<Locale>('locale');
  }

  /// Returns the softWrap of the matched [Text] via [Widget.toDiagnosticsNode]
  bool getSoftWrap() {
    return getDiagnosticProp<bool>('softWrap');
  }

  /// Returns the overflow of the matched [Text] via [Widget.toDiagnosticsNode]
  TextOverflow getOverflow() {
    return getDiagnosticProp<TextOverflow>('overflow');
  }

  /// Returns the textScaleFactor of the matched [Text] via [Widget.toDiagnosticsNode]
  double getTextScaleFactor() {
    return getDiagnosticProp<double>('textScaleFactor');
  }

  /// Returns the maxLines of the matched [Text] via [Widget.toDiagnosticsNode]
  int getMaxLines() {
    return getDiagnosticProp<int>('maxLines');
  }

  /// Returns the textWidthBasis of the matched [Text] via [Widget.toDiagnosticsNode]
  TextWidthBasis getTextWidthBasis() {
    return getDiagnosticProp<TextWidthBasis>('textWidthBasis');
  }

  /// Returns the textHeightBehavior of the matched [Text] via [Widget.toDiagnosticsNode]
  TextHeightBehavior getTextHeightBehavior() {
    return getDiagnosticProp<TextHeightBehavior>('textHeightBehavior');
  }
}
