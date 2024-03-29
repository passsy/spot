// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [Semantics] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<Semantics>().printMatchers();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'package:spot/spot.dart';

/// Allows filtering [Semantics] by the properties provided via [Diagnosticable.debugFillProperties]
extension SemanticsSelector on WidgetSelector<Semantics> {
  /// Creates a [WidgetSelector] that finds all [Semantics] where container matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereContainer((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereContainer(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('container', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where container equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withContainer(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withContainer(bool? value) {
    return withDiagnosticProp<bool>(
        'container', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where properties matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereProperties((it) => it.equals(SemanticsProperties())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereProperties(
      MatchProp<SemanticsProperties> match) {
    return withDiagnosticProp<SemanticsProperties>('properties', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where properties equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withProperties(SemanticsProperties()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withProperties(SemanticsProperties? value) {
    return withDiagnosticProp<SemanticsProperties>(
        'properties', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where checked matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereChecked((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereChecked(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('checked', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where checked equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withChecked(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withChecked(bool? value) {
    return withDiagnosticProp<bool>(
        'checked', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where mixed matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereMixed((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereMixed(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('mixed', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where mixed equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withMixed(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withMixed(bool? value) {
    return withDiagnosticProp<bool>(
        'mixed', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where selected matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereSelected((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereSelected(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('selected', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where selected equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withSelected(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withSelected(bool? value) {
    return withDiagnosticProp<bool>(
        'selected', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where label matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereLabel((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereLabel(MatchProp<String> match) {
    return withDiagnosticProp<String>('label', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where label equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withLabel('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withLabel(String? value) {
    return withDiagnosticProp<String>(
        'label', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedLabel matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereAttributedLabel((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereAttributedLabel(MatchProp<String> match) {
    return withDiagnosticProp<String>('attributedLabel', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedLabel equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withAttributedLabel('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withAttributedLabel(String? value) {
    return withDiagnosticProp<String>('attributedLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where value matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereValue(MatchProp<String> match) {
    return withDiagnosticProp<String>('value', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where value equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withValue(String? value) {
    return withDiagnosticProp<String>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedValue matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereAttributedValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereAttributedValue(MatchProp<String> match) {
    return withDiagnosticProp<String>('attributedValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedValue equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withAttributedValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withAttributedValue(String? value) {
    return withDiagnosticProp<String>('attributedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where increasedValue matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereIncreasedValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereIncreasedValue(MatchProp<String> match) {
    return withDiagnosticProp<String>('increasedValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where increasedValue equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withIncreasedValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withIncreasedValue(String? value) {
    return withDiagnosticProp<String>('increasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedIncreasedValue matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereAttributedIncreasedValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereAttributedIncreasedValue(
      MatchProp<String> match) {
    return withDiagnosticProp<String>('attributedIncreasedValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedIncreasedValue equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withAttributedIncreasedValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withAttributedIncreasedValue(String? value) {
    return withDiagnosticProp<String>('attributedIncreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where decreasedValue matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereDecreasedValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereDecreasedValue(MatchProp<String> match) {
    return withDiagnosticProp<String>('decreasedValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where decreasedValue equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withDecreasedValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withDecreasedValue(String? value) {
    return withDiagnosticProp<String>('decreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedDecreasedValue matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereAttributedDecreasedValue((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereAttributedDecreasedValue(
      MatchProp<String> match) {
    return withDiagnosticProp<String>('attributedDecreasedValue', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedDecreasedValue equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withAttributedDecreasedValue('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withAttributedDecreasedValue(String? value) {
    return withDiagnosticProp<String>('attributedDecreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where hint matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereHint((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereHint(MatchProp<String> match) {
    return withDiagnosticProp<String>('hint', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where hint equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withHint('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withHint(String? value) {
    return withDiagnosticProp<String>(
        'hint', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedHint matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereAttributedHint((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereAttributedHint(MatchProp<String> match) {
    return withDiagnosticProp<String>('attributedHint', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where attributedHint equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withAttributedHint('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withAttributedHint(String? value) {
    return withDiagnosticProp<String>('attributedHint',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where tooltip matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereTooltip((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereTooltip(MatchProp<String> match) {
    return withDiagnosticProp<String>('tooltip', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where tooltip equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withTooltip('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withTooltip(String? value) {
    return withDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where textDirection matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereTextDirection((it) => it.equals(TextDirection.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereTextDirection(MatchProp<TextDirection> match) {
    return withDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where textDirection equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withTextDirection(TextDirection.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withTextDirection(TextDirection? value) {
    return withDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where sortKey matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereSortKey((it) => it.equals(OrdinalSortKey(1.0))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereSortKey(MatchProp<SemanticsSortKey> match) {
    return withDiagnosticProp<SemanticsSortKey>('sortKey', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where sortKey equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withSortKey(OrdinalSortKey(1.0)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withSortKey(SemanticsSortKey? value) {
    return withDiagnosticProp<SemanticsSortKey>(
        'sortKey', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where hintOverrides matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereHintOverrides((it) => it.equals(SemanticsHintOverrides())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereHintOverrides(
      MatchProp<SemanticsHintOverrides> match) {
    return withDiagnosticProp<SemanticsHintOverrides>('hintOverrides', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where hintOverrides equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withHintOverrides(SemanticsHintOverrides()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withHintOverrides(SemanticsHintOverrides? value) {
    return withDiagnosticProp<SemanticsHintOverrides>('hintOverrides',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where renderObject matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().whereRenderObject((it) => it.equals(RenderBox())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> whereRenderObject(
      MatchProp<RenderSemanticsAnnotations> match) {
    return withDiagnosticProp<RenderSemanticsAnnotations>(
        'renderObject', match);
  }

  /// Creates a [WidgetSelector] that finds all [Semantics] where renderObject equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().withRenderObject(RenderBox()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Semantics> withRenderObject(
      RenderSemanticsAnnotations? value) {
    return withDiagnosticProp<RenderSemanticsAnnotations>(
        'renderObject', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [Semantics] provided via [Diagnosticable.debugFillProperties]
extension SemanticsMatcher on WidgetMatcher<Semantics> {
  /// Expects that container of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasContainerWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Semantics> hasContainerWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('container', match);
  }

  /// Expects that container of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasContainer(true);
  /// ```
  WidgetMatcher<Semantics> hasContainer(bool? value) {
    return hasDiagnosticProp<bool>(
        'container', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that properties of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasPropertiesWhere((it) => it.equals(SemanticsProperties()));
  /// ```
  WidgetMatcher<Semantics> hasPropertiesWhere(
      MatchProp<SemanticsProperties> match) {
    return hasDiagnosticProp<SemanticsProperties>('properties', match);
  }

  /// Expects that properties of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasProperties(SemanticsProperties());
  /// ```
  WidgetMatcher<Semantics> hasProperties(SemanticsProperties? value) {
    return hasDiagnosticProp<SemanticsProperties>(
        'properties', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that checked of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasCheckedWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Semantics> hasCheckedWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('checked', match);
  }

  /// Expects that checked of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasChecked(true);
  /// ```
  WidgetMatcher<Semantics> hasChecked(bool? value) {
    return hasDiagnosticProp<bool>(
        'checked', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that mixed of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasMixedWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Semantics> hasMixedWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('mixed', match);
  }

  /// Expects that mixed of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasMixed(true);
  /// ```
  WidgetMatcher<Semantics> hasMixed(bool? value) {
    return hasDiagnosticProp<bool>(
        'mixed', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that selected of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasSelectedWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Semantics> hasSelectedWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('selected', match);
  }

  /// Expects that selected of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasSelected(true);
  /// ```
  WidgetMatcher<Semantics> hasSelected(bool? value) {
    return hasDiagnosticProp<bool>(
        'selected', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that label of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasLabelWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasLabelWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('label', match);
  }

  /// Expects that label of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasLabel('foo');
  /// ```
  WidgetMatcher<Semantics> hasLabel(String? value) {
    return hasDiagnosticProp<String>(
        'label', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that attributedLabel of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedLabelWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasAttributedLabelWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('attributedLabel', match);
  }

  /// Expects that attributedLabel of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedLabel('foo');
  /// ```
  WidgetMatcher<Semantics> hasAttributedLabel(String? value) {
    return hasDiagnosticProp<String>('attributedLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that value of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasValueWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('value', match);
  }

  /// Expects that value of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasValue(String? value) {
    return hasDiagnosticProp<String>(
        'value', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that attributedValue of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasAttributedValueWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('attributedValue', match);
  }

  /// Expects that attributedValue of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasAttributedValue(String? value) {
    return hasDiagnosticProp<String>('attributedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that increasedValue of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasIncreasedValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasIncreasedValueWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('increasedValue', match);
  }

  /// Expects that increasedValue of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasIncreasedValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasIncreasedValue(String? value) {
    return hasDiagnosticProp<String>('increasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that attributedIncreasedValue of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedIncreasedValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasAttributedIncreasedValueWhere(
      MatchProp<String> match) {
    return hasDiagnosticProp<String>('attributedIncreasedValue', match);
  }

  /// Expects that attributedIncreasedValue of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedIncreasedValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasAttributedIncreasedValue(String? value) {
    return hasDiagnosticProp<String>('attributedIncreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that decreasedValue of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasDecreasedValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasDecreasedValueWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('decreasedValue', match);
  }

  /// Expects that decreasedValue of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasDecreasedValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasDecreasedValue(String? value) {
    return hasDiagnosticProp<String>('decreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that attributedDecreasedValue of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedDecreasedValueWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasAttributedDecreasedValueWhere(
      MatchProp<String> match) {
    return hasDiagnosticProp<String>('attributedDecreasedValue', match);
  }

  /// Expects that attributedDecreasedValue of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedDecreasedValue('foo');
  /// ```
  WidgetMatcher<Semantics> hasAttributedDecreasedValue(String? value) {
    return hasDiagnosticProp<String>('attributedDecreasedValue',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hint of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasHintWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasHintWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('hint', match);
  }

  /// Expects that hint of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasHint('foo');
  /// ```
  WidgetMatcher<Semantics> hasHint(String? value) {
    return hasDiagnosticProp<String>(
        'hint', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that attributedHint of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedHintWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasAttributedHintWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('attributedHint', match);
  }

  /// Expects that attributedHint of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasAttributedHint('foo');
  /// ```
  WidgetMatcher<Semantics> hasAttributedHint(String? value) {
    return hasDiagnosticProp<String>('attributedHint',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that tooltip of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasTooltipWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Semantics> hasTooltipWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('tooltip', match);
  }

  /// Expects that tooltip of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasTooltip('foo');
  /// ```
  WidgetMatcher<Semantics> hasTooltip(String? value) {
    return hasDiagnosticProp<String>(
        'tooltip', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that textDirection of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasTextDirectionWhere((it) => it.equals(TextDirection.values.first));
  /// ```
  WidgetMatcher<Semantics> hasTextDirectionWhere(
      MatchProp<TextDirection> match) {
    return hasDiagnosticProp<TextDirection>('textDirection', match);
  }

  /// Expects that textDirection of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasTextDirection(TextDirection.values.first);
  /// ```
  WidgetMatcher<Semantics> hasTextDirection(TextDirection? value) {
    return hasDiagnosticProp<TextDirection>('textDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that sortKey of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasSortKeyWhere((it) => it.equals(OrdinalSortKey(1.0)));
  /// ```
  WidgetMatcher<Semantics> hasSortKeyWhere(MatchProp<SemanticsSortKey> match) {
    return hasDiagnosticProp<SemanticsSortKey>('sortKey', match);
  }

  /// Expects that sortKey of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasSortKey(OrdinalSortKey(1.0));
  /// ```
  WidgetMatcher<Semantics> hasSortKey(SemanticsSortKey? value) {
    return hasDiagnosticProp<SemanticsSortKey>(
        'sortKey', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that hintOverrides of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasHintOverridesWhere((it) => it.equals(SemanticsHintOverrides()));
  /// ```
  WidgetMatcher<Semantics> hasHintOverridesWhere(
      MatchProp<SemanticsHintOverrides> match) {
    return hasDiagnosticProp<SemanticsHintOverrides>('hintOverrides', match);
  }

  /// Expects that hintOverrides of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasHintOverrides(SemanticsHintOverrides());
  /// ```
  WidgetMatcher<Semantics> hasHintOverrides(SemanticsHintOverrides? value) {
    return hasDiagnosticProp<SemanticsHintOverrides>('hintOverrides',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that renderObject of [Semantics] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasRenderObjectWhere((it) => it.equals(RenderBox()));
  /// ```
  WidgetMatcher<Semantics> hasRenderObjectWhere(
      MatchProp<RenderSemanticsAnnotations> match) {
    return hasDiagnosticProp<RenderSemanticsAnnotations>('renderObject', match);
  }

  /// Expects that renderObject of [Semantics] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Semantics>().existsOnce().hasRenderObject(RenderBox());
  /// ```
  WidgetMatcher<Semantics> hasRenderObject(RenderSemanticsAnnotations? value) {
    return hasDiagnosticProp<RenderSemanticsAnnotations>(
        'renderObject', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension SemanticsGetter on WidgetMatcher<Semantics> {
  /// Returns the container of the matched [Semantics] via [Widget.toDiagnosticsNode]
  bool getContainer() {
    return getDiagnosticProp<bool>('container');
  }

  /// Returns the properties of the matched [Semantics] via [Widget.toDiagnosticsNode]
  SemanticsProperties getProperties() {
    return getDiagnosticProp<SemanticsProperties>('properties');
  }

  /// Returns the checked of the matched [Semantics] via [Widget.toDiagnosticsNode]
  bool getChecked() {
    return getDiagnosticProp<bool>('checked');
  }

  /// Returns the mixed of the matched [Semantics] via [Widget.toDiagnosticsNode]
  bool getMixed() {
    return getDiagnosticProp<bool>('mixed');
  }

  /// Returns the selected of the matched [Semantics] via [Widget.toDiagnosticsNode]
  bool getSelected() {
    return getDiagnosticProp<bool>('selected');
  }

  /// Returns the label of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getLabel() {
    return getDiagnosticProp<String>('label');
  }

  /// Returns the attributedLabel of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getAttributedLabel() {
    return getDiagnosticProp<String>('attributedLabel');
  }

  /// Returns the value of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getValue() {
    return getDiagnosticProp<String>('value');
  }

  /// Returns the attributedValue of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getAttributedValue() {
    return getDiagnosticProp<String>('attributedValue');
  }

  /// Returns the increasedValue of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getIncreasedValue() {
    return getDiagnosticProp<String>('increasedValue');
  }

  /// Returns the attributedIncreasedValue of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getAttributedIncreasedValue() {
    return getDiagnosticProp<String>('attributedIncreasedValue');
  }

  /// Returns the decreasedValue of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getDecreasedValue() {
    return getDiagnosticProp<String>('decreasedValue');
  }

  /// Returns the attributedDecreasedValue of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getAttributedDecreasedValue() {
    return getDiagnosticProp<String>('attributedDecreasedValue');
  }

  /// Returns the hint of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getHint() {
    return getDiagnosticProp<String>('hint');
  }

  /// Returns the attributedHint of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getAttributedHint() {
    return getDiagnosticProp<String>('attributedHint');
  }

  /// Returns the tooltip of the matched [Semantics] via [Widget.toDiagnosticsNode]
  String getTooltip() {
    return getDiagnosticProp<String>('tooltip');
  }

  /// Returns the textDirection of the matched [Semantics] via [Widget.toDiagnosticsNode]
  TextDirection getTextDirection() {
    return getDiagnosticProp<TextDirection>('textDirection');
  }

  /// Returns the sortKey of the matched [Semantics] via [Widget.toDiagnosticsNode]
  SemanticsSortKey getSortKey() {
    return getDiagnosticProp<SemanticsSortKey>('sortKey');
  }

  /// Returns the hintOverrides of the matched [Semantics] via [Widget.toDiagnosticsNode]
  SemanticsHintOverrides getHintOverrides() {
    return getDiagnosticProp<SemanticsHintOverrides>('hintOverrides');
  }

  /// Returns the renderObject of the matched [Semantics] via [Widget.toDiagnosticsNode]
  RenderSemanticsAnnotations getRenderObject() {
    return getDiagnosticProp<RenderSemanticsAnnotations>('renderObject');
  }
}
