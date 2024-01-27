// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [LinearProgressIndicator] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<LinearProgressIndicator>().printMatchers();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Allows filtering [LinearProgressIndicator] by the properties provided via [Diagnosticable.debugFillProperties]
extension LinearProgressIndicatorSelector
    on WidgetSelector<LinearProgressIndicator> {
  /// Creates a [WidgetSelector] that finds all [LinearProgressIndicator] where value matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<LinearProgressIndicator>().whereValue((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<LinearProgressIndicator> whereValue(MatchProp<double> match) {
    return withDiagnosticProp<double>('value', match);
  }

  /// Creates a [WidgetSelector] that finds all [LinearProgressIndicator] where value equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<LinearProgressIndicator>().withValue(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<LinearProgressIndicator> withValue(double? value) {
    return withDiagnosticProp<double>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [LinearProgressIndicator] provided via [Diagnosticable.debugFillProperties]
extension LinearProgressIndicatorMatcher
    on WidgetMatcher<LinearProgressIndicator> {
  /// Expects that value of [LinearProgressIndicator] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<LinearProgressIndicator>().existsOnce().hasValueWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<LinearProgressIndicator> hasValueWhere(
      MatchProp<double> match) {
    return hasDiagnosticProp<double>('value', match);
  }

  /// Expects that value of [LinearProgressIndicator] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<LinearProgressIndicator>().existsOnce().hasValue(10.5);
  /// ```
  WidgetMatcher<LinearProgressIndicator> hasValue(double? value) {
    return hasDiagnosticProp<double>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension LinearProgressIndicatorGetter
    on WidgetMatcher<LinearProgressIndicator> {
  /// Returns the value of the matched [LinearProgressIndicator] via [Widget.toDiagnosticsNode]
  double getValue() {
    return getDiagnosticProp<double>('value');
  }
}
