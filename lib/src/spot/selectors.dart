import 'package:checks/checks.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/snapshot.dart' as snapshot_file show snapshot;
import 'package:spot/src/spot/snapshot.dart';
import 'package:spot/src/spot/text/any_text.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

export 'package:checks/context.dart';

/// Root of a [WidgetSelector] chain.
///
/// Do not use this class directly, instead use the top-level entrypoints like
/// - [spot]
/// - [spotSingle]
/// - [spotText]
/// - [spotWidgets]
/// - [spotKeys]
class Spot with Selectors<Widget> {
  /// Creates a starting point for a [WidgetSelector] chain.
  const Spot();

  @override
  WidgetSelector? get self => null;
}

/// A mixin that provides chainable builder methods to create a [WidgetSelector].
mixin Selectors<T extends Widget> {
  /// The [WidgetSelector] the chainable methods build upon.
  ///
  /// This is `null` for the root of the chain.
  WidgetSelector<T>? get self;

  /// Creates a [WidgetSelector] that matches a single Widgets of
  /// type [W] that is in the scope of the parent [WidgetSelector].
  ///
  /// This selector compares the Widgets by runtimeType rather than by super
  /// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
  /// does not accidentally match a [Center] Widget, that extends [Align].
  ///
  /// ```dart
  /// final appbar = spotSingle<MaterialApp>()
  ///    .spotSingle<Scaffold>()
  ///    .spotSingle<AppBar>()
  /// ```
  @useResult
  SingleWidgetSelector<W> spotSingle<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spot<W>(parents: parents, children: children).single;
  }

  /// Creates a [WidgetSelector] that matches a all Widgets of
  /// type [W] that are in the scope of the parent [WidgetSelector].
  ///
  /// This selector compares the Widgets by runtimeType rather than by super
  /// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
  /// does not accidentally match a [Center] Widget, that extends [Align].
  ///
  /// ```dart
  /// final appbar = spot<MaterialApp>().spot<Scaffold>().spot<AppBar>()
  /// ```
  @useResult
  MultiWidgetSelector<W> spot<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final selector = MultiWidgetSelector<W>(
      props: [
        WidgetTypePredicate<W>(),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );

    return selector;
  }

  /// Creates a [WidgetSelector] that finds [widget] by identity and returns
  /// only that widget
  ///
  /// The comparison happens by identity (===)
  @useResult
  SingleWidgetSelector<W> spotSingleWidget<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotWidgets<W>(
      widget,
      parents: [if (self != null) self!, ...parents],
      children: children,
    ).single;
  }

  /// Creates a [WidgetSelector] that finds all [widget] by identity
  ///
  /// The comparison happens by identity (===)
  @useResult
  MultiWidgetSelector<W> spotWidgets<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector<W>(
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

  /// Creates a [WidgetSelector] that finds the widget that is associated with
  /// [element]
  ///
  /// The comparison happens by identity (===)
  @useResult
  SingleWidgetSelector<W> spotElement<W extends Widget>(
    Element element, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return SingleWidgetSelector<W>(
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
  /// ```dart
  /// final welcome = spot<Text>().whereText((it) => it.equals("Hello"));
  /// welcome.first().snapshot().hasMaxLines(1).hasTextAlign(TextAlign.center);
  /// ```
  @useResult
  SingleWidgetSelector<AnyText> spotText(
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
  SingleWidgetSelector<AnyText> spotTextWhere(
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
    return SingleAnyTextWidgetSelector(
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
  SingleWidgetSelector<W> spotSingleText<W extends Widget>(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return spotTexts<W>(
      text,
      parents: [if (self != null) self!, ...parents],
      children: children,
      findRichText: findRichText,
    ).single;
  }

  /// Creates a [WidgetSelector] that finds all [Text], [EditableText] or
  /// [RichText] where [text] is the content
  @Deprecated(
    'Use spotText("Hello") or '
    'spot<Text>().whereText((it) => it.equals("Hello")) instead',
  )
  @useResult
  MultiWidgetSelector<W> spotTexts<W extends Widget>(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return MultiWidgetSelector<W>(
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

  /// Creates a [WidgetSelector] that finds a single [Icon] based on the [icon]
  @useResult
  SingleWidgetSelector<Icon> spotSingleIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotIcons(
      icon,
      parents: [if (self != null) self!, ...parents],
      children: children,
    ).single;
  }

  /// Creates a [WidgetSelector] that finds all [Icon] widgets based on the [icon]
  @useResult
  MultiWidgetSelector<Icon> spotIcons(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector(
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

  /// Creates a [WidgetSelector] that finds a single widget with the given [key]
  @useResult
  SingleWidgetSelector<W> spotSingleKey<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotKeys<W>(
      key,
      parents: [if (self != null) self!, ...parents],
      children: children,
    ).single;
  }

  /// Creates a [WidgetSelector] that finds all widgets with the given [key]
  @useResult
  MultiWidgetSelector<W> spotKeys<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector(
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

  @useResult
  WidgetSelector<W> cast<W extends Widget>() {
    return WidgetSelector<W>(
      props: self!.props,
      parents: self!.parents,
      children: self!.children,
      expectedQuantity: self!.expectedQuantity,
    );
  }

  /// Selects the first of n widgets
  ///
  /// "first" is neither the top-most or the bottom-most widget. Instead, it is
  /// the widget that was found first during a depth-first search of the widget
  /// tree
  @useResult
  SingleWidgetSelector<T> first() {
    return FirstWidgetSelector<T>(
      props: self!.props,
      parents: self!.parents,
      children: self!.children,
    );
  }

  /// Selects the last of n widgets
  ///
  /// "last" is neither the top-most or the bottom-most widget. Instead, it is
  /// the widget that was found last during a depth-first search of the widget
  /// tree
  @useResult
  SingleWidgetSelector<T> last() {
    return LastWidgetSelector<T>(
      props: self!.props,
      parents: self!.parents,
      children: self!.children,
    );
  }
}

class FirstWidgetSelector<W extends Widget> extends SingleWidgetSelector<W> {
  FirstWidgetSelector({
    required super.props,
    required super.parents,
    required super.children,
  });

  @override
  List<ElementFilter> createElementFilters() {
    return [...super.createElementFilters(), FirstElement()];
  }

  @override
  String toString() {
    return 'first Widget ${super.toString()}';
  }

  @override
  String toStringWithoutParents() {
    return ':first';
  }
}

class FirstElement extends ElementFilter {
  FirstElement();

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final first = candidates.firstOrNull;
    if (first == null) {
      return [];
    }
    return [first];
  }
}

class LastWidgetSelector<W extends Widget> extends SingleWidgetSelector<W> {
  LastWidgetSelector({
    required super.props,
    required super.parents,
    required super.children,
  });

  @override
  List<ElementFilter> createElementFilters() {
    return [...super.createElementFilters(), LastElement()];
  }

  @override
  String toString() {
    return 'last Widget ${super.toString()}';
  }

  @override
  String toStringWithoutParents() {
    return ':last';
  }
}

class LastElement extends ElementFilter {
  LastElement();

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final last = candidates.lastOrNull;
    if (last == null) {
      return [];
    }
    return [last];
  }
}

extension SelectorQueries<W extends Widget> on Selectors<W> {
  /// Creates a filter for the discovered elements which is applied when the
  /// [Selector] is snapshotted
  ///
  /// The [description] is required to make error messages understandable
  @useResult
  WidgetSelector<W> whereElement(
    bool Function(Element element) predicate, {
    required String description,
  }) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element e) => predicate(e),
          description: description,
        ),
      ],
    );
  }

  /// Creates a filter for the widgets of the discovered elements which is
  /// applied when the [Selector] is snapshotted
  ///
  /// The [description] is required to make error messages understandable
  ///
  /// ```dart
  /// spotSingle<Checkbox>()
  ///    .whereWidget(
  ///      (widget) => widget.value == true,
  ///      description: 'isChecked',
  ///    )
  ///    .existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereWidget(
    bool Function(W widget) predicate, {
    required String description,
  }) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element element) {
            final widget = self!.mapElementToWidget(element);
            return predicate(widget);
          },
          description: description,
        ),
      ],
    );
  }

  /// Creates a filter for the widgets of the discovered elements which is
  /// applied when the [Selector] is snapshotted
  ///
  /// ```dart
  /// spotSingle<Checkbox>()
  ///   .whereWidgetProp(
  ///     prop: widgetProp('isChecked', (widget) => widget.value),
  ///     match: (value) => value == true,
  ///   )
  ///   .existsOnce();
  ///   ```
  @useResult
  WidgetSelector<W> whereWidgetProp<T>(
    NamedWidgetProp<W, T> prop,
    bool Function(T value) match,
  ) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element element) {
            final widget = self!.mapElementToWidget(element);
            final value = prop.get(widget);
            return match(value);
          },
          description: prop.name,
        ),
      ],
    );
  }

  @useResult
  WidgetSelector<W> whereElementProp<T>(
    NamedElementProp<T> prop,
    bool Function(T value) match,
  ) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element element) {
            final value = prop.get(element);
            return match(value);
          },
          description: prop.name,
        ),
      ],
    );
  }

  @useResult
  WidgetSelector<W> whereRenderObjectProp<T, R extends RenderObject>(
    NamedRenderObjectProp<R, T> prop,
    bool Function(T value) match,
  ) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element element) {
            final renderObject = element.renderObject;
            if (renderObject is R) {
              final value = prop.get(renderObject);
              return match(value);
            }
            return false;
          },
          description: prop.name,
        ),
      ],
    );
  }
}

