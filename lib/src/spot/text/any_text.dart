import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/query_stats.dart';

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

  /// Normalizes [text] to what a user visually perceives, so tests can match
  /// text without worrying about invisible or special whitespace characters.
  ///
  /// Invisible characters with no visible glyph (zero width space, soft
  /// hyphen, word joiner, BOM) are removed, and every Unicode space separator
  /// (such as the non-breaking space) is folded to a regular space. Characters
  /// that carry meaning (zero width joiner, bidi controls, the [WidgetSpan]
  /// placeholder) and line structure (tabs, line breaks) are left untouched.
  ///
  /// This powers the forgiving matching of [spotText] and the `whereText` /
  /// `withText` / `hasText` selectors. To match the exact characters of a
  /// widget, use the raw variants (`whereRawText` / `withRawText` /
  /// `hasRawText`).
  static String normalizeVisibleText(String text) {
    StringBuffer? result;
    for (var i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      final removed = _invisibleCodeUnits.contains(codeUnit);
      final foldedToSpace =
          !removed && _spaceSeparatorCodeUnits.contains(codeUnit);
      if (!removed && !foldedToSpace) {
        result?.writeCharCode(codeUnit);
        continue;
      }
      // First special character: copy the untouched prefix into the buffer.
      result ??= StringBuffer(text.substring(0, i));
      if (foldedToSpace) {
        result.write(' ');
      }
      // Removed characters are simply not written.
    }
    return result?.toString() ?? text;
  }

  /// Extracts the text from a text widget [element].
  ///
  /// Supports the text widgets spot recognizes: [EditableText] and [RichText],
  /// which backs [Text] and [SelectableText]. Returns `null` for any other
  /// widget.
  static AnyTextContent? extractText(Element element) {
    final widget = element.widget;
    if (widget is EditableText) {
      return AnyTextContent(widget.controller.text);
    }
    if (widget is RichText) {
      return AnyTextContent(widget.text.toPlainText());
    }
    return null;
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
    final rawText = text;
    final normalizedText =
        rawText == null ? null : normalizeVisibleText(rawText);
    // 'text' is normalized so matching ignores invisible/special whitespace
    // (see [normalizeVisibleText]), while 'rawText' keeps the exact characters.
    // Both are always added so the generator emits the `text` and `rawText`
    // selector families.
    properties.add(StringProperty('text', normalizedText));
    properties.add(StringProperty('rawText', rawText));
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
    properties.add(
      ColorProperty(
        'selectionColor',
        selectionColor,
        defaultValue: null,
      ),
    );
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
    final textSize = properties.properties.firstOrNullWhere((it) {
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

  @override
  String toStringShort() {
    return widget.toStringShort();
  }
}

/// The text content of a text widget, available both as written ([raw]) and
/// in a [normalized] form (see [AnyText.normalizeVisibleText]) suitable for
/// matching. Returned by [AnyText.extractText].
class AnyTextContent {
  /// Creates an [AnyTextContent] from the [raw] text of a widget.
  AnyTextContent(this.raw);

  /// The text exactly as found in the widget, including invisible and special
  /// whitespace characters.
  final String raw;

  /// The [raw] text run through [AnyText.normalizeVisibleText], matching what
  /// a user visually perceives. Computed lazily and cached.
  late final String normalized = AnyText.normalizeVisibleText(raw);

  @override
  String toString() => 'AnyTextContent(raw: "$raw", normalized: "$normalized")';
}

/// Code units that have no visible glyph and no semantic effect on plain
/// text. [AnyText.normalizeVisibleText] removes them entirely.
///
/// Other invisible characters are deliberately **not** included because they
/// carry meaning and removing them would change how the text renders:
/// - `U+200C`/`U+200D` Zero Width Non-Joiner / Joiner drive emoji sequences
///   (e.g. family emojis) and Indic/Arabic shaping.
/// - `U+200E`/`U+200F` and other bidirectional controls change the visual
///   order of mixed left-to-right and right-to-left text.
/// - `U+FFFC` Object Replacement Character represents an embedded [WidgetSpan]
///   and is meaningful content, not whitespace.
const _invisibleCodeUnits = {
  0x200B, // ZERO WIDTH SPACE: inserted to allow line breaks (flutter#18761)
  0x00AD, // SOFT HYPHEN: invisible break hint, only renders when broken
  0x2060, // WORD JOINER: invisible no-break glue
  0xFEFF, // ZERO WIDTH NO-BREAK SPACE / BOM: invisible, often a stray prefix
};

/// Code units of Unicode Space_Separator (`Zs`) characters other than the
/// regular space. [AnyText.normalizeVisibleText] folds them to a regular space
/// because they all render as a blank of some width.
///
/// Each code point is listed explicitly (instead of a range) so a reader
/// wondering what happens to e.g. `U+2004` can find it by searching the repo.
///
/// Tabs and line breaks (`U+0009`, `U+000A`, `U+000D`, ...) are intentionally
/// left untouched: they are visually distinct structure, not spaces.
const _spaceSeparatorCodeUnits = {
  0x00A0, // NO-BREAK SPACE: glues words/units onto the same line
  0x1680, // OGHAM SPACE MARK
  0x2000, // EN QUAD
  0x2001, // EM QUAD
  0x2002, // EN SPACE
  0x2003, // EM SPACE
  0x2004, // THREE-PER-EM SPACE
  0x2005, // FOUR-PER-EM SPACE
  0x2006, // SIX-PER-EM SPACE
  0x2007, // FIGURE SPACE
  0x2008, // PUNCTUATION SPACE
  0x2009, // THIN SPACE
  0x200A, // HAIR SPACE
  0x202F, // NARROW NO-BREAK SPACE: common in number/currency/locale formats
  0x205F, // MEDIUM MATHEMATICAL SPACE
  0x3000, // IDEOGRAPHIC SPACE: full-width CJK space
};

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
    this.normalizeText = true,
  });

  /// The function that asserts the text content.
  ///
  /// It receives a `Subject<String>` which contains the text to be asserted.
  void Function(Subject<String> it) match;

  @override
  final String description;

  /// When `true` (the default) [match] receives the [AnyTextContent.normalized]
  /// text, ignoring invisible and special whitespace. When `false` it receives
  /// the [AnyTextContent.raw] text, matching the exact characters.
  final bool normalizeText;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates.where((it) {
      QueryStats.candidateChecks++;
      return _match(it.element);
    });
  }

  bool _match(Element element) {
    final content = AnyText.extractText(element);
    if (content == null) {
      // Not a text widget this filter understands.
      return false;
    }
    final actual = normalizeText ? content.normalized : content.raw;
    final failure = softCheck(actual, match.hideNullability());
    return failure == null;
  }

  @override
  String toString() {
    return 'MatchTextFilter which keeps $description';
  }
}
