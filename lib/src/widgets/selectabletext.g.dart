// ignore_for_file: require_trailing_commas
// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Matchers for [SelectableText] auto-generated by spot
///
/// ```dart
/// spot<SelectableText>().printMatchers(propNameOverrides: {'data': 'text'});
/// ```
/// Matchers for the properties of [SelectableText] provided via [Diagnosticable.debugFillProperties]
extension SelectableTextMatcher on WidgetMatcher<SelectableText> {
  /// Expects that text of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<SelectableText> hasTextWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('data', match);
  }

  /// Expects that text of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasText('foo');
  /// ```
  WidgetMatcher<SelectableText> hasText(String? value) {
    return hasDiagnosticProp<String>(
        'data', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that semanticsLabel of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSemanticsLabelWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<SelectableText> hasSemanticsLabelWhere(
      MatchProp<String> match) {
    return hasDiagnosticProp<String>('semanticsLabel', match);
  }

  /// Expects that semanticsLabel of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSemanticsLabel('foo');
  /// ```
  WidgetMatcher<SelectableText> hasSemanticsLabel(String? value) {
    return hasDiagnosticProp<String>('semanticsLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusNode of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasFocusNodeWhere((it) => it.equals(FocusNode()));
  /// ```
  WidgetMatcher<SelectableText> hasFocusNodeWhere(MatchProp<FocusNode> match) {
    return hasDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Expects that focusNode of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasFocusNode(FocusNode());
  /// ```
  WidgetMatcher<SelectableText> hasFocusNode(FocusNode? value) {
    return hasDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that style of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasStyleWhere((it) => it.equals(TextStyle()));
  /// ```
  WidgetMatcher<SelectableText> hasStyleWhere(MatchProp<TextStyle> match) {
    return hasDiagnosticProp<TextStyle>('style', match);
  }

  /// Expects that style of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasStyle(TextStyle());
  /// ```
  WidgetMatcher<SelectableText> hasStyle(TextStyle? value) {
    return hasDiagnosticProp<TextStyle>(
        'style', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that autofocus of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasAutofocusWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SelectableText> hasAutofocusWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('autofocus', match);
  }

  /// Expects that autofocus of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasAutofocus(true);
  /// ```
  WidgetMatcher<SelectableText> hasAutofocus(bool? value) {
    return hasDiagnosticProp<bool>(
        'autofocus', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that showCursor of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasShowCursorWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SelectableText> hasShowCursorWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('showCursor', match);
  }

  /// Expects that showCursor of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasShowCursor(true);
  /// ```
  WidgetMatcher<SelectableText> hasShowCursor(bool? value) {
    return hasDiagnosticProp<bool>(
        'showCursor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that minLines of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasMinLinesWhere((it) => it.isGreaterThan(10));
  /// ```
  WidgetMatcher<SelectableText> hasMinLinesWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('minLines', match);
  }

  /// Expects that minLines of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasMinLines(10);
  /// ```
  WidgetMatcher<SelectableText> hasMinLines(int? value) {
    return hasDiagnosticProp<int>(
        'minLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that maxLines of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasMaxLinesWhere((it) => it.isGreaterThan(10));
  /// ```
  WidgetMatcher<SelectableText> hasMaxLinesWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('maxLines', match);
  }

  /// Expects that maxLines of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasMaxLines(10);
  /// ```
  WidgetMatcher<SelectableText> hasMaxLines(int? value) {
    return hasDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textAlign of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextAlignWhere((it) => it.equals(TextAlign.values.first));
  /// ```
  WidgetMatcher<SelectableText> hasTextAlignWhere(MatchProp<TextAlign> match) {
    return hasDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Expects that textAlign of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextAlign(TextAlign.values.first);
  /// ```
  WidgetMatcher<SelectableText> hasTextAlign(TextAlign? value) {
    return hasDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textDirection of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextDirectionWhere((it) => it.equals(TextDirection.values.first));
  /// ```
  WidgetMatcher<SelectableText> hasTextDirectionWhere(
      MatchProp<TextDirection> match) {
    return hasDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Expects that textDirection of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextDirection(TextDirection.values.first);
  /// ```
  WidgetMatcher<SelectableText> hasTextDirection(TextDirection? value) {
    return hasDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textScaleFactor of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextScaleFactorWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<SelectableText> hasTextScaleFactorWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('textScaleFactor', match);
  }

  /// Expects that textScaleFactor of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextScaleFactor(10.5);
  /// ```
  WidgetMatcher<SelectableText> hasTextScaleFactor(double? value) {
    return hasDiagnosticProp<double>('textScaleFactor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that cursorWidth of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorWidthWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<SelectableText> hasCursorWidthWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('cursorWidth', match);
  }

  /// Expects that cursorWidth of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorWidth(10.5);
  /// ```
  WidgetMatcher<SelectableText> hasCursorWidth(double? value) {
    return hasDiagnosticProp<double>(
        'cursorWidth', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that cursorHeight of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorHeightWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<SelectableText> hasCursorHeightWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('cursorHeight', match);
  }

  /// Expects that cursorHeight of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorHeight(10.5);
  /// ```
  WidgetMatcher<SelectableText> hasCursorHeight(double? value) {
    return hasDiagnosticProp<double>(
        'cursorHeight', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that cursorRadius of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorRadiusWhere((it) => it.equals(Radius.circular(10.0)));
  /// ```
  WidgetMatcher<SelectableText> hasCursorRadiusWhere(MatchProp<Radius> match) {
    return hasDiagnosticProp<Radius>('cursorRadius', match);
  }

  /// Expects that cursorRadius of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorRadius(Radius.circular(10.0));
  /// ```
  WidgetMatcher<SelectableText> hasCursorRadius(Radius? value) {
    return hasDiagnosticProp<Radius>(
        'cursorRadius', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that cursorColor of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<SelectableText> hasCursorColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('cursorColor', match);
  }

  /// Expects that cursorColor of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasCursorColor(Colors.red);
  /// ```
  WidgetMatcher<SelectableText> hasCursorColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'cursorColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that selectionEnabled of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSelectionEnabledWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SelectableText> hasSelectionEnabledWhere(
      MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('selectionEnabled', match);
  }

  /// Expects that selectionEnabled of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSelectionEnabled(true);
  /// ```
  WidgetMatcher<SelectableText> hasSelectionEnabled(bool? value) {
    return hasDiagnosticProp<bool>('selectionEnabled',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that selectionControls of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSelectionControlsWhere((it) => it.equals(MaterialTextSelectionControls()));
  /// ```
  WidgetMatcher<SelectableText> hasSelectionControlsWhere(
      MatchProp<TextSelectionControls> match) {
    return hasDiagnosticProp<TextSelectionControls>('selectionControls', match);
  }

  /// Expects that selectionControls of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasSelectionControls(MaterialTextSelectionControls());
  /// ```
  WidgetMatcher<SelectableText> hasSelectionControls(
      TextSelectionControls? value) {
    return hasDiagnosticProp<TextSelectionControls>('selectionControls',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that scrollPhysics of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasScrollPhysicsWhere((it) => it.equals(BouncingScrollPhysics()));
  /// ```
  WidgetMatcher<SelectableText> hasScrollPhysicsWhere(
      MatchProp<ScrollPhysics> match) {
    return hasDiagnosticProp<ScrollPhysics>('scrollPhysics', match);
  }

  /// Expects that scrollPhysics of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasScrollPhysics(BouncingScrollPhysics());
  /// ```
  WidgetMatcher<SelectableText> hasScrollPhysics(ScrollPhysics? value) {
    return hasDiagnosticProp<ScrollPhysics>('scrollPhysics',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textHeightBehavior of [SelectableText] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextHeightBehaviorWhere((it) => it.equals(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)));
  /// ```
  WidgetMatcher<SelectableText> hasTextHeightBehaviorWhere(
      MatchProp<TextHeightBehavior> match) {
    return hasDiagnosticProp<TextHeightBehavior>('textHeightBehavior', match);
  }

  /// Expects that textHeightBehavior of [SelectableText] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().existsOnce().hasTextHeightBehavior(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false));
  /// ```
  WidgetMatcher<SelectableText> hasTextHeightBehavior(
      TextHeightBehavior? value) {
    return hasDiagnosticProp<TextHeightBehavior>('textHeightBehavior',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [SelectableText] by the properties provided via [Diagnosticable.debugFillProperties]
extension SelectableTextSelector on WidgetSelector<SelectableText> {
  /// Creates a [WidgetSelector] that finds all [SelectableText] where text matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereText((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereText(MatchProp<String> match) {
    return withDiagnosticProp<String>('data', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where text equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withText('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withText(String? value) {
    return withDiagnosticProp<String>(
        'data', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where semanticsLabel matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereSemanticsLabel((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereSemanticsLabel(MatchProp<String> match) {
    return withDiagnosticProp<String>('semanticsLabel', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where semanticsLabel equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withSemanticsLabel('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withSemanticsLabel(String? value) {
    return withDiagnosticProp<String>('semanticsLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where focusNode matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereFocusNode((it) => it.equals(FocusNode())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereFocusNode(MatchProp<FocusNode> match) {
    return withDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where focusNode equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withFocusNode(FocusNode()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withFocusNode(FocusNode? value) {
    return withDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where style matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereStyle((it) => it.equals(TextStyle())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereStyle(MatchProp<TextStyle> match) {
    return withDiagnosticProp<TextStyle>('style', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where style equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withStyle(TextStyle()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withStyle(TextStyle? value) {
    return withDiagnosticProp<TextStyle>(
        'style', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where autofocus matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereAutofocus((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereAutofocus(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('autofocus', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where autofocus equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withAutofocus(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withAutofocus(bool? value) {
    return withDiagnosticProp<bool>(
        'autofocus', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where showCursor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereShowCursor((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereShowCursor(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('showCursor', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where showCursor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withShowCursor(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withShowCursor(bool? value) {
    return withDiagnosticProp<bool>(
        'showCursor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where minLines matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereMinLines((it) => it.isGreaterThan(10)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereMinLines(MatchProp<int> match) {
    return withDiagnosticProp<int>('minLines', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where minLines equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withMinLines(10).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withMinLines(int? value) {
    return withDiagnosticProp<int>(
        'minLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where maxLines matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereMaxLines((it) => it.isGreaterThan(10)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereMaxLines(MatchProp<int> match) {
    return withDiagnosticProp<int>('maxLines', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where maxLines equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withMaxLines(10).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withMaxLines(int? value) {
    return withDiagnosticProp<int>(
        'maxLines', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textAlign matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereTextAlign((it) => it.equals(TextAlign.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereTextAlign(MatchProp<TextAlign> match) {
    return withDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textAlign equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withTextAlign(TextAlign.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withTextAlign(TextAlign? value) {
    return withDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textDirection matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereTextDirection((it) => it.equals(TextDirection.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereTextDirection(
      MatchProp<TextDirection> match) {
    return withDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textDirection equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withTextDirection(TextDirection.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withTextDirection(TextDirection? value) {
    return withDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textScaleFactor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereTextScaleFactor((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereTextScaleFactor(MatchProp<double> match) {
    return withDiagnosticProp<double>('textScaleFactor', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textScaleFactor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withTextScaleFactor(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withTextScaleFactor(double? value) {
    return withDiagnosticProp<double>('textScaleFactor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorWidth matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereCursorWidth((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereCursorWidth(MatchProp<double> match) {
    return withDiagnosticProp<double>('cursorWidth', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorWidth equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withCursorWidth(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withCursorWidth(double? value) {
    return withDiagnosticProp<double>(
        'cursorWidth', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorHeight matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereCursorHeight((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereCursorHeight(MatchProp<double> match) {
    return withDiagnosticProp<double>('cursorHeight', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorHeight equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withCursorHeight(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withCursorHeight(double? value) {
    return withDiagnosticProp<double>(
        'cursorHeight', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorRadius matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereCursorRadius((it) => it.equals(Radius.circular(10.0))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereCursorRadius(MatchProp<Radius> match) {
    return withDiagnosticProp<Radius>('cursorRadius', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorRadius equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withCursorRadius(Radius.circular(10.0)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withCursorRadius(Radius? value) {
    return withDiagnosticProp<Radius>(
        'cursorRadius', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereCursorColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereCursorColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('cursorColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where cursorColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withCursorColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withCursorColor(Color? value) {
    return withDiagnosticProp<Color>(
        'cursorColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where selectionEnabled matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereSelectionEnabled((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereSelectionEnabled(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('selectionEnabled', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where selectionEnabled equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withSelectionEnabled(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withSelectionEnabled(bool? value) {
    return withDiagnosticProp<bool>('selectionEnabled',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where selectionControls matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereSelectionControls((it) => it.equals(MaterialTextSelectionControls())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereSelectionControls(
      MatchProp<TextSelectionControls> match) {
    return withDiagnosticProp<TextSelectionControls>(
        'selectionControls', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where selectionControls equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withSelectionControls(MaterialTextSelectionControls()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withSelectionControls(
      TextSelectionControls? value) {
    return withDiagnosticProp<TextSelectionControls>('selectionControls',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where scrollPhysics matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereScrollPhysics((it) => it.equals(BouncingScrollPhysics())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereScrollPhysics(
      MatchProp<ScrollPhysics> match) {
    return withDiagnosticProp<ScrollPhysics>('scrollPhysics', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where scrollPhysics equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withScrollPhysics(BouncingScrollPhysics()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withScrollPhysics(ScrollPhysics? value) {
    return withDiagnosticProp<ScrollPhysics>('scrollPhysics',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textHeightBehavior matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().whereTextHeightBehavior((it) => it.equals(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> whereTextHeightBehavior(
      MatchProp<TextHeightBehavior> match) {
    return withDiagnosticProp<TextHeightBehavior>('textHeightBehavior', match);
  }

  /// Creates a [WidgetSelector] that finds all [SelectableText] where textHeightBehavior equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<SelectableText>().withTextHeightBehavior(TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SelectableText> withTextHeightBehavior(
      TextHeightBehavior? value) {
    return withDiagnosticProp<TextHeightBehavior>('textHeightBehavior',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}
