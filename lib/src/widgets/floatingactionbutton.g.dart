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
  /// Expects that tooltip of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasTooltipWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('tooltip', match);
  }

  /// Expects that tooltip of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasTooltip(String? value) {
    return hasDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that foregroundColor of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasForegroundColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('foregroundColor', match);
  }

  /// Expects that foregroundColor of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasForegroundColor(Color? value) {
    return hasDiagnosticProp<Color>('foregroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that backgroundColor of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasBackgroundColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('backgroundColor', match);
  }

  /// Expects that backgroundColor of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasBackgroundColor(Color? value) {
    return hasDiagnosticProp<Color>('backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusColor of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasFocusColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('focusColor', match);
  }

  /// Expects that focusColor of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasFocusColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'focusColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hoverColor of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasHoverColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('hoverColor', match);
  }

  /// Expects that hoverColor of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasHoverColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'hoverColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that splashColor of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasSplashColorWhere(
      MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('splashColor', match);
  }

  /// Expects that splashColor of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasSplashColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'splashColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that heroTag of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasHeroTagWhere(MatchProp<Object> match) {
    return hasDiagnosticProp<Object>('heroTag', match);
  }

  /// Expects that heroTag of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasHeroTag(Object? value) {
    return hasDiagnosticProp<Object>(
        'heroTag', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that elevation of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('elevation', match);
  }

  /// Expects that elevation of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasElevation(double? value) {
    return hasDiagnosticProp<double>(
        'elevation', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusElevation of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasFocusElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('focusElevation', match);
  }

  /// Expects that focusElevation of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasFocusElevation(double? value) {
    return hasDiagnosticProp<double>('focusElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hoverElevation of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasHoverElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('hoverElevation', match);
  }

  /// Expects that hoverElevation of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasHoverElevation(double? value) {
    return hasDiagnosticProp<double>('hoverElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that highlightElevation of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasHighlightElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('highlightElevation', match);
  }

  /// Expects that highlightElevation of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasHighlightElevation(double? value) {
    return hasDiagnosticProp<double>('highlightElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that disabledElevation of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasDisabledElevationWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('disabledElevation', match);
  }

  /// Expects that disabledElevation of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasDisabledElevation(double? value) {
    return hasDiagnosticProp<double>('disabledElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that shape of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasShapeWhere(
      MatchProp<ShapeBorder> match) {
    return hasDiagnosticProp<ShapeBorder>('shape', match);
  }

  /// Expects that shape of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasShape(ShapeBorder? value) {
    return hasDiagnosticProp<ShapeBorder>(
        'shape', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusNode of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasFocusNodeWhere(
      MatchProp<FocusNode> match) {
    return hasDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Expects that focusNode of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasFocusNode(FocusNode? value) {
    return hasDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that isExtended of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasIsExtendedWhere(
      MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('isExtended', match);
  }

  /// Expects that isExtended of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasIsExtended(bool? value) {
    return hasDiagnosticProp<bool>(
        'isExtended', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that materialTapTargetSize of [FloatingActionButton] matches the condition in [match]
  WidgetMatcher<FloatingActionButton> hasMaterialTapTargetSizeWhere(
      MatchProp<MaterialTapTargetSize> match) {
    return hasDiagnosticProp<MaterialTapTargetSize>(
        'materialTapTargetSize', match);
  }

  /// Expects that materialTapTargetSize of [FloatingActionButton] equals (==) [value]
  WidgetMatcher<FloatingActionButton> hasMaterialTapTargetSize(
      MaterialTapTargetSize? value) {
    return hasDiagnosticProp<MaterialTapTargetSize>('materialTapTargetSize',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [FloatingActionButton] by the properties provided via [Diagnosticable.debugFillProperties]
extension FloatingActionButtonSelector on WidgetSelector<FloatingActionButton> {
  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where tooltip matches the condition
  WidgetSelector<FloatingActionButton> whereTooltip(MatchProp<String> match) {
    return withDiagnosticProp<String>('tooltip', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where tooltip equals (==) [value]
  WidgetSelector<FloatingActionButton> withTooltip(String? value) {
    return withDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where foregroundColor matches the condition
  WidgetSelector<FloatingActionButton> whereForegroundColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('foregroundColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where foregroundColor equals (==) [value]
  WidgetSelector<FloatingActionButton> withForegroundColor(Color? value) {
    return withDiagnosticProp<Color>('foregroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where backgroundColor matches the condition
  WidgetSelector<FloatingActionButton> whereBackgroundColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('backgroundColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where backgroundColor equals (==) [value]
  WidgetSelector<FloatingActionButton> withBackgroundColor(Color? value) {
    return withDiagnosticProp<Color>('backgroundColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusColor matches the condition
  WidgetSelector<FloatingActionButton> whereFocusColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('focusColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusColor equals (==) [value]
  WidgetSelector<FloatingActionButton> withFocusColor(Color? value) {
    return withDiagnosticProp<Color>(
        'focusColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverColor matches the condition
  WidgetSelector<FloatingActionButton> whereHoverColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('hoverColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverColor equals (==) [value]
  WidgetSelector<FloatingActionButton> withHoverColor(Color? value) {
    return withDiagnosticProp<Color>(
        'hoverColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where splashColor matches the condition
  WidgetSelector<FloatingActionButton> whereSplashColor(
      MatchProp<Color> match) {
    return withDiagnosticProp<Color>('splashColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where splashColor equals (==) [value]
  WidgetSelector<FloatingActionButton> withSplashColor(Color? value) {
    return withDiagnosticProp<Color>(
        'splashColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where heroTag matches the condition
  WidgetSelector<FloatingActionButton> whereHeroTag(MatchProp<Object> match) {
    return withDiagnosticProp<Object>('heroTag', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where heroTag equals (==) [value]
  WidgetSelector<FloatingActionButton> withHeroTag(Object? value) {
    return withDiagnosticProp<Object>(
        'heroTag', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where elevation matches the condition
  WidgetSelector<FloatingActionButton> whereElevation(MatchProp<double> match) {
    return withDiagnosticProp<double>('elevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where elevation equals (==) [value]
  WidgetSelector<FloatingActionButton> withElevation(double? value) {
    return withDiagnosticProp<double>(
        'elevation', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusElevation matches the condition
  WidgetSelector<FloatingActionButton> whereFocusElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('focusElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusElevation equals (==) [value]
  WidgetSelector<FloatingActionButton> withFocusElevation(double? value) {
    return withDiagnosticProp<double>('focusElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverElevation matches the condition
  WidgetSelector<FloatingActionButton> whereHoverElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('hoverElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where hoverElevation equals (==) [value]
  WidgetSelector<FloatingActionButton> withHoverElevation(double? value) {
    return withDiagnosticProp<double>('hoverElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where highlightElevation matches the condition
  WidgetSelector<FloatingActionButton> whereHighlightElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('highlightElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where highlightElevation equals (==) [value]
  WidgetSelector<FloatingActionButton> withHighlightElevation(double? value) {
    return withDiagnosticProp<double>('highlightElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where disabledElevation matches the condition
  WidgetSelector<FloatingActionButton> whereDisabledElevation(
      MatchProp<double> match) {
    return withDiagnosticProp<double>('disabledElevation', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where disabledElevation equals (==) [value]
  WidgetSelector<FloatingActionButton> withDisabledElevation(double? value) {
    return withDiagnosticProp<double>('disabledElevation',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where shape matches the condition
  WidgetSelector<FloatingActionButton> whereShape(
      MatchProp<ShapeBorder> match) {
    return withDiagnosticProp<ShapeBorder>('shape', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where shape equals (==) [value]
  WidgetSelector<FloatingActionButton> withShape(ShapeBorder? value) {
    return withDiagnosticProp<ShapeBorder>(
        'shape', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusNode matches the condition
  WidgetSelector<FloatingActionButton> whereFocusNode(
      MatchProp<FocusNode> match) {
    return withDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where focusNode equals (==) [value]
  WidgetSelector<FloatingActionButton> withFocusNode(FocusNode? value) {
    return withDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where isExtended matches the condition
  WidgetSelector<FloatingActionButton> whereIsExtended(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('isExtended', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where isExtended equals (==) [value]
  WidgetSelector<FloatingActionButton> withIsExtended(bool? value) {
    return withDiagnosticProp<bool>(
        'isExtended', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where materialTapTargetSize matches the condition
  WidgetSelector<FloatingActionButton> whereMaterialTapTargetSize(
      MatchProp<MaterialTapTargetSize> match) {
    return withDiagnosticProp<MaterialTapTargetSize>(
        'materialTapTargetSize', match);
  }

  /// Creates a [WidgetSelector] that finds all [FloatingActionButton] where materialTapTargetSize equals (==) [value]
  WidgetSelector<FloatingActionButton> withMaterialTapTargetSize(
      MaterialTapTargetSize? value) {
    return withDiagnosticProp<MaterialTapTargetSize>('materialTapTargetSize',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}