/// A Function that fires checks against [T] using the [Subject] API
///
/// The [Subject] keeps the error states and is further processed
typedef MatchProp<T> = void Function(Subject<T>);

extension MatchPropNullable<T> on MatchProp<T> {
  MatchProp<T?> hideNullability() {
    return (Subject<T?> subject) {
      this.call(subject.hideNullability());
    };
  }
}

extension MatchPropNonNullable<T> on MatchProp<T?> {
  MatchProp<T> revealNullability() {
    return (Subject<T> subject) {
      this.call(subject.revealNullability());
    };
  }
}

class WidgetMatcher<W extends Widget> {
  final Element element;
  final WidgetSelector<W> selector;

  /// Returns the Widget that is associated with [element]
  W get widget => selector.mapElementToWidget(element);

  WidgetMatcher({
    required this.element,
    required this.selector,
  }) : assert(element.widget is W);
}

extension WidgetMatcherExtensions<W extends Widget> on WidgetMatcher<W> {
  WidgetMatcher<W> hasDiagnosticProp<T>(
    String propName,
    MatchProp<T> match,
  ) {
    final mappedElement = selector.mapElementToWidget(element);
    final diagnosticsNode = mappedElement.toDiagnosticsNode();
    final DiagnosticsNode? prop = diagnosticsNode
        .getProperties()
        .firstOrNullWhere((e) => e.name == propName);

    final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();

    final ConditionSubject<T?> conditionSubject = it<T?>();
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => [selector.toStringBreadcrumb(), 'with property $propName'],
      (value) {
        if (prop == null) {
          return Extracted.rejection(which: ['Has no prop "$propName"']);
        }
        if (value is! T) {
          return Extracted.rejection(
            which: [
              'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"',
            ],
          );
        }
        return Extracted.value(value);
      },
    );
    match(subject);
    final failure = softCheckHideNull(actual, conditionSubject);
    failure.throwPropertyCheckFailure(conditionSubject, element);
    return this;
  }

  /// Allows checking for properties of [Element] that are stored in child
  /// [Widget]s or in the state.
  /// Use [selector] to extract the actual value and validate it with [match].
  ///
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

  T getWidgetProp<T>(NamedWidgetProp<W, T> prop) {
    final widget = selector.mapElementToWidget(element);
    return prop.get(widget);
  }

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

  T getElementProp<T>(NamedElementProp<T> prop) {
    return prop.get(element);
  }

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

  T getRenderObjectProp<T, R extends RenderObject>(
    NamedRenderObjectProp<R, T> prop,
  ) {
    final renderObject = element.renderObject! as R;
    return prop.get(renderObject);
  }

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

