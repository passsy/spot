import 'package:checks/checks.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// A union type for any text widget that can be found in the widget tree.
/// Specifically this includes:
/// - [Text]
/// - [SelectableText]
/// - [RichText]
/// - [EditableText]
///
/// Consolidated attributes may, depending on the text widget type, include:
/// - [maxLines],
/// - [minLines],
/// - [textStyle],
/// - [text],
/// - [overflow],
/// - [softWrap],
/// - [textDirection],
/// - [textAlign],
/// - [locale],
/// - [selectionColor]
class AnyText extends LeafRenderObjectWidget {
  const AnyText._({
    required this.widget,
    this.maxLines,
    this.minLines,
    this.textStyle,
    this.text,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.textAlign,
    this.locale,
    this.selectionColor,
  });

  /// Factory constructor to create an [AnyText] instance from an [EditableText].
  ///
  /// This constructor is used to create an [AnyText] widget from the state of
  /// an [EditableText] widget. It extracts and consolidates various
  /// text-related properties from the [EditableText] for use in [AnyText].
  factory AnyText.fromEditableText(EditableTextState state) {
    final widget = state.widget;
    final InlineSpan text = state.renderEditable.text!;
    return AnyText._(
      widget: widget,
      textStyle: text.style,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      text: widget.controller.text,
      //overflow: https://github.com/flutter/flutter/issues/80434,
      //softWrap: https://github.com/flutter/flutter/issues/53166,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      locale: widget.locale,
      selectionColor: widget.selectionColor,
    );
  }

  /// Factory constructor to create an [AnyText] instance from a
  /// [RichText] widget.
  ///
  /// This constructor is used to create an [AnyText] widget from a [RichText]
  /// widget. It extracts and consolidates various text-related properties from
  /// the [RichText] for use in [AnyText].
  factory AnyText.fromRichText(RichText widget) {
    return AnyText._(
      widget: widget,
      textStyle: widget.text.style,
      maxLines: widget.maxLines,
      //minLines: https://github.com/flutter/flutter/issues/31134,
      text: widget.text.toPlainText(),
      overflow: widget.overflow,
      softWrap: widget.softWrap,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      locale: widget.locale,
      selectionColor: widget.selectionColor,
    );
  }

  /// The exact widget where the text was found
  final Widget widget;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [text] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any. If there is no ambient
  /// [Directionality], then this must not be null.
  final TextDirection? textDirection;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The number of lines before the text is truncated according to [overflow]
  ///
  /// `null` is valid and means that the text will not be truncated
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// The minimum number of lines for the text to span.
  ///
  /// When set, this ensures that the text takes up at least a certain number
  /// of lines, even if there's not enough text to fill them up.
  ///
  /// A value of `null` means there is no minimum constraint on the number of
  /// lines. This allows the text to naturally take up as much space as it
  /// needs, based on its content.
  ///
  /// When combined with [maxLines], it provides a range within which the text
  /// can vary in length. For example, setting both `minLines` and `maxLines`
  /// to the same value would enforce a fixed number of lines.
  final int? minLines;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  final bool? softWrap;

  /// The TextStyle applied to to this widget
  ///
  /// Usually already merged with the [DefaultTextStyle]
  final TextStyle? textStyle;

  /// The text displayed in this widget.
  ///
  /// When [RichText] includes widget using [WidgetSpan], it is included in the
  /// string as 'object replacement character' (0xFFFC) which looks like a
  /// whitespace in many fonts
  final String? text;

