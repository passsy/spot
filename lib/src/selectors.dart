import 'dart:io';

import 'package:checks/checks.dart';
import 'package:checks/context.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/snapshot.dart' as snapshot_file show snapshot;
import 'package:spot/src/snapshot.dart';
import 'package:spot/src/tree_snapshot.dart';

class Spot with Selectors<Widget> {
  const Spot();

  @override
  WidgetSelector? get self => null;
}

mixin Selectors<T extends Widget> {
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
  MultiWidgetSelector<W> spot<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final selector = MultiWidgetSelector<W>(
      props: [],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );

    return selector;
  }

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

  MultiWidgetSelector<W> spotWidgets<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector<W>(
      props: [
        PredicateWithDescription(
          (Element e) => identical(e.widget, widget),
          description: 'Widget === $widget',
        )
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  SingleWidgetSelector<W> spotElement<W extends Widget>(
    Element element, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return SingleWidgetSelector<W>(
      props: [
        PredicateWithDescription(
          (Element e) => identical(e, element),
          description: 'Element === $element',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

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

  MultiWidgetSelector<W> spotTexts<W extends Widget>(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return MultiWidgetSelector<W>(
      props: [
        PredicateWithDescription(
          (Element e) {
            if (e.widget is Text) {
              final actual = (e.widget as Text).data;
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

  MultiWidgetSelector<Icon> spotIcons(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector(
      props: [
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

  MultiWidgetSelector<W> spotKeys<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return MultiWidgetSelector(
      props: [
        PredicateWithDescription(
          (Element e) {
            if (e.widget is W) {
              return (e.widget as W).key == key;
            }
            return false;
          },
          description: 'Widget with key: "$key"',
        ),
      ],
      parents: [if (self != null) self!, ...parents],
      children: children,
    );
  }

  WidgetSelector<W> cast<W extends Widget>() {
    return WidgetSelector<W>(
      props: self!.props,
      parents: self!.parents,
      children: self!.children,
      expectedQuantity: self!.expectedQuantity,
    );
  }

  SingleWidgetSelector<T> first() {
    return FirstWidgetSelector<T>(
      props: self!.props,
      parents: self!.parents,
      children: self!.children,
    );
  }

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
        )
      ],
    );
  }

  WidgetSelector<W> whereWidget(
    bool Function(W widget) predicate, {
    required String description,
  }) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element e) {
            if (e.widget is W) {
              return predicate(e.widget as W);
            }
            return false;
          },
          description: description,
        )
      ],
    );
  }
}

typedef MatchProp<T> = void Function(Subject<T>);

class WidgetMatcher<W extends Widget> {
  W get widget => element.widget as W;
  final Element element;
  final WidgetSelector<W> selector;

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
    final diagnosticsNode = element.toDiagnosticsNode();
    final DiagnosticsNode? prop = diagnosticsNode
        .getProperties()
        .firstOrNullWhere((e) => e.name == propName);

    final actual = prop?.value as T?;

    final ConditionSubject<T?> conditionSubject = it<T?>();
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => [selector.toStringBreadcrumb(), 'with property $propName'],
      (_) {
        if (prop == null) {
          return Extracted.rejection(which: ['Has no prop "$propName"']);
        }
        if (prop.value is! T) {
          return Extracted.rejection(
            which: [
              'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"'
            ],
          );
        }
        return Extracted.value(actual as T);
      },
    );
    match(subject);
    final failure = softCheck(actual, conditionSubject);
    if (failure != null) {
      final errorParts =
          describe(conditionSubject).map((it) => it.trim()).toList();
      // workaround allowing to use
      // hasPropertyXWhere((subject)=> subject.equals(X));
      // instead of
      // hasPropertyXWhere((subject)=> subject.isNotNull().equals(X));
      //
      // when Subject is Subject<T> but the value can actually be null (should be Subject<T?>).
      final errorMessage = errorParts.join(' ');
      if (errorParts.last == 'is null' &&
          failure.rejection.actual.firstOrNull == '<null>') {
        // property is null and isNull() was called
        // not error because null == null
        return this;
      }
      throw PropertyCheckFailure(
        'Failed to match widget: $errorMessage, actual: ${literal(actual).joinToString()}',
        matcherDescription: errorParts.skip(1).join(' ').removePrefix('with '),
      );
    }
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
    required Subject<T> Function(ConditionSubject<Element>) selector,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final subject = selector(conditionSubject);

    match(subject);
    final failure = softCheck(element, conditionSubject);
    if (failure != null) {
      final errorMessage =
          describe(conditionSubject).map((it) => it.trim()).toList().join(' ');
      throw TestFailure(
        'Failed to match widget: $errorMessage, actual: ${failure.rejection.actual.joinToString()}',
      );
    }
    return this;
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
}

/// A [WidgetSelector] that intends to resolve to a single widget
class SingleWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  SingleWidgetSelector({
    required super.props,
    super.parents,
    super.children,
  }) : super(expectedQuantity: ExpectedQuantity.single);

  SingleWidgetSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this).single;
  }
}