extension on CheckFailure? {
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

class PropertyCheckFailure extends TestFailure {
  PropertyCheckFailure(
    super.message, {
    required this.matcherDescription,
  });

  final String matcherDescription;
}

class PropMatcher<W extends Widget> {
  final void Function(WidgetMatcher<W>) matcher;
  final String description;

  const PropMatcher(
    this.matcher, {
    required this.description,
  });
}

class PredicateWithDescription {
  final bool Function(Element) predicate;
  final String description;

  PredicateWithDescription(this.predicate, {required this.description});

  @override
  String toString() {
    return 'PredicateWithDescription{"$description"}';
  }
}

class WidgetTypePredicate<W extends Widget> extends PredicateWithDescription {
  WidgetTypePredicate() : super((e) => e.widget is W, description: '$W');
}

/// A [WidgetSelector] that intends to resolve to a single widget
class SingleWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  SingleWidgetSelector({
    required super.props,
    super.parents,
    super.children,
    super.mapElementToWidget,
  }) : super(expectedQuantity: ExpectedQuantity.single);

  SingleWidgetSelector.fromWidgetSelector(WidgetSelector<W> selector)
      : super(
          props: selector.props,
          parents: selector.parents,
          children: selector.children,
          mapElementToWidget: selector.mapElementToWidget,
          expectedQuantity: ExpectedQuantity.single,
        );

