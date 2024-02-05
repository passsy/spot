import 'package:checks/checks.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';

export 'package:checks/context.dart';

/// A representation of a single [Widget] found by a [WidgetSnapshot]
/// with direct access to its [element] and the original [selector].
///
/// Provides access to the underlying [Element], [WidgetSelector], and the
/// widget instance itself for more detailed assertions and manipulations.
///
/// For [WidgetSnapshot] with multiple matched widgets, use [MultiWidgetMatcher].
abstract class WidgetMatcher<W extends Widget> {
  /// The [Element] associated with the matched widget.
  Element get element;

  /// The [WidgetSelector] that was used to find this widget.
  WidgetSelector<W> get selector;

  /// The actual widget instance of type [W] that was matched.
  W get widget;

  /// Factory constructor to create a [WidgetMatcher] from an [Element] and a
  /// [WidgetSelector].
  factory WidgetMatcher({
    required Element element,
    required WidgetSelector<W> selector,
  }) = _WidgetMatcherImpl;

  /// Factory constructor to create a [WidgetMatcher] from a [WidgetSnapshot].
  factory WidgetMatcher.fromSnapshot(WidgetSnapshot<W> snapshot) =
      _WidgetMatcherFromSnapshot;
}

class _WidgetMatcherImpl<W extends Widget> implements WidgetMatcher<W> {
  _WidgetMatcherImpl({
    required this.element,
    required this.selector,
  });

  @override
  final Element element;

  @override
  final WidgetSelector<W> selector;

  @override
  W get widget => selector.mapElementToWidget(element);
}

class _WidgetMatcherFromSnapshot<W extends Widget> implements WidgetMatcher<W> {
  _WidgetMatcherFromSnapshot(this.snapshot);

  final WidgetSnapshot<W> snapshot;

  @override
  W get widget => snapshot.discoveredWidgets.first;

  @override
  Element get element => snapshot.discovered.single.element;

  @override
  WidgetSelector<W> get selector => snapshot.selector;
}