/// A [WidgetSelector] that to 0..N widgets
class MultiWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  MultiWidgetSelector({
    super.props,
    super.parents,
    super.children,
  }) : super(expectedQuantity: ExpectedQuantity.multi);

  MultiWidgetSnapshot<W> snapshot() {
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
    return candidates
        .where((node) => props.all((prop) => prop.predicate(node.element)))
        .toList();
  }

  @override
  String toString() {
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;

    return 'PropFilter of $props';
  }
}

class ChildFilter implements ElementFilter {
  final List<WidgetSelector> children;
  ChildFilter(this.children);

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    final tree = currentWidgetTreeSnapshot();
    final List<WidgetTreeNode> matchingChildNodes = [];
    // Then check for every queryMatch if the children and props match
    for (final WidgetTreeNode candidate in candidates) {
      final Map<WidgetSelector, List<WidgetTreeNode>> matchesPerChild = {};

      final subtreeNodes = tree.scope(candidate).allNodes;
      for (final WidgetSelector<Widget> childSelector in children) {
        matchesPerChild[childSelector] = [];
        final MultiWidgetSnapshot ss = snapshot(childSelector);
        final discoveredInSubtree = ss.discovered
            .where((element) => subtreeNodes.contains(element))
            .toList();

        if (discoveredInSubtree.isNotEmpty) {
          matchesPerChild[childSelector] = discoveredInSubtree;
        } else {
          continue;
        }
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
    final children = this.children.isNotEmpty
        ? 'with children: [${this.children.map((e) => e.toStringBreadcrumb()).join(', ')}]'
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
  static final WidgetSelector all = MultiWidgetSelector(
    props: [
      PredicateWithDescription(
        (e) => true,
        description: 'any Widget',
      )
    ],
  );

  Type get type => W;

  WidgetSelector({
    List<PredicateWithDescription>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    required this.expectedQuantity,
  })  : props = List.unmodifiable(props ?? []),
        parents = List.unmodifiable(parents?.toSet().toList() ?? []),
        children = List.unmodifiable(children ?? []);

  final List<PredicateWithDescription> props;

  final List<WidgetSelector> parents;

  final List<WidgetSelector> children;

  /// Whether this selector expects to find a single or multiple widgets
  final ExpectedQuantity expectedQuantity;

  /// Returns a list of [ElementFilter] that is used to filter the widget tree
  /// (or subtrees of [parents]) for widgets that match this selectors criteria
  ///
  /// This method is intended to be overridden by subclasses to add additional
  /// filters that are not covered by this base implementation.
  List<ElementFilter> createElementFilters() {
    return [
      if (W != Widget) WidgetTypeFilter<W>(),
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

    final widgetType = W != Widget ? '$W' : null;

    final constraints =
        [widgetType, props, children, parents].where((e) => e != null);
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

    final widgetType = W != Widget ? '$W' : null;

    final constraints = [widgetType, props, children].where((e) => e != null);
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

  WidgetSelector<W> copyWith({
    List<PredicateWithDescription>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    ExpectedQuantity? expectedQuantity,
  }) {
    return WidgetSelector<W>(
      props: props ?? this.props,
      parents: parents ?? this.parents,
      children: children ?? this.children,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
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
  WidgetSelector<W> withProp<T>({
    required Subject<T> Function(ConditionSubject<Element>) selector,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> elementSubject = it<Element>();
    final Subject<T> subject = selector(elementSubject);
    match(subject);
    final name =
        describe(elementSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final failure = softCheck(element, elementSubject);
        return failure == null;
      },
      description: name,
    );
  }

  /// Finds the diagnostic property (from [Element.toDiagnosticsNode]) with
  /// [propName] and returns the value as type [T]
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
        final diagnosticsNode = element.toDiagnosticsNode();
        final DiagnosticsNode? prop = diagnosticsNode
            .getProperties()
            .firstOrNullWhere((e) => e.name == propName);

        final actual = prop?.value as T?;

        final ConditionSubject<T?> conditionSubject = it<T?>();
        final Subject<T> subject = conditionSubject.context.nest<T>(
          () => [toStringBreadcrumb(), 'with prop "$propName"'],
          (_) {
            if (prop == null) {
              return Extracted.rejection(which: ['Has no prop "$propName"']);
            }
            if (prop.value is! T) {
              return Extracted.rejection(
                which: [
                  'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"'
                ],
              );
            }

            return Extracted.value(actual as T);
          },
        );
        match(subject);
        final failure = softCheck(actual, conditionSubject);
        if (failure != null) {
          final errorParts =
              describe(conditionSubject).map((it) => it.trim()).toList();
          // workaround allowing to use
          // hasPropertyXWhere((subject)=> subject.equals(X));
          // instead of
          // hasPropertyXWhere((subject)=> subject.isNotNull().equals(X));
          //
          // when Subject is Subject<T> but the value can actually be null (should be Subject<T?>).
          if (errorParts.last == 'is null' &&
              failure.rejection.actual.firstOrNull == '<null>') {
            // property is null and isNull() was called
            // not error because null == null
            return true;
          }
          return false;
        }

        return true;
      },
      description: name,
    );
  }
}

/// A collection of [discovered] elements that match [selector]
class MultiWidgetSnapshot<W extends Widget> {
  final WidgetSelector<W> selector;

  final ScopedWidgetTreeSnapshot scope;

  /// All widgets that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  final List<WidgetTreeNode> discovered;

  /// The parent nodes from where the node has been found
  // final List<MultiWidgetSnapshot> parents;

  List<W> get discoveredWidgets =>
      discovered.map((e) => e.element.widget as W).toList();

  List<Element> get discoveredElements =>
      discovered.map((e) => e.element).toList();

  MultiWidgetSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
    required this.scope,
  });

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${discoveredElements.length} matches)}';
  }

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
  });

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
    return 'SingleSpotSnapshot of $selector (${discovered == null ? 'no' : '1'} match)}';
  }

  @override
  Element get element {
    return discovered!.element;
  }

  W? get discoveredWidget => element.widget as W?;

  Element? get discoveredElement => element;

  @override
  W get widget => discovered!.element.widget as W;
}

