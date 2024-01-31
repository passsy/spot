import 'package:checks/checks.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/snapshot.dart' as snapshot_file show snapshot;
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/text/any_text.dart';

export 'package:checks/context.dart';

/// Root of a [WidgetSelector] chain.
///
/// Do not use this class directly, instead use the top-level entrypoints like
/// - [spot]
/// - [spotKey]
/// - [spotText]
/// - [spotTextWhere]
/// - [spotIcon]
/// - [spotWidget]
/// - [spotElement]
class Spot with ChainableSelectors<Widget> {
  /// Creates a starting point for a [WidgetSelector] chain.
  const Spot();

  @override
  WidgetSelector? get self => null;
}

/// A mixin that provides chainable builder methods to create a [WidgetSelector].
mixin ChainableSelectors<T extends Widget> {
  /// The [WidgetSelector] the chainable methods build upon.
  ///
  /// This is `null` for the root of the chain.
  WidgetSelector<T>? get self;

  /// Creates a [WidgetSelector] that matches a all Widgets of
  /// type [W] that are in the scope of the parent [WidgetSelector].
  ///
  /// This selector compares the Widgets by runtimeType rather than by super
  /// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
  /// does not accidentally match a [Center] Widget, that extends [Align].
  ///
  /// ### Example usage:
  /// ```dart
  /// final appbar = spot<MaterialApp>().spot<Scaffold>().spot<AppBar>();
  /// ```
  @useResult
  WidgetSelector<W> spot<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final selector = WidgetSelector<W>(
      props: [
        WidgetTypePredicate<W>(),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );

    return selector;
  }

  /// Creates a [WidgetSelector] that matches a single Widgets of
  /// type [W] that is in the scope of the parent [WidgetSelector].
  ///
  /// This selector compares the Widgets by runtimeType rather than by super
  /// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
  /// does not accidentally match a [Center] Widget, that extends [Align].
  ///
  /// ### Example usage:
  /// ```dart
  /// final appbar = spotSingle<MaterialApp>()
  ///   .spotSingle<Scaffold>()
  ///   .spotSingle<AppBar>();
  /// ```
  @useResult
  @Deprecated('Use spot<W>().atMost(1)')
  WidgetSelector<W> spotSingle<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spot<W>(parents: parents, children: children).atMost(1);
  }

  /// Creates a [WidgetSelector] that finds [widget] by identity and returns all
  /// occurrences of it in the widget tree
  ///
  /// The comparison happens by identity (===)
  @useResult
  WidgetSelector<W> spotWidget<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector<W>(
      props: [
        WidgetTypePredicate<W>(),
        PredicateWithDescription(
          (Element e) => identical(e.widget, widget),
          description: 'Widget === $widget',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds [widget] by identity and returns
  /// only that widget
  ///
  /// The comparison happens by identity (===)
  @useResult
  @Deprecated('Use spotWidget().atMost(1)')
  WidgetSelector<W> spotSingleWidget<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotWidgets<W>(widget, parents: parents, children: children)
        .atMost(1);
  }

  /// Creates a [WidgetSelector] that finds all [widget] by identity
  ///
  /// The comparison happens by identity (===)
  @useResult
  @Deprecated('Use spotWidget().atMost(1)')
  WidgetSelector<W> spotWidgets<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotWidget<W>(widget, parents: parents, children: children);
  }

  /// Creates a [WidgetSelector] that finds the widget that is associated with
  /// [element]
  ///
  /// The comparison happens by identity (===)
  @useResult
  WidgetSelector<W> spotElement<W extends Widget>(
    Element element, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector<W>(
      props: [
        WidgetTypePredicate<W>(),
        PredicateWithDescription(
          (Element e) => identical(e, element),
          description: 'Element === $element',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds text within the parent
  ///
  /// [spotText] compares text using 'contains'. For more control over the
  /// comparison, use [spotTextWhere] or set [exact] to `true`.
  ///
  /// This method combines finding of [Text], [EditableText] and [SelectableText]
  /// widgets. Ultimately, all widgets show text as [RichText] widget.
  ///
  /// For assertions against specific text widgets and their properties, use the
  /// normal [spot] method and set the text widget type as generic type argument.
  ///
  /// #### Example usage:
  /// ```dart
  /// final welcome = spot<Text>().whereText((it) => it.equals("Hello"));
  /// welcome.first().snapshot().hasMaxLines(1).hasTextAlign(TextAlign.center);
  /// ```
  @useResult
  WidgetSelector<AnyText> spotText(
    Pattern text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool exact = false,
  }) {
    if (exact) {
      if (text is! String) {
        throw ArgumentError(
          'Patterns are not supported for exact matching',
        );
      }
      return spotTextWhere(
        (it) => it.equals(text),
        description: 'with text "$text"',
        parents: parents,
        children: children,
      );
    }

    // default with contains
    return spotTextWhere(
      (it) => it.contains(text),
      description: 'contains text "$text"',
      parents: parents,
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds text matching [match] in the parent
  ///
  /// ``` dart
  /// Text('Hello World');
  ///
  /// // all match the Text widget above
  /// spotTextWhere((it) => it.equals('Hello World'));
  /// spotTextWhere((it) => it.startsWith('Hello'));
  /// spotTextWhere((it) => it.endsWith('World!'));
  /// spotTextWhere((it) => it.contains('Wo'));
  /// spotText('Wo');
  /// ```
  @useResult
  WidgetSelector<AnyText> spotTextWhere(
    void Function(Subject<String>) match, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    String? description,
  }) {
    final String name = description ??
        () {
          final ConditionSubject<String> subject = it();
          match(subject);
          return describe(subject).map((it) => it.trim()).toList().join(' ');
        }();
    return AnyTextWidgetSelector(
      props: [
        MatchTextPredicate(
          match: (it) => match(it),
          description: 'Widget with text $name',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds a single [Text], [EditableText] or
  /// [RichText] where [text] is the content
  @Deprecated(
    'Use spotText("Hello") or '
    'spot<Text>().whereText((it) => it.equals("Hello")).first() instead',
  )
  @useResult
  WidgetSelector<W> spotSingleText<W extends Widget>(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return spotTexts<W>(
      text,
      parents: parents,
      children: children,
      findRichText: findRichText,
    ).atMost(1);
  }

  /// Creates a [WidgetSelector] that finds all [Text], [EditableText] or
  /// [RichText] where [text] is the content
  @Deprecated(
    'Use spotText("Hello") or '
    'spot<Text>().whereText((it) => it.equals("Hello")) instead',
  )
  @useResult
  WidgetSelector<W> spotTexts<W extends Widget>(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return WidgetSelector<W>(
      props: [
        WidgetTypePredicate<W>(),
        PredicateWithDescription(
          (Element e) {
            if (e.widget is Text) {
              final actual = (e.widget as Text).data;
              return actual == text;
            }
            if (e.widget is SelectableText) {
              final actual = (e.widget as SelectableText).data;
              return actual == text;
            }
            if (e.widget is EditableText) {
              final actual = (e.widget as EditableText).controller.text;
              return actual == text;
            }
            if (findRichText == true && e.widget is RichText) {
              final actual = (e.widget as RichText).text.toPlainText();
              return actual == text;
            }
            return false;
          },
          description: 'Widget with exact text: "$text"',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds all [Icon] widgets showing [icon]
  @useResult
  WidgetSelector<Icon> spotIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector(
      props: [
        WidgetTypePredicate<Icon>(),
        PredicateWithDescription(
          (Element e) {
            if (e.widget is Icon) {
              return (e.widget as Icon).icon == icon;
            }
            return false;
          },
          description: 'Widget with icon: "$icon"',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds a single [Icon] based on the [icon]
  @useResult
  @Deprecated('Use spotIcon().atMost(1)')
  WidgetSelector<Icon> spotSingleIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotIcon(
      icon,
      skipOffstage: skipOffstage,
      parents: parents,
      children: children,
    ).atMost(1);
  }

  /// Creates a [WidgetSelector] that finds all [Icon] widgets based on the [icon]
  @useResult
  @Deprecated('Use spotIcon()')
  WidgetSelector<Icon> spotIcons(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotIcon(
      icon,
      skipOffstage: skipOffstage,
      parents: parents,
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds widgets with the given [key].
  ///
  /// Example usage:
  /// ```dart
  /// spot<Center>().spotKey(const ValueKey('key')).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> spotKey<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector(
      props: [
        WidgetTypePredicate<W>(),
        PredicateWithDescription(
          (element) => element.widget.key == key,
          description: 'with key: "$key"',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  /// Creates a [WidgetSelector] that finds a single widget with the given [key].
  @useResult
  @Deprecated('Use spotKey().atMost(1)')
  WidgetSelector<W> spotSingleKey<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotKey<W>(
      key,
      parents: parents,
      children: children,
    ).atMost(1);
  }

  /// Creates a [WidgetSelector] that finds all widgets with the given [key]
  @useResult
  @Deprecated('Use spotKey()')
  WidgetSelector<W> spotKeys<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotKey<W>(
      key,
      parents: parents,
      children: children,
    );
  }

  /// Selects the first of n widgets
  ///
  /// "first" is neither the top-most or the bottom-most widget. Instead, it is
  /// the widget that was found first during a depth-first search of the widget
  /// tree.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Center>().first().spotText('Pepe').existsOnce();
  /// ```
  @useResult
  WidgetSelector<T> first() {
    // TODO add names to the elementFilters, for a better WidgetSelector.toString()
    return self!.copyWith(elementFilters: [_FirstElement()]);
  }

  /// Selects the last of n widgets
  ///
  /// "last" is neither the top-most or the bottom-most widget. Instead, it is
  /// the widget that was found last during a depth-first search of the widget
  /// tree.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Center>().last().spotText('Pepe').existsOnce();
  /// ```
  @useResult
  WidgetSelector<T> last() {
    return self!.copyWith(elementFilters: [_LastElement()]);
  }

  /// Selects the widget at a specified [index] in the list of found widgets.
  ///
  /// #### Example usage:
  ///```dart
  /// spot<YourWidgetType>().atIndex(2) // Selects the third widget
  ///```
  @useResult
  WidgetSelector<T> atIndex(int index) {
    return self!.copyWith(elementFilters: [_ElementAtIndex(index)]);
  }
}

class _FirstElement extends ElementFilter {
  _FirstElement();

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final first = candidates.firstOrNull;
    if (first == null) {
      return [];
    }
    return [first];
  }

  @override
  String get description => ':first';
}

class _LastElement extends ElementFilter {
  _LastElement();

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final last = candidates.lastOrNull;
    if (last == null) {
      return [];
    }
    return [last];
  }

  @override
  String get description => ':last';
}

class _ElementAtIndex extends ElementFilter {
  _ElementAtIndex(this.index);

  final int index;

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final element = candidates.elementAtOrNull(index);
    if (element == null) {
      return [];
    }
    return [element];
  }

  @override
  String get description => ':index($index)';
}

/// Extension on [WidgetSelector<W>] for advanced widget querying.
///
/// Adds methods to refine widget selections based on elements, widgets,
/// and their properties. Filters are applied during the snapshotting
/// of the selector, enabling precise widget selection.
///
/// Each method requires a predicate and a description for clear
/// error messages and precise selection.
extension SelectorQueries<W extends Widget> on WidgetSelector<W> {
  /// Creates a filter for the discovered elements which is applied when the
  /// [WidgetSelector] is snapshotted.
  ///
  /// The [description] is required to make error messages understandable.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Checkbox>()
  ///   .whereElement(
  ///     (el) => (el.widget as Checkbox).value == true,
  ///     description: 'is checked',
  ///   ).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereElement(
    bool Function(Element element) predicate, {
    required String description,
  }) {
    return self.copyWith(
      props: [
        ...self.props,
        PredicateWithDescription(
          (Element e) => predicate(e),
          description: description,
        ),
      ],
    );
  }

  /// Creates a filter for the widgets of the discovered elements which is
  /// applied when the [WidgetSelector] is snapshotted.
  ///
  /// The [description] is required to make error messages understandable
  ///
  /// #### Example usage:
  /// ```dart
  /// spotSingle<Checkbox>()
  ///   .whereWidget(
  ///     (widget) => widget.value == true,
  ///     description: 'isChecked',
  ///   ).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereWidget(
    bool Function(W widget) predicate, {
    required String description,
  }) {
    return self.copyWith(
      props: [
        ...self.props,
        PredicateWithDescription(
          (Element element) {
            final widget = self.mapElementToWidget(element);
            return predicate(widget);
          },
          description: description,
        ),
      ],
    );
  }
}

/// Abstract class representing a matcher for a widget of type [W].
///
/// Provides access to the underlying [Element], [WidgetSelector], and the
/// widget instance itself for more detailed assertions and manipulations.
abstract class WidgetMatcher<W extends Widget> {
  /// The [Element] associated with the matched widget.
  Element get element;

  /// The [WidgetSelector<W>] that was used to find this widget.
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
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => ['$W', "with prop '${prop.name}'"],
      (element) {
        final nonNullable =
            widgetProp<W, T>(prop.name, (widget) => prop.get(widget)!);
        final value = getWidgetProp(nonNullable);
        return Extracted.value(value);
      },
    );

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
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => ['Element of $W', "with prop '${prop.name}'"],
      (element) {
        final nonNullable =
            elementProp<T>(prop.name, (element) => prop.get(element)!);
        final value = getElementProp(nonNullable);
        return Extracted.value(value);
      },
    );

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
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => ['RenderObject of $W', "with prop '${prop.name}'"],
      (element) {
        final nonNullable =
            renderObjectProp<T, R>(prop.name, (element) => prop.get(element)!);
        final value = getRenderObjectProp(nonNullable);
        return Extracted.value(value);
      },
    );

    match(subject);
    final failure = softCheckHideNull(element, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }
}

extension ThrowCheckFailure on CheckFailure? {
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

/// A predicate that checks if an element's widget is of a specific type [W].
///
/// This class is a specialized version of [PredicateWithDescription] that
/// is used to filter widgets by their type.
class WidgetTypePredicate<W extends Widget>
    implements PredicateWithDescription {
  /// Constructs a [WidgetTypePredicate] for the widget type [W].
  WidgetTypePredicate();

  @override
  String get description => '$W';

  @override
  bool Function(Element e) get predicate => (e) => e.widget is W;

  @override
  String toString() {
    return 'WidgetTypePredicate<$W>()';
  }
}

/// Extension on [WidgetSelector<W>] to create snapshots of the current
/// widget selection.
///
/// Provides methods to create a snapshot of the widgets currently selected by
/// the selector, which can then be used for further analysis or assertions.
extension SelectorToSnapshot<W extends Widget> on WidgetSelector<W> {
  /// Creates a snapshot of the currently selected widgets.
  ///
  /// This method captures the current state of the widgets selected by the
  /// selector for further analysis or assertions.
  WidgetSnapshot<W> snapshot() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this, validateQuantity: false);
  }

  /// Modifies the selector to match an unconstrained number of widgets.
  ///
  /// This method returns a new selector that does not impose any constraints
  /// on the number of widgets it can match.
  @useResult
  WidgetSelector<W> get multi {
    return overrideQuantityConstraint(QuantityConstraint.unconstrained);
  }

  /// Modifies the selector to match at most one widget.
  @Deprecated('Use .atMost(1) or .amount(1)')
  @useResult
  WidgetSelector<W> get single {
    return atMost(1);
  }
}

/// Extension on [WidgetSelector<W>] to provide easy access to the single
/// widget, element, or render object in the current selection.
///
/// These convenience methods are intended for use with selectors that are
/// expected to match exactly one widget.
extension ReadSingleSnapshot<W extends Widget> on WidgetSelector<W> {
  /// Convenience getter to access the [Widget] when evaluating the [WidgetSelector]
  W snapshotWidget() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this).single.widget;
  }

  /// Convenience getter to access the [Element] when evaluating the [WidgetSelector]
  Element snapshotElement() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this).single.element;
  }

  /// Convenience getter to access the [RenderObject] when evaluating the [WidgetSelector]
  RenderObject snapshotRenderObject() {
    TestAsyncUtils.guardSync();
    // There is not a single Element in the Flutter SDK that returns null for `renderObject`.
    // So we can safely assume that this cast never fails.
    return snapshot_file.snapshot(this).single.element.renderObject!;
  }
}

/// Extension on [WidgetSelector<W>] providing methods to specify the
/// quantity of widgets to select.
/// These methods allow setting specific quantity constraints for the
/// selection of widgets.
extension QuantitySelectors<W extends Widget> on WidgetSelector<W> {
  /// Sets the selector to match exactly [n] widgets.
  WidgetSelector<W> amount(int n) {
    return self.overrideQuantityConstraint(QuantityConstraint.exactly(n));
  }

  /// Sets the selector to match at least [n] widgets.
  WidgetSelector<W> atLeast(int n) {
    return self.overrideQuantityConstraint(QuantityConstraint.atLeast(n));
  }

  /// Sets the selector to match at most [n] widgets.
  WidgetSelector<W> atMost(int n) {
    return self.overrideQuantityConstraint(QuantityConstraint.atMost(n));
  }

  /// Overrides the current quantity constraint with a new [constraint].
  ///
  /// This method allows for more flexible control over the number of widgets
  /// the selector should match.
  WidgetSelector<W> overrideQuantityConstraint(QuantityConstraint constraint) {
    return self.copyWith(quantityConstraint: constraint);
  }
}

/// Extension on [WidgetSelector<W>] providing matchers to assert on the
/// quantity of selected widgets.
///
/// These matchers enable assertions on whether a certain number
/// of widgets exist.
extension QuantityMatchers<W extends Widget> on WidgetSelector<W> {
  /// Asserts that at least one widget of type [W] exists.
  ///
  /// This matcher is used when the expectation is to have one or more
  /// widgets of type [W] present in the widget tree.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsAtLeastOnce();
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsExactlyNTimes] asserts that exactly `n` widgets of type [W] exist.
  /// - [existsAtLeastNTimes] asserts that at least `n` widgets of type [W] exist.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  /// - [existsAtMostNTimes] asserts that at most `n` widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtLeastOnce() {
    TestAsyncUtils.guardSync();
    final atLeastOne =
        copyWith(quantityConstraint: const QuantityConstraint.atLeast(1));
    return snapshot(atLeastOne).multi;
  }

  /// Asserts that at most one widget of type [W] exists.
  ///
  /// This matcher is useful for scenarios where either one or no widget
  /// of type [W] should be present.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsAtMostOnce();
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsExactlyNTimes] asserts that exactly `n` widgets of type [W] exist.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtLeastNTimes] asserts that at least `n` widgets of type [W] exist.
  /// - [existsAtMostNTimes] asserts that at most `n` widgets of type [W] exist.
  WidgetMatcher<W> existsAtMostOnce() {
    TestAsyncUtils.guardSync();
    final atMostOne = copyWith(quantityConstraint: QuantityConstraint.single);
    return snapshot(atMostOne).single;
  }

  /// Asserts that no widgets of type [W] exist.
  ///
  /// This method does not return a matcher but directly verifies that
  /// no widgets are found.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().doesNotExist();
  /// ```
  /// #### See also:
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsExactlyNTimes] asserts that exactly `n` widgets of type [W] exist.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtLeastNTimes] asserts that at least `n` widgets of type [W] exist.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  /// - [existsAtMostNTimes] asserts that at most `n` widgets of type [W] exist.
  void doesNotExist() {
    TestAsyncUtils.guardSync();
    final none = copyWith(quantityConstraint: QuantityConstraint.zero);
    snapshot(none);
  }

  /// Asserts that exactly one widget of type [W] exists.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsOnce();
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsExactlyNTimes] asserts that exactly `n` widgets of type [W] exist.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtLeastNTimes] asserts that at least `n` widgets of type [W] exist.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  /// - [existsAtMostNTimes] asserts that at most `n` widgets of type [W] exist.
  WidgetMatcher<W> existsOnce() {
    TestAsyncUtils.guardSync();
    final one =
        copyWith(quantityConstraint: const QuantityConstraint.exactly(1));
    return snapshot(one).single;
  }

  /// Asserts that exactly [n] widgets of type [W] exist.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsExactlyNTimes(2);
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtLeastNTimes] asserts that at least [n] widgets of type [W] exist.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  /// - [existsAtMostNTimes] asserts that at most [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsExactlyNTimes(int n) {
    TestAsyncUtils.guardSync();
    final exactlyNTimes =
        copyWith(quantityConstraint: QuantityConstraint.exactly(n));
    return snapshot(exactlyNTimes).multi;
  }

  /// Asserts that at least [n] widgets of type [W] exist.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsAtLeastNTimes(2);
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsExactlyNTimes] asserts that exactly [n] widgets of type [W] exist.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  /// - [existsAtMostNTimes] asserts that at most [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtLeastNTimes(int n) {
    TestAsyncUtils.guardSync();
    final atLeast = copyWith(quantityConstraint: QuantityConstraint.atLeast(n));
    return snapshot(atLeast).multi;
  }

  /// Asserts that at most [n] widgets of type [W] exist.
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<ElevatedButton>().existsAtMostNTimes(2);
  /// ```
  /// #### See also:
  /// - [doesNotExist] asserts that no widgets of type [W] exist.
  /// - [existsOnce] asserts that exactly one widget of type [W] exists.
  /// - [existsExactlyNTimes] asserts that exactly [n] widgets of type [W] exist.
  /// - [existsAtLeastOnce] asserts that at least one widget of type [W] exists.
  /// - [existsAtLeastNTimes] asserts that at least [n] widgets of type [W] exist.
  /// - [existsAtMostOnce] asserts that at most one widget exists.
  MultiWidgetMatcher<W> existsAtMostNTimes(int n) {
    TestAsyncUtils.guardSync();
    final atMostN = copyWith(quantityConstraint: QuantityConstraint.atMost(n));
    return snapshot(atMostN).multi;
  }
}