  SingleWidgetSnapshot<W> snapshot() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this).single;
  }

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

/// A [WidgetSelector] that to 0..N widgets
class MultiWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  MultiWidgetSelector({
    super.props,
    super.parents,
    super.children,
    super.mapElementToWidget,
  }) : super(expectedQuantity: ExpectedQuantity.multi);

  MultiWidgetSelector.fromWidgetSelector(WidgetSelector<W> selector)
      : super(
          props: selector.props,
          parents: selector.parents,
          children: selector.children,
          mapElementToWidget: selector.mapElementToWidget,
          expectedQuantity: ExpectedQuantity.multi,
        );

  MultiWidgetSnapshot<W> snapshot() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this);
  }
}

abstract class ElementFilter {
  /// Filters all candidates, retuning only a subset that matches
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates);

// TODO add description
}

abstract class CandidateGenerator<W extends Widget> {
  Iterable<WidgetTreeNode> generateCandidates();
}

Type _typeOf<T>() => T;

/// Filters candidates by widget type [W] comparing the runtime type.
///
/// Comparing the runtimeType makes sure that `spot<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
class WidgetTypeFilter<W extends Widget> implements ElementFilter {
  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final type = _typeOf<W>();
    return candidates
        .where((WidgetTreeNode node) => node.element.widget.runtimeType == type)
        .toList();
  }

  @override
  String toString() {
    return 'WidgetTypeFilter of $W';
  }
}

class PropFilter implements ElementFilter {
  final List<PredicateWithDescription> props;

  PropFilter(this.props);

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates.where((node) {
      return props.all((prop) {
        return prop.predicate(node.element);
      });
    }).toList();
  }

  @override
  String toString() {
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;

    return 'PropFilter of $props';
  }
}

