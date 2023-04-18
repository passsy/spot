import 'package:checks/checks.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

extension TextSelector on WidgetSelector<Text> {
  WidgetSelector<Text> withText(String text) {
    return withProp<String>(
      'text',
      (s) => text == s,
      description: 'text = "$text"',
    );
  }

  WidgetSelector<Text> containsText(Pattern text) {
    return withProp2<String>(
        'text', (Subject<String> it) => it..contains(text));
  }

  WidgetSelector<Text> text(void Function(Subject<String>) matcher) {
    return withProp2<String>('text', matcher);
  }

  WidgetSelector<Text> startsWith(Pattern text) {
    return whereText(
      (s) => s?.startsWith(text) ?? false,
      description: 'starting with "$text"',
    );
  }

  WidgetSelector<Text> whereText(
    bool Function(String? text) predicate, {
    required String description,
  }) {
    return whereWidget(
      (widget) => predicate(widget.data),
      description: description,
      // errorDescription: (element) =>
      //     'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
    );
  }

  WidgetSelector<Text> withMaxLines(int? maxLines) {
    return whereWidget(
      (widget) => widget.maxLines == maxLines,
      description: 'maxLines: $maxLines',
    );
  }
}

extension TextWidgetSelector on WidgetMatcher<Text> {
  WidgetMatcher<Text> hasText(String text) {
    if (widget.data != text) {
      throw TestFailure(
        'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
      );
    }
    return this;
  }

  WidgetMatcher<Text> endsWith(String text) {
    if (widget.data?.endsWith(text) ?? false) {
      throw TestFailure(
        'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
      );
    }
    return this;
  }

  WidgetMatcher<Text> hasTextSize(int size) {
    // TODO
    final richText = collectAllElementsFrom(element, skipOffstage: true)
        .firstOrNullWhere((element) => element.widget is RichText)
        ?.widget as RichText?;

    final style = richText!.text.style;
    if (style!.fontSize != size) {
      throw TestFailure(
        'Expected to find text with size "$size" but found "${style.fontSize}" at ${selector.toStringBreadcrumb()}',
      );
    }

    // if (widget.style?.endsWith(text) ?? false) {
    //   throw TestFailure(
    //     'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
    //   );
    // }
    return this;
  }

  WidgetMatcher<Text> containsText(String text) {
    if (widget.data != text) {
      throw TestFailure(
        'Expected to find text "$text" but found "${widget.data}" at ${selector.toStringBreadcrumb()}',
      );
    }
    return this;
  }

  WidgetMatcher<Text> hasMaxLines(int? maxLines) {
    if (widget.maxLines != maxLines) {
      throw TestFailure(
        'Expected to find text with maxLines "$maxLines" but found "${widget.maxLines}" at ${selector.toStringBreadcrumb()}',
      );
    }
    // final elements = this.elements;
    // for (final element in elements) {
    //   final textWidget = element.widget as Text;
    //   if (textWidget.data != text) {
    //     throw TestFailure(
    //       'Expected to find text "$text" but found "${textWidget.data}" at ${toStringBreadcrumb()}',
    //     );
    //   }
    // }
    return this;
  }
}
