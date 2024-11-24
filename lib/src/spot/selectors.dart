import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
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

  List<ElementFilter> _childAndParentFilters(
    List<WidgetSelector> children,
    List<WidgetSelector> parents,
  ) {
    final List<ElementFilter> filters = [];
    if (children.isNotEmpty) {
      filters.add(ChildFilter(children));
    }
    final list = [if (self != null) self!, ...parents];
    if (list.isNotEmpty) {
      filters.add(ParentFilter(list));
    }
    return filters;
  }

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
      stages: [
        if (W == Widget)
          PredicateFilter(
            predicate: (e) => true,
            description: 'any Widget',
          )
        else
          WidgetTypeFilter<W>(),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
  }

  /// Creates a [WidgetSelector] that includes offstage widgets in the selection.
  ///
  /// Offstage widgets are those that are not currently visible on the screen,
  /// but are still part of the widget tree. This can be useful when you want to
  /// select and perform operations on widgets that are not currently visible to the user.
  ///
  /// Returns a new [WidgetSelector] that includes offstage widgets.
  ///
  /// ### Example usage:
  /// ```dart
  /// final text = spotText('text')
  ///   .overrideWidgetPresence(WidgetPresence.combined);
  /// ```
  @useResult
  WidgetSelector<T> overrideWidgetPresence(WidgetPresence presence) {
    if (presence == self!.widgetPresence) {
      return self!;
    }
    return self!.copyWith(widgetPresence: presence);
  }

  /// Creates a [WidgetSelector] that includes offstage widgets in the selection.
  ///
  /// Offstage widgets are those that are not currently visible on the screen,
  /// but are still part of the widget tree. This can be useful when you want to
  /// select and perform operations on widgets that are not currently visible to the user.
  ///
  /// Returns a new [WidgetSelector] that includes offstage widgets.
  ///
  /// ### Example usage:
  /// ```dart
  /// final text = spotOffstage()
  ///   .spotText('text');
  /// ```
  @useResult
  WidgetSelector<Widget> spotOffstage({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector(
      widgetPresence: WidgetPresence.offstage,
      stages: _childAndParentFilters(children, parents),
    );
  }

  /// Creates a [WidgetSelector] that excludes offstage widgets from the selection.
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
    final selector = WidgetSelector<W>(
      stages: [
        WidgetTypeFilter<W>(),
        PredicateFilter(
          predicate: (Element e) => identical(e.widget, widget),
          description: 'Widget === $widget',
        ),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
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
    final selector = WidgetSelector<W>(
      stages: [
        WidgetTypeFilter<W>(),
        PredicateFilter(
          predicate: (Element e) => identical(e, element),
          description: 'Element === $element',
        ),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
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
          return describe(match).map((it) => it.trim()).toList().join(' ');
        }();
    final selector = AnyTextWidgetSelector(
      stages: [
        MatchTextFilter(
          match: (it) => match(it),
          description: 'Widget with text $name',
        ),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
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
    final selector = WidgetSelector<W>(
      stages: [
        WidgetTypeFilter<W>(),
        PredicateFilter(
          predicate: (Element e) {
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
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
  }

  /// Creates a [WidgetSelector] that finds all [Icon] widgets showing [icon]
  @useResult
  WidgetSelector<Icon> spotIcon(
    IconData icon, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final selector = WidgetSelector<Icon>(
      stages: [
        WidgetTypeFilter<Icon>(),
        PredicateFilter(
          predicate: (Element e) {
            if (e.widget is Icon) {
              return (e.widget as Icon).icon == icon;
            }
            return false;
          },
          description: 'Widget with icon: "$icon"',
        ),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
  }

  /// Creates a [WidgetSelector] that finds a single [Icon] based on the [icon]
  @useResult
  @Deprecated('Use spotIcon().atMost(1)')
  WidgetSelector<Icon> spotSingleIcon(
    IconData icon, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotIcon(
      icon,
      parents: parents,
      children: children,
    ).atMost(1);
  }

  /// Creates a [WidgetSelector] that finds all [Icon] widgets based on the [icon]
  @useResult
  @Deprecated('Use spotIcon()')
  WidgetSelector<Icon> spotIcons(
    IconData icon, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spotIcon(
      icon,
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
    final selector = WidgetSelector<W>(
      stages: [
        WidgetTypeFilter<W>(),
        PredicateFilter(
          predicate: (Element e) => e.widget.key == key,
          description: 'with key: "$key"',
        ),
        ..._childAndParentFilters(children, parents),
      ],
    );
    return selector;
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
    return self!.addStage(_FirstElement());
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
    return self!.addStage(_LastElement());
  }

  /// Selects the widget at a specified [index] in the list of found widgets.
  ///
  /// #### Example usage:
  ///```dart
  /// spot<YourWidgetType>().atIndex(2) // Selects the third widget
  ///```
  @useResult
  WidgetSelector<T> atIndex(int index) {
    return self!.addStage(_ElementAtIndex(index));
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
  String get description => 'first item';
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
  String get description => 'last item';
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
  String get description => 'at index $index';

  @override
  String toString() {
    return '_ElementAtIndex{index: $index}';
  }
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
    return self.addStage(
      PredicateFilter(
        predicate: predicate,
        description: description,
      ),
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
    return self.addStage(
      PredicateFilter(
        predicate: (Element element) {
          final widget = self.mapElementToWidget(element);
          return predicate(widget);
        },
        description: description,
      ),
    );
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
    return snapshot_file.snapshot(this).single.widget;
  }

  /// Convenience getter to access the [State] of a Widget found by the [WidgetSelector]
  S snapshotState<S extends State>() {
    final matcher = snapshot_file.snapshot(this).single;
    final element = matcher.element;
    if (element is! StatefulElement) {
      throw StateError(
        '${element.widget.toStringShort()} is not a StatefulWidget and does not have a State',
      );
    }
    final state = element.state as S;
    return state;
  }

  /// Convenience getter to access the [Element] when evaluating the [WidgetSelector]
  Element snapshotElement() {
    return snapshot_file.snapshot(this).single.element;
  }

  /// Convenience getter to access the [RenderObject] when evaluating the [WidgetSelector]
  RenderObject snapshotRenderObject() {
    // There is not a single Element in the Flutter SDK that returns null for `renderObject`.
    // So we can safely assume that this cast never fails.
    return snapshot_file.snapshot(this).single.element.renderObject!;
  }

  /// Convenience getter to access the [RenderBox] when evaluating the [WidgetSelector]
  RenderBox snapshotRenderBox() {
    final renderObject = snapshotRenderObject();
    if (renderObject is! RenderBox) {
      throw StateError('RenderObject $renderObject is not a RenderBox');
    }
    return renderObject;
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
    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync();
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} exists at least once.',
        color: Colors.grey,
      );
    }
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
    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync();
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} exists at most once.',
        color: Colors.grey,
      );
    }
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
    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync();
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} does not exist.',
        color: Colors.grey,
      );
    }
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
    final one =
        copyWith(quantityConstraint: const QuantityConstraint.exactly(1));
    final widgetSnapshot = snapshot(one);

    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync(
        annotators: [
          HighlightAnnotator.elements(widgetSnapshot.discoveredElements),
        ],
      );
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} exists once.',
        color: Colors.grey,
      );
    }

    return widgetSnapshot.single;
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
    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync();
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} exists at least $n times.',
        color: Colors.grey,
      );
    }
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
    if (timeline.mode != TimelineMode.off) {
      final screenshot = timeline.takeScreenshotSync();
      timeline.addEvent(
        eventType: 'Assertion',
        screenshot: screenshot,
        details: '${toStringBreadcrumb()} exists at most $n times.',
        color: Colors.grey,
      );
    }
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
    return addStage(ParentFilter([parent]));
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
    return addStage(ParentFilter(parents));
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
    return addStage(ChildFilter([child]));
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
    return addStage(ChildFilter(children));
  }
}
