// ignore_for_file: require_trailing_commas
// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:spot/spot.dart';

/// Matchers for [Tooltip] auto-generated by spot
///
/// ```dart
/// spot<Tooltip>().printMatchers(propNameOverrides: {'vertical offset': 'verticalOffset'}, {'wait duration': 'waitDuration'}, {'show duration': 'showDuration'});
/// ```
/// Matchers for the properties of [Tooltip] provided via [Diagnosticable.debugFillProperties]
extension TooltipMatcher on WidgetMatcher<Tooltip> {
  /// Expects that message of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasMessageWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('message', match);
  }

  /// Expects that message of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasMessage(String? value) {
    return hasDiagnosticProp<String>(
        'message', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that richMessage of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasRichMessageWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('richMessage', match);
  }

  /// Expects that richMessage of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasRichMessage(String? value) {
    return hasDiagnosticProp<String>(
        'richMessage', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that height of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasHeightWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('height', match);
  }

  /// Expects that height of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasHeight(double? value) {
    return hasDiagnosticProp<double>(
        'height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that padding of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasPaddingWhere(MatchProp<EdgeInsetsGeometry> match) {
    return hasDiagnosticProp<EdgeInsetsGeometry>('padding', match);
  }

  /// Expects that padding of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasPadding(EdgeInsetsGeometry? value) {
    return hasDiagnosticProp<EdgeInsetsGeometry>(
        'padding', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that margin of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasMarginWhere(MatchProp<EdgeInsetsGeometry> match) {
    return hasDiagnosticProp<EdgeInsetsGeometry>('margin', match);
  }

  /// Expects that margin of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasMargin(EdgeInsetsGeometry? value) {
    return hasDiagnosticProp<EdgeInsetsGeometry>(
        'margin', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that verticalOffset of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasVerticalOffsetWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('vertical offset', match);
  }

  /// Expects that verticalOffset of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasVerticalOffset(double? value) {
    return hasDiagnosticProp<double>('vertical offset',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that position of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasPositionWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('position', match);
  }

  /// Expects that position of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasPosition(bool? value) {
    return hasDiagnosticProp<bool>(
        'position', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that semantics of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasSemanticsWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('semantics', match);
  }

  /// Expects that semantics of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasSemantics(bool? value) {
    return hasDiagnosticProp<bool>(
        'semantics', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that waitDuration of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasWaitDurationWhere(MatchProp<Duration> match) {
    return hasDiagnosticProp<Duration>('wait duration', match);
  }

  /// Expects that waitDuration of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasWaitDuration(Duration? value) {
    return hasDiagnosticProp<Duration>('wait duration',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that showDuration of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasShowDurationWhere(MatchProp<Duration> match) {
    return hasDiagnosticProp<Duration>('show duration', match);
  }

  /// Expects that showDuration of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasShowDuration(Duration? value) {
    return hasDiagnosticProp<Duration>('show duration',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that triggerMode of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasTriggerModeWhere(
      MatchProp<TooltipTriggerMode> match) {
    return hasDiagnosticProp<TooltipTriggerMode>('triggerMode', match);
  }

  /// Expects that triggerMode of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasTriggerMode(TooltipTriggerMode? value) {
    return hasDiagnosticProp<TooltipTriggerMode>(
        'triggerMode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that enableFeedback of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasEnableFeedbackWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('enableFeedback', match);
  }

  /// Expects that enableFeedback of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasEnableFeedback(bool? value) {
    return hasDiagnosticProp<bool>('enableFeedback',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textAlign of [Tooltip] matches the condition in [match]
  WidgetMatcher<Tooltip> hasTextAlignWhere(MatchProp<TextAlign> match) {
    return hasDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Expects that textAlign of [Tooltip] equals (==) [value]
  WidgetMatcher<Tooltip> hasTextAlign(TextAlign? value) {
    return hasDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Allows filtering [Tooltip] by the properties provided via [Diagnosticable.debugFillProperties]
extension TooltipSelector on WidgetSelector<Tooltip> {
  /// Creates a [WidgetSelector] that finds all [Tooltip] where message matches the condition
  WidgetSelector<Tooltip> whereMessage(MatchProp<String> match) {
    return withDiagnosticProp<String>('message', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where message equals (==) [value]
  WidgetSelector<Tooltip> withMessage(String? value) {
    return withDiagnosticProp<String>(
        'message', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where richMessage matches the condition
  WidgetSelector<Tooltip> whereRichMessage(MatchProp<String> match) {
    return withDiagnosticProp<String>('richMessage', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where richMessage equals (==) [value]
  WidgetSelector<Tooltip> withRichMessage(String? value) {
    return withDiagnosticProp<String>(
        'richMessage', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where height matches the condition
  WidgetSelector<Tooltip> whereHeight(MatchProp<double> match) {
    return withDiagnosticProp<double>('height', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where height equals (==) [value]
  WidgetSelector<Tooltip> withHeight(double? value) {
    return withDiagnosticProp<double>(
        'height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where padding matches the condition
  WidgetSelector<Tooltip> wherePadding(MatchProp<EdgeInsetsGeometry> match) {
    return withDiagnosticProp<EdgeInsetsGeometry>('padding', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where padding equals (==) [value]
  WidgetSelector<Tooltip> withPadding(EdgeInsetsGeometry? value) {
    return withDiagnosticProp<EdgeInsetsGeometry>(
        'padding', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where margin matches the condition
  WidgetSelector<Tooltip> whereMargin(MatchProp<EdgeInsetsGeometry> match) {
    return withDiagnosticProp<EdgeInsetsGeometry>('margin', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where margin equals (==) [value]
  WidgetSelector<Tooltip> withMargin(EdgeInsetsGeometry? value) {
    return withDiagnosticProp<EdgeInsetsGeometry>(
        'margin', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where verticalOffset matches the condition
  WidgetSelector<Tooltip> whereVerticalOffset(MatchProp<double> match) {
    return withDiagnosticProp<double>('vertical offset', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where verticalOffset equals (==) [value]
  WidgetSelector<Tooltip> withVerticalOffset(double? value) {
    return withDiagnosticProp<double>('vertical offset',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where position matches the condition
  WidgetSelector<Tooltip> wherePosition(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('position', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where position equals (==) [value]
  WidgetSelector<Tooltip> withPosition(bool? value) {
    return withDiagnosticProp<bool>(
        'position', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where semantics matches the condition
  WidgetSelector<Tooltip> whereSemantics(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('semantics', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where semantics equals (==) [value]
  WidgetSelector<Tooltip> withSemantics(bool? value) {
    return withDiagnosticProp<bool>(
        'semantics', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where waitDuration matches the condition
  WidgetSelector<Tooltip> whereWaitDuration(MatchProp<Duration> match) {
    return withDiagnosticProp<Duration>('wait duration', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where waitDuration equals (==) [value]
  WidgetSelector<Tooltip> withWaitDuration(Duration? value) {
    return withDiagnosticProp<Duration>('wait duration',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where showDuration matches the condition
  WidgetSelector<Tooltip> whereShowDuration(MatchProp<Duration> match) {
    return withDiagnosticProp<Duration>('show duration', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where showDuration equals (==) [value]
  WidgetSelector<Tooltip> withShowDuration(Duration? value) {
    return withDiagnosticProp<Duration>('show duration',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where triggerMode matches the condition
  WidgetSelector<Tooltip> whereTriggerMode(
      MatchProp<TooltipTriggerMode> match) {
    return withDiagnosticProp<TooltipTriggerMode>('triggerMode', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where triggerMode equals (==) [value]
  WidgetSelector<Tooltip> withTriggerMode(TooltipTriggerMode? value) {
    return withDiagnosticProp<TooltipTriggerMode>(
        'triggerMode', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where enableFeedback matches the condition
  WidgetSelector<Tooltip> whereEnableFeedback(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('enableFeedback', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where enableFeedback equals (==) [value]
  WidgetSelector<Tooltip> withEnableFeedback(bool? value) {
    return withDiagnosticProp<bool>('enableFeedback',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where textAlign matches the condition
  WidgetSelector<Tooltip> whereTextAlign(MatchProp<TextAlign> match) {
    return withDiagnosticProp<TextAlign>('textAlign', match);
  }

  /// Creates a [WidgetSelector] that finds all [Tooltip] where textAlign equals (==) [value]
  WidgetSelector<Tooltip> withTextAlign(TextAlign? value) {
    return withDiagnosticProp<TextAlign>(
        'textAlign', (it) => value == null ? it.isNull() : it.equals(value));
  }
}