/// Keeps all [WidgetTreeNode] that have child elements that match the [childSelectors] selectors
class ChildFilter implements ElementFilter {
  final List<WidgetSelector> childSelectors;

  ChildFilter(this.childSelectors);

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final tree = currentWidgetTreeSnapshot();
    final List<WidgetTreeNode> matchingChildNodes = [];

    // Then check for every queryMatch if the children and props match
    for (final WidgetTreeNode candidate in candidates) {
      final Map<WidgetSelector, List<WidgetTreeNode>> matchesPerChild = {};

      final ScopedWidgetTreeSnapshot subtree = tree.scope(candidate);
      final List<WidgetTreeNode> subtreeNodes = subtree.allNodes;
      for (final WidgetSelector<Widget> childSelector in childSelectors) {
        matchesPerChild[childSelector] = [];
        // TODO instead of searching the children, starting from the root widget, find a way to reverse the search and
        //  start form the subtree.
        //  Keep in mind, each child selector might be defined with parents which are outside of the subtree
        final MultiWidgetSnapshot ss =
            snapshot(childSelector, validateQuantity: false);
        final discoveredInSubtree =
            ss.discovered.where((node) => subtreeNodes.contains(node)).toList();

        if (childSelector.expectedQuantity == ExpectedQuantity.single &&
            discoveredInSubtree.length > 1) {
          // not a match because the child selector expects a single widget
          continue;
        }

        if (discoveredInSubtree.isEmpty) {
          // did not find any matching child
          continue;
        }

        // consider it as a match
        matchesPerChild[childSelector] = discoveredInSubtree;
      }
      if (matchesPerChild.values.any((list) => list.isEmpty)) {
        // not all children match
        continue;
      }
      matchingChildNodes.add(candidate);
    }
    return matchingChildNodes;
  }

  @override
  String toString() {
    final children = childSelectors.isNotEmpty
        ? 'with children: [${childSelectors.map((e) => e.toStringBreadcrumb()).join(', ')}]'
        : null;

    return 'PropFilter of $children';
  }
}

enum ExpectedQuantity {
  /// A selector that matches a single widget
  single,