/// Extensions that control the parent/children widgets of a [WidgetSelector]
extension RelativeSelectors<W extends Widget> on WidgetSelector<W> {
  /// Returns a [WidgetSelector] that requires [parent] to be a parent of the
  /// widget to match.
  ///
  /// #### Example usage:
  /// ```dart
  ///  final containers = spot<Container>();
  ///  containers.withParent(spot<Wrap>()).existsOnce()
  /// ```
  /// #### See also:
  /// - [withParents] requires [parents] to be parents of the widget to match.
  /// - [withChild] requires [child] to be a child of the widget to match.
  /// - [withChildren] requires [children] to be children of the widget to match.
  @useResult
  WidgetSelector<W> withParent(WidgetSelector parent) {
    return copyWith(parents: [...parents, parent]);
  }

  /// Returns a [WidgetSelector] that requires [parents] to be parents of the
  /// widget to match.
  ///
  /// #### Example usage:
  /// ```dart
  ///  final containers = spot<Container>();
  ///  containers.withParents([spot<Wrap>()]).existsOnce();
  /// ```
  /// #### See also:
  /// - [withParent] requires [parent] to be a parent of the widget to match.
  /// - [withChild] requires [child] to be a child of the widget to match.
  /// - [withChildren] requires [children] to be children of the widget to match.
  @useResult
  WidgetSelector<W> withParents(List<WidgetSelector> parents) {
    return copyWith(parents: [...this.parents, ...parents]);
  }

