// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [Switch] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<Switch>().printMatchers();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Allows filtering [Switch] by the properties provided via [Diagnosticable.debugFillProperties]
extension SwitchSelector on WidgetSelector<Switch> {
  /// Creates a [WidgetSelector] that finds all [Switch] where value matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Switch>().whereValue((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Switch> whereValue(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('value', match);
  }

  /// Creates a [WidgetSelector] that finds all [Switch] where value equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Switch>().withValue(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Switch> withValue(bool? value) {
    return withDiagnosticProp<bool>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [Switch] provided via [Diagnosticable.debugFillProperties]
extension SwitchMatcher on WidgetMatcher<Switch> {
  /// Expects that value of [Switch] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Switch>().existsOnce().hasValueWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Switch> hasValueWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('value', match);
  }

  /// Expects that value of [Switch] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Switch>().existsOnce().hasValue(true);
  /// ```
  WidgetMatcher<Switch> hasValue(bool? value) {
    return hasDiagnosticProp<bool>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension SwitchGetter on WidgetMatcher<Switch> {
  /// Returns the value of the matched [Switch] via [Widget.toDiagnosticsNode]
  bool getValue() {
    return getDiagnosticProp<bool>('value');
  }
}