extension SelectorToSnapshot<W extends Widget> on WidgetSelector<W> {
  SingleWidgetSelector<W> get single {
    return SingleWidgetSelector<W>(
      props: props,
      parents: parents,
      children: children,
    );
  }

  MultiWidgetSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this);
  }

  MultiWidgetSnapshot<W> existsAtLeastOnce() {
    return snapshot().existsAtLeastOnce();
  }

  void doesNotExist() {
    snapshot().doesNotExist();
  }

  SingleWidgetSnapshot<W> existsOnce() {
    return snapshot().existsOnce();
  }

  MultiWidgetSnapshot<W> existsExactlyNTimes(int n) {
    return snapshot().existsExactlyNTimes(n);
  }

  MultiWidgetSnapshot<W> existsAtLeastNTimes(int n) {
    return snapshot().existsAtLeastNTimes(n);
  }
}

extension SingleSnapshotSelector<W extends Widget> on SingleWidgetSelector<W> {
  MultiWidgetSelector<W> get multi {
    return MultiWidgetSelector<W>(
      props: props,
      parents: parents,
      children: children,
    );
  }

  SingleWidgetSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this).single;
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

Type _typeOf<T>() => T;

extension CreateMatchers<W extends Widget> on WidgetSelector<W> {
  void printMatchers({
    Map<String, String> propNameOverrides = const {},
  }) {
    final value = createMatcherString(
      propNameOverrides: propNameOverrides,
    );
    if (value == null) {
      return;
    }

    // ignore: avoid_print
    print(value);
  }