  /// Returns a [WidgetSelector] that requires [child] to be a child of the
  /// widget to match.
  ///
  /// #### Example usage:
  /// ```dart
  ///  final containers = spot<Container>();
  ///  containers.witchChild(spot<Wrap>()).existsOnce();
  /// ```
  /// #### See also:
  /// - [withParent] requires [parent] to be a parent of the widget to match.
  /// - [withParents] requires [parents] to be parents of the widget to match.
  /// - [withChildren] requires [children] to be children of the widget to match.
  @useResult
  WidgetSelector<W> withChild(WidgetSelector child) {
    return copyWith(children: [...children, child]);
  }

  /// Returns a [WidgetSelector] that requires [children] to be children of the
  /// widget to match.
  ///
  /// #### Example usage:
  /// ```dart
  /// final containers = spot<Container>();
  /// containers.withChildren([spot<Wrap>()]).existsOnce();
  /// ```
  /// #### See also:
  /// - [withParent] requires [parent] to be a parent of the widget to match.
  /// - [withParents] requires [parents] to be parents of the widget to match.
  /// - [withChild] requires [child] to be a child of the widget to match.
  @useResult
  WidgetSelector<W> withChildren(List<WidgetSelector> children) {
    return copyWith(children: [...this.children, ...children]);
  }
}

