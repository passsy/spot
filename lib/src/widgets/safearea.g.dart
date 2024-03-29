// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [SafeArea] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<SafeArea>().printMatchers();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Allows filtering [SafeArea] by the properties provided via [Diagnosticable.debugFillProperties]
extension SafeAreaSelector on WidgetSelector<SafeArea> {
  /// Creates a [WidgetSelector] that finds all [SafeArea] where left matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().whereLeft((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> whereLeft(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('left', match);
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where left equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().withLeft(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> withLeft(bool? value) {
    return withDiagnosticProp<bool>(
        'left', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where top matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().whereTop((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> whereTop(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('top', match);
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where top equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().withTop(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> withTop(bool? value) {
    return withDiagnosticProp<bool>(
        'top', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where right matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().whereRight((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> whereRight(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('right', match);
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where right equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().withRight(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> withRight(bool? value) {
    return withDiagnosticProp<bool>(
        'right', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where bottom matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().whereBottom((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> whereBottom(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('bottom', match);
  }

  /// Creates a [WidgetSelector] that finds all [SafeArea] where bottom equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().withBottom(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<SafeArea> withBottom(bool? value) {
    return withDiagnosticProp<bool>(
        'bottom', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [SafeArea] provided via [Diagnosticable.debugFillProperties]
extension SafeAreaMatcher on WidgetMatcher<SafeArea> {
  /// Expects that left of [SafeArea] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasLeftWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SafeArea> hasLeftWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('left', match);
  }

  /// Expects that left of [SafeArea] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasLeft(true);
  /// ```
  WidgetMatcher<SafeArea> hasLeft(bool? value) {
    return hasDiagnosticProp<bool>(
        'left', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that top of [SafeArea] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasTopWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SafeArea> hasTopWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('top', match);
  }

  /// Expects that top of [SafeArea] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasTop(true);
  /// ```
  WidgetMatcher<SafeArea> hasTop(bool? value) {
    return hasDiagnosticProp<bool>(
        'top', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that right of [SafeArea] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasRightWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SafeArea> hasRightWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('right', match);
  }

  /// Expects that right of [SafeArea] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasRight(true);
  /// ```
  WidgetMatcher<SafeArea> hasRight(bool? value) {
    return hasDiagnosticProp<bool>(
        'right', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that bottom of [SafeArea] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasBottomWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<SafeArea> hasBottomWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('bottom', match);
  }

  /// Expects that bottom of [SafeArea] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<SafeArea>().existsOnce().hasBottom(true);
  /// ```
  WidgetMatcher<SafeArea> hasBottom(bool? value) {
    return hasDiagnosticProp<bool>(
        'bottom', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension SafeAreaGetter on WidgetMatcher<SafeArea> {
  /// Returns the left of the matched [SafeArea] via [Widget.toDiagnosticsNode]
  bool getLeft() {
    return getDiagnosticProp<bool>('left');
  }

  /// Returns the top of the matched [SafeArea] via [Widget.toDiagnosticsNode]
  bool getTop() {
    return getDiagnosticProp<bool>('top');
  }

  /// Returns the right of the matched [SafeArea] via [Widget.toDiagnosticsNode]
  bool getRight() {
    return getDiagnosticProp<bool>('right');
  }

  /// Returns the bottom of the matched [SafeArea] via [Widget.toDiagnosticsNode]
  bool getBottom() {
    return getDiagnosticProp<bool>('bottom');
  }
}
