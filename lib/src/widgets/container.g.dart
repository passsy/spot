// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [Container] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<Container>().printMatchers(propNameOverrides: {'fg': 'foreground'}, {'bg': 'background'});
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Allows filtering [Container] by the properties provided via [Diagnosticable.debugFillProperties]
extension ContainerSelector on WidgetSelector<Container> {
  /// Creates a [WidgetSelector] that finds all [Container] where alignment matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereAlignment((it) => it.equals(Alignment.center)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereAlignment(MatchProp<AlignmentGeometry> match) {
    return withDiagnosticProp<AlignmentGeometry>('alignment', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where alignment equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withAlignment(Alignment.center).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withAlignment(AlignmentGeometry? value) {
    return withDiagnosticProp<AlignmentGeometry>(
        'alignment', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where padding matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().wherePadding((it) => it.equals(EdgeInsets.all(8.0))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> wherePadding(MatchProp<EdgeInsetsGeometry> match) {
    return withDiagnosticProp<EdgeInsetsGeometry>('padding', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where padding equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withPadding(EdgeInsets.all(8.0)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withPadding(EdgeInsetsGeometry? value) {
    return withDiagnosticProp<EdgeInsetsGeometry>(
        'padding', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where clipBehavior matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereClipBehavior((it) => it.equals(Clip.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereClipBehavior(MatchProp<Clip> match) {
    return withDiagnosticProp<Clip>('clipBehavior', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where clipBehavior equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withClipBehavior(Clip.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withClipBehavior(Clip? value) {
    return withDiagnosticProp<Clip>(
        'clipBehavior', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where background matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereBackground((it) => it.equals(BoxDecoration(color: Colors.blue))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereBackground(MatchProp<Decoration> match) {
    return withDiagnosticProp<Decoration>('bg', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where background equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withBackground(BoxDecoration(color: Colors.blue)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withBackground(Decoration? value) {
    return withDiagnosticProp<Decoration>(
        'bg', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where foreground matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereForeground((it) => it.equals(BoxDecoration(color: Colors.blue))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereForeground(MatchProp<Decoration> match) {
    return withDiagnosticProp<Decoration>('fg', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where foreground equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withForeground(BoxDecoration(color: Colors.blue)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withForeground(Decoration? value) {
    return withDiagnosticProp<Decoration>(
        'fg', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where constraints matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereConstraints((it) => it.equals(BoxConstraints.tight(Size(100, 100)))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereConstraints(MatchProp<BoxConstraints> match) {
    return withDiagnosticProp<BoxConstraints>('constraints', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where constraints equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withConstraints(BoxConstraints.tight(Size(100, 100))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withConstraints(BoxConstraints? value) {
    return withDiagnosticProp<BoxConstraints>(
        'constraints', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where margin matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereMargin((it) => it.equals(EdgeInsets.all(8.0))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereMargin(MatchProp<EdgeInsetsGeometry> match) {
    return withDiagnosticProp<EdgeInsetsGeometry>('margin', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where margin equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withMargin(EdgeInsets.all(8.0)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withMargin(EdgeInsetsGeometry? value) {
    return withDiagnosticProp<EdgeInsetsGeometry>(
        'margin', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Container] where transform matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().whereTransform((it) => it.equals(Matrix4.identity())).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> whereTransform(MatchProp<Matrix4> match) {
    return withDiagnosticProp<Matrix4>('transform', match);
  }

  /// Creates a [WidgetSelector] that finds all [Container] where transform equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().withTransform(Matrix4.identity()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Container> withTransform(Matrix4? value) {
    return withDiagnosticProp<Matrix4>(
        'transform', (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [Container] provided via [Diagnosticable.debugFillProperties]
extension ContainerMatcher on WidgetMatcher<Container> {
  /// Expects that alignment of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasAlignmentWhere((it) => it.equals(Alignment.center));
  /// ```
  WidgetMatcher<Container> hasAlignmentWhere(
      MatchProp<AlignmentGeometry> match) {
    return hasDiagnosticProp<AlignmentGeometry>('alignment', match);
  }

  /// Expects that alignment of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasAlignment(Alignment.center);
  /// ```
  WidgetMatcher<Container> hasAlignment(AlignmentGeometry? value) {
    return hasDiagnosticProp<AlignmentGeometry>(
        'alignment', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that padding of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasPaddingWhere((it) => it.equals(EdgeInsets.all(8.0)));
  /// ```
  WidgetMatcher<Container> hasPaddingWhere(
      MatchProp<EdgeInsetsGeometry> match) {
    return hasDiagnosticProp<EdgeInsetsGeometry>('padding', match);
  }

  /// Expects that padding of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasPadding(EdgeInsets.all(8.0));
  /// ```
  WidgetMatcher<Container> hasPadding(EdgeInsetsGeometry? value) {
    return hasDiagnosticProp<EdgeInsetsGeometry>(
        'padding', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that clipBehavior of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasClipBehaviorWhere((it) => it.equals(Clip.values.first));
  /// ```
  WidgetMatcher<Container> hasClipBehaviorWhere(MatchProp<Clip> match) {
    return hasDiagnosticProp<Clip>('clipBehavior', match);
  }

  /// Expects that clipBehavior of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasClipBehavior(Clip.values.first);
  /// ```
  WidgetMatcher<Container> hasClipBehavior(Clip? value) {
    return hasDiagnosticProp<Clip>(
        'clipBehavior', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that background of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasBackgroundWhere((it) => it.equals(BoxDecoration(color: Colors.blue)));
  /// ```
  WidgetMatcher<Container> hasBackgroundWhere(MatchProp<Decoration> match) {
    return hasDiagnosticProp<Decoration>('bg', match);
  }

  /// Expects that background of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasBackground(BoxDecoration(color: Colors.blue));
  /// ```
  WidgetMatcher<Container> hasBackground(Decoration? value) {
    return hasDiagnosticProp<Decoration>(
        'bg', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that foreground of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasForegroundWhere((it) => it.equals(BoxDecoration(color: Colors.blue)));
  /// ```
  WidgetMatcher<Container> hasForegroundWhere(MatchProp<Decoration> match) {
    return hasDiagnosticProp<Decoration>('fg', match);
  }

  /// Expects that foreground of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasForeground(BoxDecoration(color: Colors.blue));
  /// ```
  WidgetMatcher<Container> hasForeground(Decoration? value) {
    return hasDiagnosticProp<Decoration>(
        'fg', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that constraints of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasConstraintsWhere((it) => it.equals(BoxConstraints.tight(Size(100, 100))));
  /// ```
  WidgetMatcher<Container> hasConstraintsWhere(
      MatchProp<BoxConstraints> match) {
    return hasDiagnosticProp<BoxConstraints>('constraints', match);
  }

  /// Expects that constraints of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasConstraints(BoxConstraints.tight(Size(100, 100)));
  /// ```
  WidgetMatcher<Container> hasConstraints(BoxConstraints? value) {
    return hasDiagnosticProp<BoxConstraints>(
        'constraints', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that margin of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasMarginWhere((it) => it.equals(EdgeInsets.all(8.0)));
  /// ```
  WidgetMatcher<Container> hasMarginWhere(MatchProp<EdgeInsetsGeometry> match) {
    return hasDiagnosticProp<EdgeInsetsGeometry>('margin', match);
  }

  /// Expects that margin of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasMargin(EdgeInsets.all(8.0));
  /// ```
  WidgetMatcher<Container> hasMargin(EdgeInsetsGeometry? value) {
    return hasDiagnosticProp<EdgeInsetsGeometry>(
        'margin', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that transform of [Container] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasTransformWhere((it) => it.equals(Matrix4.identity()));
  /// ```
  WidgetMatcher<Container> hasTransformWhere(MatchProp<Matrix4> match) {
    return hasDiagnosticProp<Matrix4>('transform', match);
  }

  /// Expects that transform of [Container] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce().hasTransform(Matrix4.identity());
  /// ```
  WidgetMatcher<Container> hasTransform(Matrix4? value) {
    return hasDiagnosticProp<Matrix4>(
        'transform', (it) => value == null ? it.isNull() : it.equals(value));
  }
}
