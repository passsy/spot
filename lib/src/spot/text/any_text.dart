import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/element_extensions.dart';
import 'package:spot/src/spot/selectors.dart';

/// A union type for any text widget that can be found in the widget tree.
/// Specifically this includes:
/// - [Text]
/// - [SelectableText]
/// - [RichText]
/// - [EditableText]
///
class AnyText extends Widget {
  const AnyText._();

  int? get maxLines {
    return 0;
  }

  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
// typedef AnyText = Widget;

class SingleAnyTextWidgetSelector extends SingleWidgetSelector<AnyText> {
  SingleAnyTextWidgetSelector({
    required super.props,
    super.children,
    super.parents,
  });

  @override
  List<ElementFilter> createElementFilters() {
    return super.createElementFilters()
      ..removeWhere((it) => it is WidgetTypeFilter);
  }
}

// class _AnyTextWidgetFilter<W extends Widget> implements ElementFilter {
//   static const allowedTypes = [
//     Text,
//     SelectableText,
//     RichText,
//     EditableText,
//   ];
//
//   @override
//   Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
//     return candidates
//         .where((WidgetTreeNode node) =>
//             allowedTypes.contains(node.element.widget.runtimeType))
//         .toList();
//   }
//
//   @override
//   String toString() {
//     return 'AnyTextWidgetFilter';
//   }
// }

extension AnyTextMatcher on WidgetMatcher<AnyText> {
  WidgetMatcher<AnyText> hasMaxLines(int? value) {
    return hasDiagnosticProp<int>(
      'maxLines',
      (it) {
        value == null ? it.isNull() : it.equals(value);
      },
    );
  }

  WidgetMatcher<AnyText> hasMaxLinesWhere(MatchProp<int?> match) {
    return hasProp(
      selector: (subject) => subject.context.nest<int?>(
        () => ['has "maxLines"'],
        (Element element) {
          final widget = element.widget;

          if (widget is Text) {
            return Extracted.value(widget.maxLines);
          }
          throw 'unsupported widget type ${widget.runtimeType}';
        },
      ),
      match: match.hideNullability(),
    );
  }

  WidgetMatcher<AnyText> hasEffectiveMaxLinesWhere(MatchProp<int?> match) {
    return hasProp(
      selector: (subject) => subject.context.nest<int?>(
        () => ['has "maxLines"'],
        (element) => Extracted.value(_extractMaxLines(element)),
      ),
      match: match.hideNullability(),
    );
  }

  WidgetMatcher<AnyText> hasEffectiveMaxLines(int? value) {
    return hasEffectiveMaxLinesWhere((it) => it.equals(value));
  }

  WidgetMatcher<AnyText> hasEffectiveTextStyleWhere(
    MatchProp<TextStyle> match,
  ) {
    return hasProp(
      selector: (subject) => subject.context.nest<TextStyle?>(
        () => ['has "textStyle"'],
        (Element element) => Extracted.value(_extractTextStyle(element)),
      ),
      match: match.hideNullability(),
    );
  }
}

extension AnyTextSelector on WidgetSelector<AnyText> {
  WidgetSelector<AnyText> withEffectiveMaxLinesMatching(MatchProp<int?> match) {
    return withProp(
      selector: (subject) => subject.context.nest<int?>(
        () => ['with "maxLines"'],
        (Element element) {
          final widget = element.widget;

          if (widget is Text) {
            return Extracted.value(widget.maxLines);
          }
          throw 'unsupported widget type ${widget.runtimeType}';
        },
      ),
      match: match,
    );
  }

  WidgetSelector<AnyText> withEffectiveMaxLines(int? value) {
    return withEffectiveMaxLinesMatching((it) => it.equals(value));
  }
}

int? _extractMaxLines(Element element) {
  element.requireWidgetType<Text>();
  // every Text widget has a RichText child where the effective maxLines are set
  final richTextElement =
      element.children.firstWhere((e) => e.widget is RichText);
  final richText = richTextElement.widget as RichText;
  return richText.maxLines;
}

TextStyle _extractTextStyle(Element element) {
  element.requireWidgetType<Text>();
  // every Text widget has a RichText child where
  final richTextElement =
      element.children.firstWhere((e) => e.widget is RichText);
  final richText = richTextElement.widget as RichText;
  return richText.text.style!;
}

extension on Element {
  void requireWidgetType<W extends Widget>() {
    if (widget is! W) {
      throw 'Require widget of type $W but got ${widget.runtimeType} from Element $this';
    }
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