  /// How visual overflow should be handled.
  ///
  /// Not available for [SelectableText] and [EditableText] https://github.com/flutter/flutter/issues/80434
  final TextOverflow? overflow;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
    properties.add(
      EnumProperty<TextDirection>(
        'textDirection',
        textDirection,
        defaultValue: null,
      ),
    );
    properties.add(
      EnumProperty<TextAlign>(
        'textAlign',
        textAlign,
        defaultValue: TextAlign.start,
      ),
    );
    properties.add(ColorProperty('selectionColor', selectionColor));
    properties.add(
      FlagProperty(
        'softWrap',
        value: softWrap,
        ifTrue: 'wrapping at box width',
        ifFalse: 'no wrapping except at line break characters',
        showName: true,
      ),
    );
    properties.add(
      EnumProperty<TextOverflow>(
        'overflow',
        overflow,
        defaultValue: TextOverflow.clip,
      ),
    );
    properties.add(IntProperty('maxLines', maxLines, ifNull: 'unlimited'));
    properties
        .add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    textStyle?.debugFillProperties(properties, prefix: 'font_');

    // set default value for font_size
    final textSize = properties.properties.firstWhereOrNull((it) {
      return it.name == 'font_size';
    }) as DoubleProperty?;
    if (textSize != null) {
      properties.properties.remove(textSize);
      properties
          .add(DoubleProperty('font_size', textSize.value, defaultValue: 14.0));
    }
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderProxyBox();
  }
}

/// A [WidgetSelector] that matches any text on the screen, including:
/// - [Text]
/// - [SelectableText]
/// - [RichText]
/// - [EditableText]
///
/// It uses a custom mapping function to convert an [Element] into an [AnyText]
/// widget, accommodating different types of text widgets.
///
/// This selector removes the [WidgetTypeFilter] during element filtering
/// as it matches multiple widget types.
class AnyTextWidgetSelector extends WidgetSelector<AnyText> {
  /// Constructs a [AnyTextWidgetSelector] with the following parameters:
  /// - `props`: Properties to match widgets.
  /// - `children`: Child selectors to include in the match.
  /// - `parents`: Parent selectors to include in the match.
  AnyTextWidgetSelector({
    required super.stages,
  }) : super(mapElementToWidget: _mapElementToAnyText);

  static AnyText _mapElementToAnyText(Element element) {
    if (element.widget is RichText) {
      // RichText is used by Text and SelectableText under the hood
      return AnyText.fromRichText(element.widget as RichText);
    }
    if (element.widget is EditableText) {
      final e = element as StatefulElement;
      final state = e.state as EditableTextState;
      return AnyText.fromEditableText(state);
    }
    throw ArgumentError(
      'Widget ${element.widget.toStringShort()} is not supported by AnyText',
    );
  }
}

/// Matches text widgets ([EditableText] and [RichText]) on screen.
///
/// This predicate is used to verify the presence and properties of text within
/// widgets. It extracts text data from the relevant widget and uses the
/// provided [match] function to assert the text content.
class MatchTextFilter implements ElementFilter {
  /// Constructs a [MatchTextFilter].
  ///
  /// The [match] function is used to assert the text content found in the
  /// relevant widget. The [description] provides a human-readable explanation
  /// of what this predicate checks.
  MatchTextFilter({
    required this.match,
    required this.description,
  });

  /// The function that asserts the text content.
  ///
  /// It receives a `Subject<String>` which contains the text to be asserted.
  void Function(Subject<String> it) match;

  @override
  final String description;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates.where((it) => _match(it.element));
  }

  bool _match(Element element) {
    try {
      final actual = _extractTextData(element);
      final subject = it<String?>();
      match(subject.hideNullability());
      final failure = softCheck(actual, subject);
      return failure == null;
    } on _UnsupportedWidgetTypeException {
      return false;
    }
  }

  String? _extractTextData(Element e) {
    if (e.widget is EditableText) {
      return (e.widget as EditableText).controller.text;
    }
    if (e.widget is RichText) {
      return (e.widget as RichText).text.toPlainText();
    }
    throw _UnsupportedWidgetTypeException(e.widget);
  }
}

class _UnsupportedWidgetTypeException implements Exception {
  _UnsupportedWidgetTypeException(this.widget);

  final Widget widget;

  @override
  String toString() {
    return 'UnsupportedWidgetTypeException: ${widget.toStringShort()}';
  }
}
