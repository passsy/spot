// ignore_for_file: require_trailing_commas, directives_ordering
// coverage:ignore-file

/// Matchers for [Image] auto-generated by spot
///
/// Can be generated with:
/// ```dart
/// spot<Image>().printMatchers(propNameOverrides: {'this.excludeFromSemantics': 'excludeFromSemantics'}, {'thisExcludeFromSemantics': 'excludeFromSemantics'});
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

/// Allows filtering [Image] by the properties provided via [Diagnosticable.debugFillProperties]
extension ImageSelector on WidgetSelector<Image> {
  /// Creates a [WidgetSelector] that finds all [Image] where image matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereImage((it) => it.equals(NetworkImage('https://example.com/image.png'))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereImage(MatchProp<ImageProvider<Object>> match) {
    return withDiagnosticProp<ImageProvider<Object>>('image', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where image equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withImage(NetworkImage('https://example.com/image.png')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withImage(ImageProvider<Object>? value) {
    return withDiagnosticProp<ImageProvider<Object>>(
        'image', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where frameBuilder matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereFrameBuilder((it) => it.equals(() {})).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereFrameBuilder(MatchProp<Function> match) {
    return withDiagnosticProp<Function>('frameBuilder', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where frameBuilder equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withFrameBuilder(() {}).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withFrameBuilder(Function? value) {
    return withDiagnosticProp<Function>(
        'frameBuilder', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where loadingBuilder matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereLoadingBuilder((it) => it.equals(() {})).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereLoadingBuilder(MatchProp<Function> match) {
    return withDiagnosticProp<Function>('loadingBuilder', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where loadingBuilder equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withLoadingBuilder(() {}).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withLoadingBuilder(Function? value) {
    return withDiagnosticProp<Function>('loadingBuilder',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where width matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereWidth((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereWidth(MatchProp<double> match) {
    return withDiagnosticProp<double>('width', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where width equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withWidth(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withWidth(double? value) {
    return withDiagnosticProp<double>(
        'width', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where height matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereHeight((it) => it.isGreaterThan(10.5)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereHeight(MatchProp<double> match) {
    return withDiagnosticProp<double>('height', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where height equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withHeight(10.5).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withHeight(double? value) {
    return withDiagnosticProp<double>(
        'height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where color matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereColor((it) => it.equals(Colors.red)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereColor(MatchProp<Color> match) {
    return withDiagnosticProp<Color>('color', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where color equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withColor(Colors.red).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withColor(Color? value) {
    return withDiagnosticProp<Color>(
        'color', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where opacity matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereOpacity((it) => it.equals(null)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereOpacity(MatchProp<Animation<double>?> match) {
    return withDiagnosticProp<Animation<double>?>('opacity', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where opacity equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withOpacity(null).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withOpacity(Animation<double>? value) {
    return withDiagnosticProp<Animation<double>?>(
        'opacity', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where colorBlendMode matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereColorBlendMode((it) => it.equals(BlendMode.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereColorBlendMode(MatchProp<BlendMode> match) {
    return withDiagnosticProp<BlendMode>('colorBlendMode', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where colorBlendMode equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withColorBlendMode(BlendMode.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withColorBlendMode(BlendMode? value) {
    return withDiagnosticProp<BlendMode>('colorBlendMode',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where fit matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereFit((it) => it.equals(BoxFit.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereFit(MatchProp<BoxFit> match) {
    return withDiagnosticProp<BoxFit>('fit', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where fit equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withFit(BoxFit.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withFit(BoxFit? value) {
    return withDiagnosticProp<BoxFit>(
        'fit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where alignment matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereAlignment((it) => it.equals(Alignment.center)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereAlignment(MatchProp<AlignmentGeometry> match) {
    return withDiagnosticProp<AlignmentGeometry>('alignment', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where alignment equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withAlignment(Alignment.center).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withAlignment(AlignmentGeometry? value) {
    return withDiagnosticProp<AlignmentGeometry>(
        'alignment', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where repeat matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereRepeat((it) => it.equals(ImageRepeat.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereRepeat(MatchProp<ImageRepeat> match) {
    return withDiagnosticProp<ImageRepeat>('repeat', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where repeat equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withRepeat(ImageRepeat.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withRepeat(ImageRepeat? value) {
    return withDiagnosticProp<ImageRepeat>(
        'repeat', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where centerSlice matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereCenterSlice((it) => it.equals(Rect.fromLTWH(0, 0, 100, 100))).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereCenterSlice(MatchProp<Rect> match) {
    return withDiagnosticProp<Rect>('centerSlice', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where centerSlice equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withCenterSlice(Rect.fromLTWH(0, 0, 100, 100)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withCenterSlice(Rect? value) {
    return withDiagnosticProp<Rect>(
        'centerSlice', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where matchTextDirection matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereMatchTextDirection((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereMatchTextDirection(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('matchTextDirection', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where matchTextDirection equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withMatchTextDirection(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withMatchTextDirection(bool? value) {
    return withDiagnosticProp<bool>('matchTextDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where semanticLabel matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereSemanticLabel((it) => it.equals('foo')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereSemanticLabel(MatchProp<String> match) {
    return withDiagnosticProp<String>('semanticLabel', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where semanticLabel equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withSemanticLabel('foo').existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withSemanticLabel(String? value) {
    return withDiagnosticProp<String>('semanticLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where excludeFromSemantics matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereExcludeFromSemantics((it) => it.isTrue()).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereExcludeFromSemantics(MatchProp<bool> match) {
    return withDiagnosticProp<bool>('this.excludeFromSemantics', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where excludeFromSemantics equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withExcludeFromSemantics(true).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withExcludeFromSemantics(bool? value) {
    return withDiagnosticProp<bool>('this.excludeFromSemantics',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Creates a [WidgetSelector] that finds all [Image] where filterQuality matches the condition.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().whereFilterQuality((it) => it.equals(FilterQuality.values.first)).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> whereFilterQuality(MatchProp<FilterQuality> match) {
    return withDiagnosticProp<FilterQuality>('filterQuality', match);
  }

  /// Creates a [WidgetSelector] that finds all [Image] where filterQuality equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().withFilterQuality(FilterQuality.values.first).existsOnce();
  /// ```
  @useResult
  WidgetSelector<Image> withFilterQuality(FilterQuality? value) {
    return withDiagnosticProp<FilterQuality>('filterQuality',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Matchers for the properties of [Image] provided via [Diagnosticable.debugFillProperties]
extension ImageMatcher on WidgetMatcher<Image> {
  /// Expects that image of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasImageWhere((it) => it.equals(NetworkImage('https://example.com/image.png')));
  /// ```
  WidgetMatcher<Image> hasImageWhere(MatchProp<ImageProvider<Object>> match) {
    return hasDiagnosticProp<ImageProvider<Object>>('image', match);
  }

  /// Expects that image of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasImage(NetworkImage('https://example.com/image.png'));
  /// ```
  WidgetMatcher<Image> hasImage(ImageProvider<Object>? value) {
    return hasDiagnosticProp<ImageProvider<Object>>(
        'image', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that frameBuilder of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFrameBuilderWhere((it) => it.equals(() {}));
  /// ```
  WidgetMatcher<Image> hasFrameBuilderWhere(MatchProp<Function> match) {
    return hasDiagnosticProp<Function>('frameBuilder', match);
  }

  /// Expects that frameBuilder of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFrameBuilder(() {});
  /// ```
  WidgetMatcher<Image> hasFrameBuilder(Function? value) {
    return hasDiagnosticProp<Function>(
        'frameBuilder', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that loadingBuilder of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasLoadingBuilderWhere((it) => it.equals(() {}));
  /// ```
  WidgetMatcher<Image> hasLoadingBuilderWhere(MatchProp<Function> match) {
    return hasDiagnosticProp<Function>('loadingBuilder', match);
  }

  /// Expects that loadingBuilder of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasLoadingBuilder(() {});
  /// ```
  WidgetMatcher<Image> hasLoadingBuilder(Function? value) {
    return hasDiagnosticProp<Function>('loadingBuilder',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that width of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasWidthWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<Image> hasWidthWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('width', match);
  }

  /// Expects that width of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasWidth(10.5);
  /// ```
  WidgetMatcher<Image> hasWidth(double? value) {
    return hasDiagnosticProp<double>(
        'width', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that height of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasHeightWhere((it) => it.isGreaterThan(10.5));
  /// ```
  WidgetMatcher<Image> hasHeightWhere(MatchProp<double> match) {
    return hasDiagnosticProp<double>('height', match);
  }

  /// Expects that height of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasHeight(10.5);
  /// ```
  WidgetMatcher<Image> hasHeight(double? value) {
    return hasDiagnosticProp<double>(
        'height', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that color of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasColorWhere((it) => it.equals(Colors.red));
  /// ```
  WidgetMatcher<Image> hasColorWhere(MatchProp<Color> match) {
    return hasDiagnosticProp<Color>('color', match);
  }

  /// Expects that color of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasColor(Colors.red);
  /// ```
  WidgetMatcher<Image> hasColor(Color? value) {
    return hasDiagnosticProp<Color>(
        'color', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that opacity of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasOpacityWhere((it) => it.equals(null));
  /// ```
  WidgetMatcher<Image> hasOpacityWhere(MatchProp<Animation<double>?> match) {
    return hasDiagnosticProp<Animation<double>?>('opacity', match);
  }

  /// Expects that opacity of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasOpacity(null);
  /// ```
  WidgetMatcher<Image> hasOpacity(Animation<double>? value) {
    return hasDiagnosticProp<Animation<double>?>(
        'opacity', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that colorBlendMode of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasColorBlendModeWhere((it) => it.equals(BlendMode.values.first));
  /// ```
  WidgetMatcher<Image> hasColorBlendModeWhere(MatchProp<BlendMode> match) {
    return hasDiagnosticProp<BlendMode>('colorBlendMode', match);
  }

  /// Expects that colorBlendMode of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasColorBlendMode(BlendMode.values.first);
  /// ```
  WidgetMatcher<Image> hasColorBlendMode(BlendMode? value) {
    return hasDiagnosticProp<BlendMode>('colorBlendMode',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that fit of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFitWhere((it) => it.equals(BoxFit.values.first));
  /// ```
  WidgetMatcher<Image> hasFitWhere(MatchProp<BoxFit> match) {
    return hasDiagnosticProp<BoxFit>('fit', match);
  }

  /// Expects that fit of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFit(BoxFit.values.first);
  /// ```
  WidgetMatcher<Image> hasFit(BoxFit? value) {
    return hasDiagnosticProp<BoxFit>(
        'fit', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that alignment of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasAlignmentWhere((it) => it.equals(Alignment.center));
  /// ```
  WidgetMatcher<Image> hasAlignmentWhere(MatchProp<AlignmentGeometry> match) {
    return hasDiagnosticProp<AlignmentGeometry>('alignment', match);
  }

  /// Expects that alignment of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasAlignment(Alignment.center);
  /// ```
  WidgetMatcher<Image> hasAlignment(AlignmentGeometry? value) {
    return hasDiagnosticProp<AlignmentGeometry>(
        'alignment', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that repeat of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasRepeatWhere((it) => it.equals(ImageRepeat.values.first));
  /// ```
  WidgetMatcher<Image> hasRepeatWhere(MatchProp<ImageRepeat> match) {
    return hasDiagnosticProp<ImageRepeat>('repeat', match);
  }

  /// Expects that repeat of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasRepeat(ImageRepeat.values.first);
  /// ```
  WidgetMatcher<Image> hasRepeat(ImageRepeat? value) {
    return hasDiagnosticProp<ImageRepeat>(
        'repeat', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that centerSlice of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasCenterSliceWhere((it) => it.equals(Rect.fromLTWH(0, 0, 100, 100)));
  /// ```
  WidgetMatcher<Image> hasCenterSliceWhere(MatchProp<Rect> match) {
    return hasDiagnosticProp<Rect>('centerSlice', match);
  }

  /// Expects that centerSlice of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasCenterSlice(Rect.fromLTWH(0, 0, 100, 100));
  /// ```
  WidgetMatcher<Image> hasCenterSlice(Rect? value) {
    return hasDiagnosticProp<Rect>(
        'centerSlice', (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that matchTextDirection of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasMatchTextDirectionWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Image> hasMatchTextDirectionWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('matchTextDirection', match);
  }

  /// Expects that matchTextDirection of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasMatchTextDirection(true);
  /// ```
  WidgetMatcher<Image> hasMatchTextDirection(bool? value) {
    return hasDiagnosticProp<bool>('matchTextDirection',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that semanticLabel of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasSemanticLabelWhere((it) => it.equals('foo'));
  /// ```
  WidgetMatcher<Image> hasSemanticLabelWhere(MatchProp<String> match) {
    return hasDiagnosticProp<String>('semanticLabel', match);
  }

  /// Expects that semanticLabel of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasSemanticLabel('foo');
  /// ```
  WidgetMatcher<Image> hasSemanticLabel(String? value) {
    return hasDiagnosticProp<String>('semanticLabel',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that excludeFromSemantics of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasExcludeFromSemanticsWhere((it) => it.isTrue());
  /// ```
  WidgetMatcher<Image> hasExcludeFromSemanticsWhere(MatchProp<bool> match) {
    return hasDiagnosticProp<bool>('this.excludeFromSemantics', match);
  }

  /// Expects that excludeFromSemantics of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasExcludeFromSemantics(true);
  /// ```
  WidgetMatcher<Image> hasExcludeFromSemantics(bool? value) {
    return hasDiagnosticProp<bool>('this.excludeFromSemantics',
        (it) => value == null ? it.isNull() : it.equals(value));
  }

  /// Expects that filterQuality of [Image] matches the condition in [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFilterQualityWhere((it) => it.equals(FilterQuality.values.first));
  /// ```
  WidgetMatcher<Image> hasFilterQualityWhere(MatchProp<FilterQuality> match) {
    return hasDiagnosticProp<FilterQuality>('filterQuality', match);
  }

  /// Expects that filterQuality of [Image] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Image>().existsOnce().hasFilterQuality(FilterQuality.values.first);
  /// ```
  WidgetMatcher<Image> hasFilterQuality(FilterQuality? value) {
    return hasDiagnosticProp<FilterQuality>('filterQuality',
        (it) => value == null ? it.isNull() : it.equals(value));
  }
}

/// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
extension ImageGetter on WidgetMatcher<Image> {
  /// Returns the image of the matched [Image] via [Widget.toDiagnosticsNode]
  ImageProvider<Object> getImage() {
    return getDiagnosticProp<ImageProvider<Object>>('image');
  }

  /// Returns the frameBuilder of the matched [Image] via [Widget.toDiagnosticsNode]
  Function getFrameBuilder() {
    return getDiagnosticProp<Function>('frameBuilder');
  }

  /// Returns the loadingBuilder of the matched [Image] via [Widget.toDiagnosticsNode]
  Function getLoadingBuilder() {
    return getDiagnosticProp<Function>('loadingBuilder');
  }

  /// Returns the width of the matched [Image] via [Widget.toDiagnosticsNode]
  double getWidth() {
    return getDiagnosticProp<double>('width');
  }

  /// Returns the height of the matched [Image] via [Widget.toDiagnosticsNode]
  double getHeight() {
    return getDiagnosticProp<double>('height');
  }

  /// Returns the color of the matched [Image] via [Widget.toDiagnosticsNode]
  Color getColor() {
    return getDiagnosticProp<Color>('color');
  }

  /// Returns the opacity of the matched [Image] via [Widget.toDiagnosticsNode]
  Animation<double>? getOpacity() {
    return getDiagnosticProp<Animation<double>?>('opacity');
  }

  /// Returns the colorBlendMode of the matched [Image] via [Widget.toDiagnosticsNode]
  BlendMode getColorBlendMode() {
    return getDiagnosticProp<BlendMode>('colorBlendMode');
  }

  /// Returns the fit of the matched [Image] via [Widget.toDiagnosticsNode]
  BoxFit getFit() {
    return getDiagnosticProp<BoxFit>('fit');
  }

  /// Returns the alignment of the matched [Image] via [Widget.toDiagnosticsNode]
  AlignmentGeometry getAlignment() {
    return getDiagnosticProp<AlignmentGeometry>('alignment');
  }

  /// Returns the repeat of the matched [Image] via [Widget.toDiagnosticsNode]
  ImageRepeat getRepeat() {
    return getDiagnosticProp<ImageRepeat>('repeat');
  }

  /// Returns the centerSlice of the matched [Image] via [Widget.toDiagnosticsNode]
  Rect getCenterSlice() {
    return getDiagnosticProp<Rect>('centerSlice');
  }

  /// Returns the matchTextDirection of the matched [Image] via [Widget.toDiagnosticsNode]
  bool getMatchTextDirection() {
    return getDiagnosticProp<bool>('matchTextDirection');
  }

  /// Returns the semanticLabel of the matched [Image] via [Widget.toDiagnosticsNode]
  String getSemanticLabel() {
    return getDiagnosticProp<String>('semanticLabel');
  }

  /// Returns the excludeFromSemantics of the matched [Image] via [Widget.toDiagnosticsNode]
  bool getExcludeFromSemantics() {
    return getDiagnosticProp<bool>('this.excludeFromSemantics');
  }

  /// Returns the filterQuality of the matched [Image] via [Widget.toDiagnosticsNode]
  FilterQuality getFilterQuality() {
    return getDiagnosticProp<FilterQuality>('filterQuality');
  }
}