  void writeMatchersToFile({
    required String path,
    Map<String, String> propNameOverrides = const {},
    String? imports,
  }) {
    final content = createMatcherString(
      propNameOverrides: propNameOverrides,
      imports: imports,
    );
    final file = File(path);
    if (content == null) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } else {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }
  }

  String? createMatcherString({
    Map<String, String> propNameOverrides = const {},
    String? imports,
  }) {
    final snapshot = existsAtLeastOnce();
    final anyElement = snapshot.discoveredElements.first;
    final props = anyElement.toDiagnosticsNode().getProperties();
    String widgetType = _typeOf<W>().toString().capitalize();
    if (widgetType.contains('<')) {
      widgetType = widgetType.substring(0, widgetType.indexOf('<'));
    }
    bool addedMethods = false;

    final matcherSb = StringBuffer();
    matcherSb.writeln('''
/// Matchers for the properties of [$widgetType] provided via [Diagnosticable.debugFillProperties]
extension ${widgetType}Matcher on WidgetMatcher<$widgetType> {
''');

    final selectorSb = StringBuffer();
    selectorSb.writeln(
      '''
/// Allows filtering [$widgetType] by the properties provided via [Diagnosticable.debugFillProperties]
extension ${widgetType}Selector on WidgetSelector<$widgetType> {
''',
    );

    final distinctProps = props.distinctBy((it) => it.name).toList();
    for (final DiagnosticsNode prop in distinctProps) {
      final propName = prop.name!;
      final humanPropName = propNameOverrides[propName] ?? propName;
      String propType = prop.getType();
      if (prop is ObjectFlagProperty &&
          (propType == 'Widget' || propType == 'Widget?')) {
        // matchers on widgets are not supported, use .spot() to check the tree further down
        continue;
      }
      if (prop is FlagProperty && propName == 'dirty') {
        // dirty flags are irrelevant for assertions (and always false)
        continue;
      }
      if (propType.contains('=>')) {
        // ignore lambda properties
        continue;
      }
      if (prop.name == 'depth' || prop.name == 'key') {
        // ignore default properties that are covered by general Wiget selectors
        continue;
      }
      if (prop.name == 'dependencies' && propType == 'List<DiagnosticsNode>') {
        // Widget dependencies are only indirect properties
        continue;
      }
      if (prop.name == 'renderObject' && propType == 'RenderObject') {
        final propValueRuntimeType = prop.value.runtimeType.toString();
        if (!propValueRuntimeType.startsWith('_')) {
          propType = propValueRuntimeType;
        }
      }

      if (prop.name == 'state' && propType.contains('State<StatefulWidget>')) {
        final propValueRuntimeType = prop.value.runtimeType.toString();
        if (propValueRuntimeType.startsWith('_')) {
          // this is not useful without type
          continue;
        }
        propType = propValueRuntimeType;
        continue;
      }
      final propTypeNullable = propType.endsWith('?') ? propType : '$propType?';

      String matcherVerb = 'has';
      if (humanPropName == 'enabled') {
        matcherVerb = 'is';
      }

      addedMethods = true;
      matcherSb.writeln('''
  /// Expects that $humanPropName of [$widgetType] matches the condition in [match]    
  WidgetMatcher<$widgetType> $matcherVerb${humanPropName.capitalize()}Where(MatchProp<$propType> match) {
    return hasDiagnosticProp<$propType>('$propName', match);
  }
  
  /// Expects that $humanPropName of [$widgetType] equals (==) [value]
  WidgetMatcher<$widgetType> $matcherVerb${humanPropName.capitalize()}($propTypeNullable value) {
    return hasDiagnosticProp<$propType>('$propName', (it) => value == null ? it.isNull() : it.equals(value));
  }
''');

      selectorSb.writeln('''
  /// Creates a [WidgetSelector] that finds all [$widgetType] where $humanPropName matches the condition   
  WidgetSelector<$widgetType> where${humanPropName.capitalize()}(MatchProp<$propType> match) {
    return withDiagnosticProp<$propType>('$propName', match);
  }
  
  /// Creates a [WidgetSelector] that finds all [$widgetType] where $humanPropName equals (==) [value]
  WidgetSelector<$widgetType> with${humanPropName.capitalize()}($propTypeNullable value) {
    return withDiagnosticProp<$propType>('$propName', (it) => value == null ? it.isNull() : it.equals(value));
  }
''');
    }

    matcherSb.writeln('}');
    selectorSb.writeln('}');

    if (addedMethods == false) {
      // nothing added, don't generate the file at all
      return null;
    }

    final overridesParam = propNameOverrides.isEmpty
        ? ''
        : 'propNameOverrides: ${propNameOverrides.mapEntries((it) => MapEntry("'${it.key}'", "'${it.value}'"))}';

    return '''
// ignore_for_file: require_trailing_commas

${imports ?? "import 'package:flutter/widgets.dart';"}
import 'package:spot/spot.dart';

/// Matchers for [$widgetType] auto-generated by spot
///
/// ```dart
/// spot<$widgetType>().printMatchers($overridesParam);
/// ```
$matcherSb
$selectorSb    
    ''';
  }
}

extension ReadType on DiagnosticsNode {
  String getType() {
    if (this is StringProperty) {
      return 'String';
    }

    if (this is FlagProperty) {
      return 'bool';
    }

    if (this is DoubleProperty) {
      return 'double';
    }

    if (this is IntProperty) {
      return 'int';
    }
    if (this is IconDataProperty) {
      return 'IconData';
    }
    if (this is ColorProperty) {
      return 'Color';
    }

    if (this is AttributedStringProperty) {
      return 'String';
    }

    if (this is EnumProperty) {
      // "EnumProperty<TextAlign>"
      final Type runtimeType = this.runtimeType;
      // "TextAlign"
      final String? genericType = () {
        try {
          final regex = RegExp('<(.*)>');
          return regex.firstMatch(runtimeType.toString())?.group(1);
        } catch (_) {
          return null;
        }
      }();

      if (genericType != null) {
        return genericType;
      }
    }

    if (this is DiagnosticsProperty) {
      final Type runtimeType = this.runtimeType;
      final String? genericType = () {
        try {
          final regex = RegExp('<(.*)>');
          return regex.firstMatch(runtimeType.toString())?.group(1);
        } catch (_) {
          return null;
        }
      }();

      if (genericType != null) {
        return genericType;
      }
    }

    return 'Object?';
  }
}
