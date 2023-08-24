import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/selectors.dart';

/// A union type for any text widget that can be found in the widget tree.
/// Specifically this includes:
/// - [Text]
/// - [SelectableText]
/// - [RichText]
/// - [EditableText]
///
class AnyText extends Widget {
  const AnyText._({
    this.maxLines,
    this.textStyle,
    this.text,
  });

  factory AnyText.fromEditableText(EditableText widget) {
    return AnyText._(
      textStyle: widget.style,
      maxLines: widget.maxLines,
      text: widget.controller.text,
    );
  }
  factory AnyText.fromRichText(RichText widget) {
    return AnyText._(
      textStyle: widget.text.style,
      maxLines: widget.maxLines,
      text: widget.text.toPlainText(),
    );
  }

  final int? maxLines;

  final TextStyle? textStyle;

  final String? text;

  @override
  Element createElement() {
    throw UnimplementedError();
  }
}

/// A [WidgetSelector] that matches any text on the screen, including:
/// - [Text]
/// - [SelectableText]
/// - [RichText]
/// - [EditableText]
class SingleAnyTextWidgetSelector extends SingleWidgetSelector<AnyText> {
  SingleAnyTextWidgetSelector({
    required super.props,
    super.children,
    super.parents,
  }) : super(mapElementToWidget: _mapElementToAnyText);

  static AnyText _mapElementToAnyText(Element element) {
    if (element.widget is RichText) {
      // RichText is used by Text and SelectableText under the hood
      return AnyText.fromRichText(element.widget as RichText);
    }
    if (element.widget is EditableText) {
      return AnyText.fromEditableText(element.widget as EditableText);
    }
    throw ArgumentError(
      'Widget ${element.widget.toStringShort()} is not supported by AnyText',
    );
  }

  @override
  List<ElementFilter> createElementFilters() {
    return super.createElementFilters()
      // Matches multiple widget types, can't filter by synthetic type AnyText
      ..removeWhere((it) => it is WidgetTypeFilter);
  }
}

extension AnyTextMatcher on WidgetMatcher<AnyText> {
  WidgetMatcher<AnyText> hasMaxLines(int? value) {
    return hasMaxLinesWhere((it) => it.equals(value));
  }

  WidgetMatcher<AnyText> hasMaxLinesWhere(MatchProp<int?> match) {
    return hasProp<int?>(
      widgetSelector: (Subject<AnyText> widget) {
        return widget.context.nest<int?>(
          () => ['has maxLines'],
          (AnyText widget) {
            return Extracted.value(widget.maxLines);
          },
        );
      },
      match: match,
    );
  }

  WidgetMatcher<AnyText> hasText(String value) {
    return hasTextWhere((it) => it.equals(value));
  }

  WidgetMatcher<AnyText> hasTextWhere(MatchProp<String?> match) {
    return hasProp<String?>(
      widgetSelector: (Subject<AnyText> widget) {
        return widget.context.nest<String?>(
          () => ['has text'],
          (AnyText widget) {
            return Extracted.value(widget.text);
          },
        );
      },
      match: match.hideNullability(),
    );
  }

  WidgetMatcher<AnyText> hasTextStyle(TextStyle value) {
    return hasTextStyleWhere((it) => it.equals(value));
  }

  WidgetMatcher<AnyText> hasTextStyleWhere(MatchProp<TextStyle?> match) {
    return hasProp<TextStyle?>(
      widgetSelector: (Subject<AnyText> widget) {
        return widget.context.nest<TextStyle?>(
          () => ['has textStyle'],
          (AnyText widget) {
            return Extracted.value(widget.textStyle);
          },
        );
      },
      match: match.hideNullability(),
    );
  }
}

extension AnyTextSelector on WidgetSelector<AnyText> {
  WidgetSelector<AnyText> withMaxLines(int? value) {
    return withMaxLinesMatching((it) => it.equals(value));
  }

  WidgetSelector<AnyText> withMaxLinesMatching(MatchProp<int?> match) {
    return withProp(
      widgetSelector: (subject) => subject.context.nest<int?>(
        () => ['with "maxLines"'],
        (AnyText widget) {
          return Extracted.value(widget.maxLines);
        },
      ),
      match: match,
    );
  }

  WidgetSelector<AnyText> withText(String value) {
    return withTextMatching((it) => it.equals(value));
  }

  WidgetSelector<AnyText> withTextMatching(MatchProp<String?> match) {
    return withProp(
      widgetSelector: (subject) => subject.context.nest<String?>(
        () => ['with "text"'],
        (AnyText widget) {
          return Extracted.value(widget.text);
        },
      ),
      match: match.hideNullability(),
    );
  }

  WidgetSelector<AnyText> withTextStyle(TextStyle value) {
    return withTextStyleMatching((it) => it.equals(value));
  }

  WidgetSelector<AnyText> withTextStyleMatching(MatchProp<TextStyle?> match) {
    return withProp(
      widgetSelector: (subject) => subject.context.nest<TextStyle?>(
        () => ['with "textStyle"'],
        (AnyText widget) {
          return Extracted.value(widget.textStyle);
        },
      ),
      match: match.hideNullability(),
    );
  }
}

class MatchTextPredicate implements PredicateWithDescription {
  MatchTextPredicate({
    required this.match,
    required this.description,
  });

  void Function(Subject<String> it) match;

  @override
  final String description;

  @override
  bool Function(Element e) get predicate => _match;

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