/// Represents a matcher for multiple widgets of type [W].
///
/// This class is used to handle multiple widgets that have been matched
/// by a [WidgetSnapshot], allowing for further assertions or operations
/// on each matched widget.
class MultiWidgetMatcher<W extends Widget> {
  /// Constructs a [MultiWidgetMatcher] from a [WidgetSnapshot].
  ///
  /// This constructor takes a snapshot of matched widgets and creates a matcher
  /// for handling multiple widgets.
  const MultiWidgetMatcher.fromSnapshot(this.snapshot);

  /// The snapshot of widgets that this matcher is based on.
  ///
  /// [snapshot] contains the result of a widget selection process,
  /// encapsulating information about the widgets that matched the selector's criteria.
  final WidgetSnapshot<W> snapshot;

  /// Gets a list of [WidgetMatcher]s for each widget discovered in the
  /// snapshot.
  ///
  /// This list allows for individual assertions or operations on each matched
  /// widget. The items in the list are immutable to ensure consistent state.
  List<WidgetMatcher<W>> get discovered {
    final items = snapshot.discovered.mapIndexed((index, element) {
      return WidgetMatcher(
        selector: snapshot.selector.atIndex(index),
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
extension MutliMatchers<W extends Widget> on MultiWidgetMatcher<W> {
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