  /// A selector that matches multiple widgets
  multi,
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with Selectors<W> {
  /// Matches any widget currently mounted
  static final WidgetSelector all = MultiWidgetSelector(
    props: [
      PredicateWithDescription(
        (e) => true,
        description: 'any Widget',
      ),
    ],
  );

  Type get type => W;

  WidgetSelector({
    List<PredicateWithDescription>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    required this.expectedQuantity,
    W Function(Element element)? mapElementToWidget,
  })  : props = List.unmodifiable(props ?? []),
        parents = List.unmodifiable(parents?.toSet().toList() ?? []),
        children = List.unmodifiable(children ?? []),
        mapElementToWidget = mapElementToWidget ?? defaultMapElementToWidget<W>;

  final List<PredicateWithDescription> props;

  final List<WidgetSelector> parents;

  final List<WidgetSelector> children;

  /// Whether this selector expects to find a single or multiple widgets
  final ExpectedQuantity expectedQuantity;

  static W defaultMapElementToWidget<W>(Element element) {
    return element.widget as W;
  }

  /// Overwrite this method when [W] is a synthetic widget like [AnyText] that
  /// combines multiple widgets of similar (but not exact) Type
  final W Function(Element element) mapElementToWidget;

  /// Returns a list of [ElementFilter] that is used to filter the widget tree
  /// (or subtrees of [parents]) for widgets that match this selectors criteria
  ///
  /// This method is intended to be overridden by subclasses to add additional
  /// filters that are not covered by this base implementation.
  List<ElementFilter> createElementFilters() {
    return [
      if (props.isNotEmpty) PropFilter(props),
      if (children.isNotEmpty) ChildFilter(children),
    ];
  }

  CandidateGenerator<W> createCandidateGenerator() {
    return CandidateGeneratorFromParents(this);
  }

  @override
  String toString() {
    final children = this.children.isNotEmpty
        ? 'with children: [${this.children.map((e) => e.toString()).join(', ')}]'
        : null;
    final parents = this.parents.isNotEmpty
        ? 'with parents: [${this.parents.map((e) => e.toString()).join(', ')}]'
        : null;
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;

    final constraints = [props, children, parents].where((e) => e != null);
    if (constraints.isEmpty) {
      return '';
    }
    return "'${constraints.join(' ')}'";
  }

  String toStringWithoutParents() {
    final children = this.children.isNotEmpty
        ? 'with children: [${this.children.map((e) => e.toString()).join(', ')}]'
        : null;
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;

    final constraints = [props, children].where((e) => e != null);
    return constraints.join(' ');
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      return toStringWithoutParents();
    }

    final parentBreadcrumbs = parents.map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return '${parentBreadcrumbs.first} > ${toStringWithoutParents()}';
    } else {
      return '[${parentBreadcrumbs.join(' && ')}] > ${toStringWithoutParents()}';
    }
  }

  @override
  WidgetSelector<W> get self => this;

  @useResult
  WidgetSelector<W> copyWith({
    List<PredicateWithDescription>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    ExpectedQuantity? expectedQuantity,
    W Function(Element element)? mapElementToWidget,
  }) {
    return WidgetSelector<W>(
      props: props ?? this.props,
      parents: parents ?? this.parents,
      children: children ?? this.children,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      mapElementToWidget: mapElementToWidget ?? this.mapElementToWidget,
    );
  }

  /// Filters all elements that match the selector
  ///
  /// ```dart
  /// withProp(
  ///   selector: (subject) => subject.context.nest<int?>(
  ///     () => ['with "maxLines"'],
  ///     (Element element) => Extracted.value(_extractMaxLines(element)),
  ///   ),
  ///   match: (maxLines) => maxLines.equals(1),
  /// );
  /// ```
  @useResult
  WidgetSelector<W> withProp<T>({
    @Deprecated('use elementSelector instead')
    Subject<T> Function(ConditionSubject<Element>)? selector,
    Subject<T> Function(ConditionSubject<Element>)? elementSelector,
    Subject<T> Function(Subject<W>)? widgetSelector,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> elementSubject = it<Element>();
    final Subject<T> subject = () {
      if (selector != null) {
        return selector(elementSubject);
      }
      if (elementSelector != null) {
        return elementSelector(elementSubject);
      }
      assert(widgetSelector != null);

      if (widgetSelector != null) {
        final Subject<W> widgetSubject = elementSubject.context.nest<W>(
          () => [],
          (element) {
            final widget = this.mapElementToWidget(element);
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
    final name =
        describe(elementSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final failure = softCheckHideNull(element, elementSubject);
        if (failure != null) {
          return false;
        }
        return true;
      },
      description: name,
    );
  }

  /// Finds the diagnostic property (from [Element.toDiagnosticsNode]) with
  /// [propName] and returns the value as type [T]
  @useResult
  WidgetSelector<W> withDiagnosticProp<T>(
    String propName,
    MatchProp<T> match,
  ) {
    final ConditionSubject<T> nameSubject = it();
    nameSubject.context.nest<T>(
      () => ['with prop "$propName"'],
      (value) => Extracted.value(value),
    );
    match(nameSubject);
    final name =
        describe(nameSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final diagnosticsNode = mapElementToWidget(element).toDiagnosticsNode();
        final DiagnosticsNode? prop = diagnosticsNode
            .getProperties()
            .firstOrNullWhere((e) => e.name == propName);

        final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();

        final ConditionSubject<T?> conditionSubject = it<T?>();
        final Subject<T> subject = conditionSubject.context.nest<T>(
          () => [toStringBreadcrumb(), 'with prop "$propName"'],
          (value) {
            if (prop == null) {
              return Extracted.rejection(which: ['Has no prop "$propName"']);
            }
            if (value is! T) {
              return Extracted.rejection(
                which: [
                  'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"',
                ],
              );
            }

            return Extracted.value(actual as T);
          },
        );
        match(subject);
        final failure = softCheckHideNull(actual, conditionSubject);
        if (failure != null) {
          return false;
        }

        return true;
      },
      description: name,
    );
  }
}

extension SelectorToSnapshot<W extends Widget> on WidgetSelector<W> {
  MultiWidgetSnapshot<W> snapshot() {
    TestAsyncUtils.guardSync();
    return snapshot_file.snapshot(this);
  }

  @useResult
  MultiWidgetSelector<W> get multi {
    return MultiWidgetSelector<W>.fromWidgetSelector(this);
  }

  @useResult
  SingleWidgetSelector<W> get single {
    return SingleWidgetSelector<W>.fromWidgetSelector(this);
  }
}

/// A collection of [discovered] elements that match [selector]
class MultiWidgetSnapshot<W extends Widget> {
  MultiWidgetSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
    required this.scope,
  }) : _widgets = Map.fromEntries(
          discovered.map((e) => MapEntry(e, e.element.widget)),
        );

  /// The widgets at the point when the snapshot was taken
  ///
  /// [Element] is a mutable object that might have changed since the snapshot
  /// was taken. This is a reference to the widget that was found at the time
  /// the snapshot was taken. This allows to compare the widget with the current
  /// widget in the tree.
  final Map<WidgetTreeNode, Widget> _widgets;

  final WidgetSelector<W> selector;

  final ScopedWidgetTreeSnapshot scope;

  /// All widgets that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  final List<WidgetTreeNode> discovered;

  /// Shorthand to get the widgets of all discovered elements
  /// (see [discovered] or [discoveredElements])
  ///
  /// This list may be incomplete for synthetic widgets like [AnyText], when the widgets are not of type [W].
  ///
  /// To check the number of discovered elements, always use [discovered] or [discoveredElements]. Use [discoveredWidgets] only when you need to access any properties of the widgets.
  List<W> get discoveredWidgets => _widgets.values.whereType<W>().toList();

  List<Element> get discoveredElements =>
      discovered.map((e) => e.element).toList();

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${discoveredElements.length} matches)}';
  }

  @useResult
  SingleWidgetSnapshot<W> get single {
    if (discovered.length > 1) {
      final errorBuilder = StringBuffer();
      errorBuilder.writeln(
        'Found ${discovered.length} elements matching $selector in widget tree, '
        'expected only one',
      );

      discovered.forEachIndexed((candidate, index) {
        errorBuilder.writeln("Possible candidate $index:");
        errorBuilder.writeln(candidate.element.toStringDeep());
      });

      errorBuilder.writeln(
        'Found ${discovered.length} elements matching $selector in widget tree, '
        'expected only one',
      );

      fail(errorBuilder.toString());
    }

    assert(discovered.length <= 1);
    return SingleWidgetSnapshot(
      selector: selector,
      discovered: discovered.firstOrNull,
      debugCandidates: debugCandidates,
    );
  }
}

