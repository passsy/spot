// ignore_for_file: require_trailing_commas
// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Matchers for [FloatingActionButton] auto-generated by spot
///
/// ```dart
/// spot<FloatingActionButton>().printMatchers();
/// ```
/// Matchers for the properties of [FloatingActionButton] provided via [Diagnosticable.debugFillProperties]
extension FloatingActionButtonMatcher on WidgetMatcher<FloatingActionButton> {
  /// Expects that tooltip of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasTooltipWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<FloatingActionButton> hasTooltipWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('tooltip', match);
  }

  /// Expects that tooltip of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasTooltip('foo');
  /// ```
  WidgetMatcher<FloatingActionButton> hasTooltip(String? value) {
    return hasDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that foregroundColor of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasForegroundColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<FloatingActionButton> hasForegroundColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('foregroundColor', match);
  }

  /// Expects that foregroundColor of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasForegroundColor(Colors.red);
  /// ```
  WidgetMatcher<FloatingActionButton> hasForegroundColor(Color? value) {
    return hasDiagnosticProp<Color>('foregroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that backgroundColor of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasBackgroundColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<FloatingActionButton> hasBackgroundColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('backgroundColor', match);
  }

  /// Expects that backgroundColor of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasBackgroundColor(Colors.red);
  /// ```
  WidgetMatcher<FloatingActionButton> hasBackgroundColor(Color? value) {
    return hasDiagnosticProp<Color>('backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusColor of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('focusColor', match);
  }

  /// Expects that focusColor of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusColor(Colors.red);
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'focusColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hoverColor of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHoverColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<FloatingActionButton> hasHoverColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('hoverColor', match);
  }

  /// Expects that hoverColor of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHoverColor(Colors.red);
  /// ```
  WidgetMatcher<FloatingActionButton> hasHoverColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'hoverColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that splashColor of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasSplashColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<FloatingActionButton> hasSplashColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('splashColor', match);
  }

  /// Expects that splashColor of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasSplashColor(Colors.red);
  /// ```
  WidgetMatcher<FloatingActionButton> hasSplashColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'splashColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that heroTag of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHeroTagWhere((it) => it.equals(Object()));
  /// ```
  WidgetMatcher<FloatingActionButton> hasHeroTagWhere(MatchProp<Object> match) {
    return hasDiagnosticProp<Object>('heroTag', match);
  }

  /// Expects that heroTag of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHeroTag(Object());
  /// ```
  WidgetMatcher<FloatingActionButton> hasHeroTag(Object? value) {
    return hasDiagnosticProp<Object>(
        'heroTag', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that elevation of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasElevationWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<FloatingActionButton> hasElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('elevation', match);
  }

  /// Expects that elevation of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasElevation(10.5);
  /// ```
  WidgetMatcher<FloatingActionButton> hasElevation(double? value) {
    return hasDiagnosticProp<double>(
        'elevation', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusElevation of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusElevationWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('focusElevation', match);
  }

  /// Expects that focusElevation of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusElevation(10.5);
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusElevation(double? value) {
    return hasDiagnosticProp<double>('focusElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hoverElevation of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHoverElevationWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<FloatingActionButton> hasHoverElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('hoverElevation', match);
  }

  /// Expects that hoverElevation of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHoverElevation(10.5);
  /// ```
  WidgetMatcher<FloatingActionButton> hasHoverElevation(double? value) {
    return hasDiagnosticProp<double>('hoverElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that highlightElevation of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHighlightElevationWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<FloatingActionButton> hasHighlightElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('highlightElevation', match);
  }

  /// Expects that highlightElevation of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasHighlightElevation(10.5);
  /// ```
  WidgetMatcher<FloatingActionButton> hasHighlightElevation(double? value) {
    return hasDiagnosticProp<double>('highlightElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that disabledElevation of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasDisabledElevationWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<FloatingActionButton> hasDisabledElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('disabledElevation', match);
  }

  /// Expects that disabledElevation of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasDisabledElevation(10.5);
  /// ```
  WidgetMatcher<FloatingActionButton> hasDisabledElevation(double? value) {
    return hasDiagnosticProp<double>('disabledElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that shape of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasShapeWhere((it) => it.equals(RoundedRectangleBorder()));
  /// ```
  WidgetMatcher<FloatingActionButton> hasShapeWhere(
      MatchProp<ShapeBorder> match) {
    return hasDiagnosticProp<ShapeBorder>('shape', match);
  }

  /// Expects that shape of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasShape(RoundedRectangleBorder());
  /// ```
  WidgetMatcher<FloatingActionButton> hasShape(ShapeBorder? value) {
    return hasDiagnosticProp<ShapeBorder>(
        'shape', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusNode of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusNodeWhere((it) => it.equals(FocusNode()));
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusNodeWhere(
      MatchProp<FocusNode> match) {
    return hasDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Expects that focusNode of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasFocusNode(FocusNode());
  /// ```
  WidgetMatcher<FloatingActionButton> hasFocusNode(FocusNode? value) {
    return hasDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that isExtended of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasIsExtendedWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<FloatingActionButton> hasIsExtendedWhere(
      MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('isExtended', match);
  }

  /// Expects that isExtended of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasIsExtended(true);
  /// ```
  WidgetMatcher<FloatingActionButton> hasIsExtended(bool? value) {
    return hasDiagnosticProp<bool>(
        'isExtended', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that materialTapTargetSize of [FloatingActionButton] matches the condition in [match].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasMaterialTapTargetSizeWhere((it) => it.equals(MaterialTapTargetSize.values.first));
  /// ```
  WidgetMatcher<FloatingActionButton> hasMaterialTapTargetSizeWhere(
      MatchProp<MaterialTapTargetSize> match) {
    return hasDiagnosticProp<MaterialTapTargetSize>(
        'materialTapTargetSize', match);
  }

  /// Expects that materialTapTargetSize of [FloatingActionButton] equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().existsOnce().hasMaterialTapTargetSize(MaterialTapTargetSize.values.first);
  /// ```
  WidgetMatcher<FloatingActionButton> hasMaterialTapTargetSize(
      MaterialTapTargetSize? value) {
    return hasDiagnosticProp<MaterialTapTargetSize>('materialTapTargetSize',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [FloatingActionButton] by the properties provided via [Diagnosticable.debugFillProperties]
extension FloatingActionButtonSelector on WidgetSelector<FloatingActionButton> {
  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where tooltip matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereTooltip((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereTooltip(MatchProp<String> match) {
    return withDiagnosticProp<String>('tooltip', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where tooltip equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withTooltip('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withTooltip(String? value) {
    return withDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where foregroundColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereForegroundColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereForegroundColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('foregroundColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where foregroundColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withForegroundColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withForegroundColor(Color? value) {
    return withDiagnosticProp<Color>('foregroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where backgroundColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereBackgroundColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereBackgroundColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('backgroundColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where backgroundColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withBackgroundColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withBackgroundColor(Color? value) {
    return withDiagnosticProp<Color>('backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereFocusColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereFocusColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('focusColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withFocusColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withFocusColor(Color? value) {
    return withDiagnosticProp<Color>(
        'focusColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereHoverColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereHoverColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('hoverColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withHoverColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withHoverColor(Color? value) {
    return withDiagnosticProp<Color>(
        'hoverColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where splashColor matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereSplashColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereSplashColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('splashColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where splashColor equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withSplashColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withSplashColor(Color? value) {
    return withDiagnosticProp<Color>(
        'splashColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where heroTag matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereHeroTag((it) => it.equals(Object())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereHeroTag(MatchProp<Object> match) {
    return withDiagnosticProp<Object>('heroTag', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where heroTag equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withHeroTag(Object()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withHeroTag(Object? value) {
    return withDiagnosticProp<Object>(
        'heroTag', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where elevation matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereElevation((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereElevation(MatchProp<double> match) {
    return withDiagnosticProp<double>('elevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where elevation equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withElevation(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withElevation(double? value) {
    return withDiagnosticProp<double>(
        'elevation', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusElevation matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereFocusElevation((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereFocusElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('focusElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusElevation equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withFocusElevation(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withFocusElevation(double? value) {
    return withDiagnosticProp<double>('focusElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverElevation matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereHoverElevation((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereHoverElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('hoverElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverElevation equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withHoverElevation(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withHoverElevation(double? value) {
    return withDiagnosticProp<double>('hoverElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where highlightElevation matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereHighlightElevation((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereHighlightElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('highlightElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where highlightElevation equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withHighlightElevation(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withHighlightElevation(double? value) {
    return withDiagnosticProp<double>('highlightElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where disabledElevation matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereDisabledElevation((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereDisabledElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('disabledElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where disabledElevation equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withDisabledElevation(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withDisabledElevation(double? value) {
    return withDiagnosticProp<double>('disabledElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where shape matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereShape((it) => it.equals(RoundedRectangleBorder())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereShape(
      MatchProp<ShapeBorder> match) {
    return withDiagnosticProp<ShapeBorder>('shape', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where shape equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withShape(RoundedRectangleBorder()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withShape(ShapeBorder? value) {
    return withDiagnosticProp<ShapeBorder>(
        'shape', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusNode matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereFocusNode((it) => it.equals(FocusNode())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereFocusNode(
      MatchProp<FocusNode> match) {
    return withDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusNode equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withFocusNode(FocusNode()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withFocusNode(FocusNode? value) {
    return withDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where isExtended matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereIsExtended((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereIsExtended(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('isExtended', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where isExtended equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withIsExtended(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withIsExtended(bool? value) {
    return withDiagnosticProp<bool>(
        'isExtended', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where materialTapTargetSize matches the condition.
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().whereMaterialTapTargetSize((it) => it.equals(MaterialTapTargetSize.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> whereMaterialTapTargetSize(
      MatchProp<MaterialTapTargetSize> match) {
    return withDiagnosticProp<MaterialTapTargetSize>(
        'materialTapTargetSize', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where materialTapTargetSize equals (==) [value].
  /// #### Example usage:
  /// ```dart
  /// spot<FloatingActionButton>().withMaterialTapTargetSize(MaterialTapTargetSize.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<FloatingActionButton> withMaterialTapTargetSize(
      MaterialTapTargetSize? value) {
    return withDiagnosticProp<MaterialTapTargetSize>('materialTapTargetSize',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}
