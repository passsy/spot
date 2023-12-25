// ignore_for_file: require_trailing_commas
// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Matchers for [Slider] auto-generated by spot
///
/// ```dart
/// spot<Slider>().printMatchers();
/// ```
/// Matchers for the properties of [Slider] provided via [Diagnosticable.debugFillProperties]
extension SliderMatcher on WidgetMatcher<Slider> {
  /// Expects that value of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasValueWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('value', match);
  }

  /// Expects that value of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasValue(double? value) {
    return hasDiagnosticProp<double>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that secondaryTrackValue of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasSecondaryTrackValueWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('secondaryTrackValue', match);
  }

  /// Expects that secondaryTrackValue of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasSecondaryTrackValue(double? value) {
    return hasDiagnosticProp<double>('secondaryTrackValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that min of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasMinWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('min', match);
  }

  /// Expects that min of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasMin(double? value) {
    return hasDiagnosticProp<double>(
        'min', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that max of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasMaxWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('max', match);
  }

  /// Expects that max of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasMax(double? value) {
    return hasDiagnosticProp<double>(
        'max', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that divisions of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasDivisionsWhere(MatchProp<int> match) {
    return hasDiagnosticProp<int>('divisions', match);
  }

  /// Expects that divisions of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasDivisions(int? value) {
    return hasDiagnosticProp<int>(
        'divisions', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that label of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasLabelWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('label', match);
  }

  /// Expects that label of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasLabel(String? value) {
    return hasDiagnosticProp<String>(
        'label', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that activeColor of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasActiveColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('activeColor', match);
  }

  /// Expects that activeColor of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasActiveColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'activeColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that inactiveColor of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasInactiveColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('inactiveColor', match);
  }

  /// Expects that inactiveColor of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasInactiveColor(Color? value) {
    return hasDiagnosticProp<Color>('inactiveColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that secondaryActiveColor of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasSecondaryActiveColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('secondaryActiveColor', match);
  }

  /// Expects that secondaryActiveColor of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasSecondaryActiveColor(Color? value) {
    return hasDiagnosticProp<Color>('secondaryActiveColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that focusNode of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasFocusNodeWhere(MatchProp<FocusNode> match) {
    return hasDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Expects that focusNode of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasFocusNode(FocusNode? value) {
    return hasDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that autofocus of [Slider] matches the condition in [match]
  WidgetMatcher<Slider> hasAutofocusWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('autofocus', match);
  }

  /// Expects that autofocus of [Slider] equals (==) [value]
  WidgetMatcher<Slider> hasAutofocus(bool? value) {
    return hasDiagnosticProp<bool>(
        'autofocus', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [Slider] by the properties provided via [Diagnosticable.debugFillProperties]
extension SliderSelector on WidgetSelector<Slider> {
  /// Creates a [WidgetSelector] that finds all [Slider] where value matches the condition
  @useResult
  WidgetSelector<Slider> whereValue(MatchProp<double> match) {
    return withDiagnosticProp<double>('value', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where value equals (==) [value]
  @useResult
  WidgetSelector<Slider> withValue(double? value) {
    return withDiagnosticProp<double>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where secondaryTrackValue matches the condition
  @useResult
  WidgetSelector<Slider> whereSecondaryTrackValue(MatchProp<double> match) {
    return withDiagnosticProp<double>('secondaryTrackValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where secondaryTrackValue equals (==) [value]
  @useResult
  WidgetSelector<Slider> withSecondaryTrackValue(double? value) {
    return withDiagnosticProp<double>('secondaryTrackValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where min matches the condition
  @useResult
  WidgetSelector<Slider> whereMin(MatchProp<double> match) {
    return withDiagnosticProp<double>('min', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where min equals (==) [value]
  @useResult
  WidgetSelector<Slider> withMin(double? value) {
    return withDiagnosticProp<double>(
        'min', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where max matches the condition
  @useResult
  WidgetSelector<Slider> whereMax(MatchProp<double> match) {
    return withDiagnosticProp<double>('max', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where max equals (==) [value]
  @useResult
  WidgetSelector<Slider> withMax(double? value) {
    return withDiagnosticProp<double>(
        'max', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where divisions matches the condition
  @useResult
  WidgetSelector<Slider> whereDivisions(MatchProp<int> match) {
    return withDiagnosticProp<int>('divisions', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where divisions equals (==) [value]
  @useResult
  WidgetSelector<Slider> withDivisions(int? value) {
    return withDiagnosticProp<int>(
        'divisions', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where label matches the condition
  @useResult
  WidgetSelector<Slider> whereLabel(MatchProp<String> match) {
    return withDiagnosticProp<String>('label', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where label equals (==) [value]
  @useResult
  WidgetSelector<Slider> withLabel(String? value) {
    return withDiagnosticProp<String>(
        'label', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where activeColor matches the condition
  @useResult
  WidgetSelector<Slider> whereActiveColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('activeColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where activeColor equals (==) [value]
  @useResult
  WidgetSelector<Slider> withActiveColor(Color? value) {
    return withDiagnosticProp<Color>(
        'activeColor', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where inactiveColor matches the condition
  @useResult
  WidgetSelector<Slider> whereInactiveColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('inactiveColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where inactiveColor equals (==) [value]
  @useResult
  WidgetSelector<Slider> withInactiveColor(Color? value) {
    return withDiagnosticProp<Color>('inactiveColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where secondaryActiveColor matches the condition
  @useResult
  WidgetSelector<Slider> whereSecondaryActiveColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('secondaryActiveColor', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where secondaryActiveColor equals (==) [value]
  @useResult
  WidgetSelector<Slider> withSecondaryActiveColor(Color? value) {
    return withDiagnosticProp<Color>('secondaryActiveColor',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where focusNode matches the condition
  @useResult
  WidgetSelector<Slider> whereFocusNode(MatchProp<FocusNode> match) {
    return withDiagnosticProp<FocusNode>('focusNode', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where focusNode equals (==) [value]
  @useResult
  WidgetSelector<Slider> withFocusNode(FocusNode? value) {
    return withDiagnosticProp<FocusNode>(
        'focusNode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where autofocus matches the condition
  @useResult
  WidgetSelector<Slider> whereAutofocus(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('autofocus', match);
  }

  /// Creates a [WidgetSelector] that finds all [Slider] where autofocus equals (==) [value]
  @useResult
  WidgetSelector<Slider> withAutofocus(bool? value) {
    return withDiagnosticProp<bool>(
        'autofocus', (it) => value == null ? it.isNull() : it.equals(value));
  }
}