/// A snapshot of a single [discovered] element that matches [selector]
class SingleWidgetSnapshot<W extends Widget> implements WidgetMatcher<W> {
  SingleWidgetSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
  }) : _widget = discovered?.element == null
            ? null
            : selector.mapElementToWidget(discovered!.element);

  /// The widget at the point when the snapshot was taken
  ///
  /// [Element] is a mutable object that might have changed since the snapshot
  /// was taken. This is a reference to the widget that was found at the time
  /// the snapshot was taken. This allows to compare the widget with the current
  /// widget in the tree.
  final W? _widget;

  @override
  final WidgetSelector<W> selector;

  /// All widgets that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  /// The node in the widget tree that was found by [selector]
  final WidgetTreeNode? discovered;

  @override
  String toString() {
    return 'SingleSpotSnapshot{widget: $_widget, selector: $selector, element: ${discovered?.element}}';
  }

  @override
  Element get element {
    if (discovered == null) {
      throw StateError(
        "WidgetSelector does not match any widget, can not access the shorthand 'element'. "
        "Instead check if 'discovered' is null.",
      );
    }
    return discovered!.element;
  }

  W? get discoveredWidget =>
      discovered == null ? null : selector.mapElementToWidget(element);

  Element? get discoveredElement => element;

  @override
  W get widget => _widget!;
}