/// Extension on [WidgetMatcher]<W> providing additional matchers for
/// widgets of type [W].
///
/// These matchers facilitate more specific assertions on widget properties,
/// element properties, and render object properties.
extension WidgetMatcherExtensions<W extends Widget> on WidgetMatcher<W> {
  /// Allows checking for properties of [Element] that are stored in child
  /// [Widget]s or in the state.
  /// Use [selector] to extract the actual value and validate it with [match].
  ///
  /// #### Example usage:
  /// ```dart
  /// hasProp(
  ///   selector: (subject) => subject.context.nest<int?>(
  ///     () => ['has "maxLines"'],
  ///     (Element element) => Extracted.value(_extractMaxLines(element)),
  ///   ),
  ///   match: (maxLines) => maxLines.equals(1),
  /// );
  ///
  /// int? _extractMaxLines(Element element) {
  ///   element.requireWidgetType<Text>();
  ///   // every Text widget has a RichText child where the effective maxLines are set
  ///   final richTextElement =
  ///       element.children.firstWhere((e) => e.widget is RichText);
  ///   final richText = richTextElement.widget as RichText;
  ///   return richText.maxLines;
  /// }
  /// ```
  WidgetMatcher<W> hasProp<T>({
    @Deprecated('use elementSelector instead')
    Subject<T> Function(ConditionSubject<Element>)? selector,
    Subject<T> Function(ConditionSubject<Element>)? elementSelector,
    Subject<T> Function(Subject<W>)? widgetSelector,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<T> subject = () {
      if (selector != null) {
        return selector(conditionSubject);
      }
      if (elementSelector != null) {
        return elementSelector(conditionSubject);
      }
      assert(widgetSelector != null);

      if (widgetSelector != null) {
        final Subject<W> widgetSubject = conditionSubject.context.nest<W>(
          () => ['widget $W'],
          (element) {
            final widget = this.selector.mapElementToWidget(element);
            return Extracted.value(widget);
          },
        );
        return widgetSelector.call(widgetSubject);
      }

      throw ArgumentError(
        'Either elementSelector (former selector) or widgetSelector must be set',
      );
    }();

    match(subject);
    final failure = softCheckHideNull(element, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }

  /// Retrieves a specific property from the matched widget.
  ///
  /// Use this method to get a property value directly from the widget for
  /// further processing or assertions.
  T getWidgetProp<T>(NamedWidgetProp<W, T> prop) {
    final widget = selector.mapElementToWidget(element);
    return prop.get(widget);
  }

  /// Asserts that a widget's property meets a specific condition.
  ///
  /// This method is useful for making assertions on properties directly
  /// within the widget.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Checkbox>().existsOnce().hasWidgetProp(
  ///   prop: widgetProp('value', (widget) => widget.value),
  ///   match: (value) => value.isTrue(),
  /// );
  /// ```
  WidgetMatcher<W> hasWidgetProp<T>({
    required NamedWidgetProp<W, T?> prop,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<T> subject = conditionSubject.context.nest<T?>(
      () => ['$W', "with prop '${prop.name}'"],
      (element) {
        final value = getWidgetProp(prop);
        return Extracted.value(value);
      },
    ).hideNullability();

    match(subject);
    final failure = softCheckHideNull(element, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }

  /// Retrieves a specific property from the matched widget's element.
  ///
  /// Use this method to get a property value directly from the element of
  /// the widget for further processing or assertions.
  T getElementProp<T>(NamedElementProp<T> prop) {
    return prop.get(element);
  }

  /// Asserts that an element's property meets a specific condition.
  ///
  /// This method is useful for making assertions on properties within the
  /// element of the widget.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Checkbox>().existsOnce().hasElementProp(
  ///   prop: elementProp('value', (e) => (e.widget as Checkbox).value),
  ///   match: (it) => it.equals(true),
  /// );
  /// ```
  WidgetMatcher<W> hasElementProp<T>({
    required NamedElementProp<T?> prop,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<T> subject = conditionSubject.context.nest<T?>(
      () => ['Element of $W', "with prop '${prop.name}'"],
      (element) {
        final value = getElementProp(prop);
        return Extracted.value(value);
      },
    ).hideNullability();

    match(subject);
    final failure = softCheckHideNull(element, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }

  /// Retrieves a specific property from the matched widget's render object.
  ///
  /// Use this method to get a property value directly from the render object
  /// of the widget for further processing or assertions.
  T getRenderObjectProp<T, R extends RenderObject>(
    NamedRenderObjectProp<R, T> prop,
  ) {
    final renderObject = element.renderObject! as R;
    return prop.get(renderObject);
  }

  /// Asserts that a render object's property meets a specific condition.
  ///
  /// This method is useful for making assertions on properties within the
  /// render object of the widget.
  ///
  /// #### Example usage:
  /// ```dart
  /// final isComplexProp = renderObjectProp<bool?, RenderCustomPaint>(
  ///   'isComplex',
  ///   (r) => r.isComplex,
  /// );
  /// spot<Checkbox>().spot<CustomPaint>().existsOnce().hasRenderObjectProp(
  ///   prop: isComplexProp,
  ///   match: (it) => it.isFalse(),
  /// );
  /// ```
  WidgetMatcher<W> hasRenderObjectProp<T, R extends RenderObject>({
    required NamedRenderObjectProp<R, T?> prop,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<T> subject = conditionSubject.context.nest<T?>(
      () => ['RenderObject of $W', "with prop '${prop.name}'"],
      (element) {
        final value = getRenderObjectProp(prop);
        return Extracted.value(value);
      },
    ).hideNullability();

    match(subject);
    final failure = softCheckHideNull(element, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }
}

/// A representation of multiple [Widget]s found by a [WidgetSnapshot]
///
/// This class is used to handle multiple widgets that have been matched
/// by a [WidgetSnapshot], allowing for further assertions or operations
/// on each matched widget.
///
/// To match individual widgets use [WidgetMatcher]
class MultiWidgetMatcher<W extends Widget> {
  /// Constructs a [MultiWidgetMatcher] from a [WidgetSnapshot].
  ///
  /// This constructor takes a snapshot of matched widgets and creates a matcher
  /// for handling multiple widgets.
  const MultiWidgetMatcher.fromSnapshot(WidgetSnapshot<W> snapshot)
      : _snapshot = snapshot;

  /// The snapshot of widgets that this matcher is based on.
  ///
  /// [snapshot] contains the result of a widget selection process,
  /// encapsulating information about the widgets that matched the selector's criteria.
  final WidgetSnapshot<W> _snapshot;

  /// The actual widget instances of type [W] that were matched
  List<Widget> get widgets => _snapshot.discoveredWidgets;

  /// All [Element] associated with the matched widgets
  List<Element> get elements =>
      _snapshot.discovered.map((e) => e.element).toList();

  /// The [WidgetSelector] that was used to find this widget
  WidgetSelector<W> get selector => _snapshot.selector;

  /// Gets a list of [WidgetMatcher]s for each widget discovered in the
  /// snapshot.
  ///
  /// This list allows for individual assertions or operations on each matched
  /// widget. The items in the list are immutable to ensure consistent state.
  List<WidgetMatcher<W>> get discovered {
    final items = _snapshot.discovered.mapIndexed((index, element) {
      return WidgetMatcher(
        selector: _snapshot.selector.atIndex(index),
        element: element.element,
      );
    });
    return List.unmodifiable(items);
  }
}

/// Extension on [MultiWidgetMatcher]<W> providing matchers for assertions
/// on multiple widgets.
///
/// These matchers allow performing assertions on each widget in the set of
/// matched widgets.
extension MultiWidgetMatcherExtensions<W extends Widget>
    on MultiWidgetMatcher<W> {
  /// Asserts that at least one of the matched widgets
  /// fulfills the provided [matcher].
  ///
  /// If none of the matched widgets fulfill the [matcher],
  /// a [TestFailure] is thrown. This method is useful for cases when at least
  /// one widget is expected to meet a certain condition.
  MultiWidgetMatcher<W> any(void Function(WidgetMatcher<W>) matcher) {
    TestAsyncUtils.guardSync();
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }

    late String matcherDescription;
    final found = discovered.any((wm) {
      try {
        matcher(wm);
        return true;
      } catch (e) {
        matcherDescription =
            e is PropertyCheckFailure ? e.matcherDescription : e.toString();
        return false;
      }
    });

    if (found) {
      return this;
    }
    throw TestFailure(
      "Expected that at least one candidate fulfills matcher '$matcherDescription', but none did.",
    );
  }

  /// Asserts that all widgets in the matched set fulfill the provided [matcher].
  ///
  /// Applies [matcher] to each widget. If any fail, throws a [TestFailure]
  /// with details of the mismatches.
  MultiWidgetMatcher<W> all(void Function(WidgetMatcher<W>) matcher) {
    TestAsyncUtils.guardSync();
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }

    late String matcherDescription;
    final missMatches = discovered.whereNot((wm) {
      try {
        matcher(wm);
        return true;
      } catch (e) {
        matcherDescription =
            e is PropertyCheckFailure ? e.matcherDescription : e.toString();
        return false;
      }
    }).toList();

    if (missMatches.isEmpty) {
      return this;
    }
    throw TestFailure(
        "Expected that all candidates fulfill matcher '$matcherDescription', but only ${discovered.length - missMatches.length} of ${discovered.length} did.\n"
        'Mismatches: ${missMatches.map((e) => e.element.toStringDeep()).join(', ')}');
  }
}

/// Extension which throws a [PropertyCheckFailure] when a [CheckFailure] is detected.
extension ThrowCheckFailure on CheckFailure? {
  /// Throws a [PropertyCheckFailure] if the [CheckFailure] is not `null`.
  void throwPropertyCheckFailure<T>(
    ConditionSubject<T> conditionSubject,
    Object? actual,
  ) {
    if (this == null) {
      return;
    }
    final errorParts =
        describe(conditionSubject).map((it) => it.trim()).toList();
    final errorMessage = errorParts.join(' ');
    throw PropertyCheckFailure(
      'Failed to match widget: $errorMessage, actual: ${this!.rejection.actual.joinToString()}',
      matcherDescription: errorParts.skip(1).join(' ').removePrefix('with '),
    );
  }
}

/// Represents a failure in a property check within widget testing.
///
/// This exception is thrown when a property of a widget does not meet
/// the expected criteria defined in a matcher.
class PropertyCheckFailure extends TestFailure {
  /// Constructs a [PropertyCheckFailure] with a custom message and
  /// a description of the matcher that caused the failure.
  PropertyCheckFailure(
    super.message, {
    required this.matcherDescription,
  });

  /// Description of the matcher that led to this failure.
  final String matcherDescription;
}