extension QuantityMatchers<W extends Widget> on WidgetSelector<W> {
  MultiWidgetSnapshot<W> existsAtLeastOnce() {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsAtLeastOnce();
  }

  MultiWidgetSnapshot<W> existsAtMostOnce() {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsAtMostOnce();
  }

  void doesNotExist() {
    TestAsyncUtils.guardSync();
    snapshot(this).doesNotExist();
  }

  SingleWidgetSnapshot<W> existsOnce() {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsOnce();
  }

  MultiWidgetSnapshot<W> existsExactlyNTimes(int n) {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsExactlyNTimes(n);
  }

  MultiWidgetSnapshot<W> existsAtLeastNTimes(int n) {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsAtLeastNTimes(n);
  }

  MultiWidgetSnapshot<W> existsAtMostNTimes(int n) {
    TestAsyncUtils.guardSync();
    return snapshot(this).existsAtMostNTimes(n);
  }
}

/// Extensions that control the parent/children widgets of a [WidgetSelector]
extension RelativeSelectors<W extends Widget> on WidgetSelector<W> {
  /// Returns a [WidgetSelector] that requires [parent] to be a parent of
  /// the to be matched widget
  @useResult
  WidgetSelector<W> withParent(WidgetSelector parent) {
    return copyWith(parents: [...parents, parent]);
  }

  /// Returns a [WidgetSelector] that requires [parents] to be parents of
  /// the to be matched widget
  @useResult
  WidgetSelector<W> withParents(List<WidgetSelector> parents) {
    return copyWith(parents: [...this.parents, ...parents]);
  }

  /// Returns a [WidgetSelector] that requires [child] to be a child of the to
  /// be matched widget
  @useResult
  WidgetSelector<W> withChild(WidgetSelector child) {
    return copyWith(children: [...children, child]);
  }

  /// Returns a [WidgetSelector] that requires [children] to be children of the
  /// to be matched widget
  @useResult
  WidgetSelector<W> withChildren(List<WidgetSelector> children) {
    return copyWith(children: [...this.children, ...children]);
  }
}

extension AssertionMatcher<W extends Widget> on MultiWidgetSnapshot<W> {
  SingleWidgetSnapshot<W> single() {
    return SingleWidgetSnapshot(
      selector: selector,
      discovered: discovered.firstOrNull,
      debugCandidates: debugCandidates,
    );
  }
}

extension MutliMatchers<W extends Widget> on MultiWidgetSnapshot<W> {
  MultiWidgetSnapshot<W> any(void Function(WidgetMatcher<W>) matcher) {
    TestAsyncUtils.guardSync();
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }

    late String matcherDescription;
    final found = discovered.any((element) {
      final wm = WidgetMatcher(
        element: element.element,
        selector: selector,
      );
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

  MultiWidgetSnapshot<W> all(void Function(WidgetMatcher<W>) matcher) {
    TestAsyncUtils.guardSync();
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }

    late String matcherDescription;
    final missMatches = discovered.whereNot((element) {
      final wm = WidgetMatcher(
        element: element.element,
        selector: selector,
      );
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

extension on DiagnosticsNode {
  T? getDefaultValue<T>() {
    try {
      if (this is DiagnosticsProperty) {
        return (this as DiagnosticsProperty).defaultValue as T?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
