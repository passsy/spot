import 'dart:io';

import 'package:checks/checks.dart';
import 'package:checks/context.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/snapshot.dart' as snapshot_file show snapshot;

class Spot with Spotters<Widget> {
  const Spot();

  @override
  WidgetSelector? get self => null;
}

mixin Spotters<T extends Widget> {
  WidgetSelector<T>? get self;

  SingleWidgetSelector<W> spotSingle<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return spot<W>(parents: parents, children: children).single;
  }

  /// Spots a widget of type [W] in the scope of the parent selector
  WidgetSelector<W> spot<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final type = _typeOf<W>();
    final selector = WidgetSelector<W>(
      props: [
        PredicateWithDescription(
          (Element e) => e.widget.runtimeType == type,
          description: '$type',
        ),
      ],
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

  WidgetSelector<W> spotWidgets<W extends Widget>(
    W widget, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector<W>(
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

  SingleWidgetSelector<W> spotSingleElement<W extends Widget>(
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

  SingleWidgetSelector<Text> spotSingleText(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return spotTexts(
      text,
      parents: [if (self != null) self!, ...parents],
      children: children,
      findRichText: findRichText,
    ).single;
  }

  WidgetSelector<Text> spotTexts(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return WidgetSelector(
      props: [
        PredicateWithDescription(
          (Element e) {
            if (e.widget is Text) {
              return (e.widget as Text).data == text;
            }
            if (e.widget is EditableText) {
              return (e.widget as EditableText).controller.text == text;
            }
            if (findRichText == true && e.widget is RichText) {
              return (e.widget as RichText).text.toPlainText() == text;
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

  WidgetSelector<Icon> spotIcons(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector(
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

  SingleWidgetSelector<W> spotKey<W extends Widget>(
    Key key, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return SingleWidgetSelector(
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
}

extension SpotterQueries<T extends Widget> on Spotters<T> {
  WidgetSelector<T> whereElement(
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

  WidgetSelector<T> whereWidget(
    bool Function(T widget) predicate, {
    required String description,
  }) {
    return self!.copyWith(
      props: [
        ...self!.props,
        PredicateWithDescription(
          (Element e) {
            if (e.widget is T) {
              return predicate(e.widget as T);
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
  WidgetMatcher<W> hasProp<T>(
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
      (widget) {
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
      final errorMessage =
          describe(conditionSubject).map((it) => it.trim()).toList().join(' ');
      throw TestFailure(
        'Failed to match widget: $errorMessage, actual: ${literal(actual).joinToString()}',
      );
    }
    return this;
  }
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
  }) : super(expectSingle: true);

  SingleSpotSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this).single;
  }
}

/// A [WidgetSelector] that to 0..N widgets
class MultiWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  MultiWidgetSelector._({
    required super.props,
    super.parents,
    super.children,
  }) : super(expectSingle: false);

  SpotSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this);
  }
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with Spotters<W> {
  static final WidgetSelector all = WidgetSelector(
    props: [
      PredicateWithDescription(
        (e) => true,
        description: 'any Widget',
      )
    ],
  );

  WidgetSelector({
    required List<PredicateWithDescription> props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    this.expectSingle,
  })  : props = List.unmodifiable(props),
        parents = List.unmodifiable(parents?.toSet().toList() ?? []),
        children = List.unmodifiable(children ?? []);

  final List<PredicateWithDescription> props;

  final List<WidgetSelector> parents;

  final List<WidgetSelector> children;

  /// True when this selector should only match a single widget
  final bool? expectSingle;

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

    if (this.children.isEmpty && this.parents.isEmpty) {
      return "'$props'";
    }

    final constraints = [props, children, parents].where((e) => e != null);
    return "'${constraints.join(' ')}'";
  }

  String toStringWithoutParents() {
    final children = this.children.isNotEmpty
        ? 'with children: [${this.children.map((e) => e.toString()).join(', ')}]'
        : null;
    final props = this.props.isNotEmpty
        ? this.props.map((e) => e.description).join(' ')
        : null;

    if (this.children.isEmpty && this.parents.isEmpty) {
      return "'$props'";
    }

    final constraints = [props, children].where((e) => e != null);
    return constraints.join(' ');
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      final props = this.props.isNotEmpty
          ? this.props.map((e) => e.description).join(' ')
          : null;
      return props ?? 'any widget';
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
    bool? expectSingle,
  }) {
    return WidgetSelector<W>(
      props: props ?? this.props,
      parents: parents ?? this.parents,
      children: children ?? this.children,
      expectSingle: expectSingle ?? this.expectSingle,
    );
  }

  WidgetSelector<W> withProp<T>(
    String propName,
    MatchProp<T> match,
  ) {
    final ConditionSubject<Element> conditionSubject = it<Element>();
    final Subject<T> subject = conditionSubject.context.nest<T>(
      () => ['with prop "$propName"'],
      (Element element) {
        final diagnosticsNode = element.toDiagnosticsNode();
        final prop = diagnosticsNode
            .getProperties()
            .firstOrNullWhere((e) => e.name == propName);
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

        return Extracted.value(prop.value as T);
      },
    );
    match(subject);
    final name =
        describe(conditionSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final failure = softCheck(element, conditionSubject);
        return failure == null;
      },
      description: name,
    );
  }
}

/// An [Element] in the widget tree that was found with a [WidgetSelector] query
class SpotNode<W extends Widget> {
  /// The parent nodes from where the node has been found
  final List<SpotNode> parents;

  /// The selector that has been used to find [element]
  final WidgetSelector<W> selector;

  /// The element that has been found
  final Element element;

  /// All candidates that have been checked with [selector]
  final List<Element> debugCandidates;

  const SpotNode({
    required this.selector,
    required this.element,
    required this.debugCandidates,
    this.parents = const [],
  });

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType{value: ${element.widget.toStringShallow()}, parents: ${parents.map((it) => it.element.toStringShort()).join(', ')}}';
  }
}

/// A collection of [discovered] elements that match [selector]
class SpotSnapshot<W extends Widget> {
  final WidgetSelector<W> selector;

  /// All widgets that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  final List<SpotNode<W>> discovered;

  List<W> get discoveredWidgets =>
      discovered.map((e) => e.element.widget as W).toList();

  List<Element> get discoveredElements =>
      discovered.map((e) => e.element).toList();

  SpotSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
  });

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${discoveredElements.length} matches)}';
  }

  SingleSpotSnapshot<W> get single {
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
    return SingleSpotSnapshot(
      selector: selector,
      discovered: discovered.firstOrNull,
      debugCandidates: debugCandidates,
    );
  }
}

/// A snapshot of a single [discovered] element that matches [selector]
class SingleSpotSnapshot<W extends Widget> implements WidgetMatcher<W> {
  SingleSpotSnapshot({
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

  final SpotNode<W>? discovered;

  @override
  String toString() {
    return 'SingleSpotSnapshot of $selector (${discovered == null ? 'no' : '1'} match)}';
  }

  @override
  Element get element {
    return discovered!.element;
  }

  W? get discoveredWidget => element.widget as W?;

  Element? get discoveredElements => element;

  @override
  W get widget => discovered!.element.widget as W;
}

extension SnapshotSelector<W extends Widget> on WidgetSelector<W> {
  SingleWidgetSelector<W> get single {
    return SingleWidgetSelector<W>(
      props: props,
      parents: parents,
      children: children,
    );
  }

  SpotSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this);
  }

  SpotSnapshot<W> existsAtLeastOnce() {
    return snapshot().existsAtLeastOnce();
  }

  void doesNotExist() {
    snapshot().doesNotExist();
  }

  SingleSpotSnapshot<W> existsOnce() {
    return snapshot().existsOnce();
  }

  SpotSnapshot<W> existsExactlyNTimes(int n) {
    return snapshot().existsExactlyNTimes(n);
  }

  SpotSnapshot<W> existsAtLeastNTimes(int n) {
    return snapshot().existsAtLeastNTimes(n);
  }
}

extension SingleSnapshotSelector<W extends Widget> on SingleWidgetSelector<W> {
  MultiWidgetSelector<W> get multi {
    return MultiWidgetSelector<W>._(
      props: props,
      parents: parents,
      children: children,
    );
  }

  SingleSpotSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this).single;
  }
}

extension AssertionMatcher<W extends Widget> on SpotSnapshot<W> {
  SingleSpotSnapshot<W> single() {
    return SingleSpotSnapshot(
      selector: selector,
      discovered: discovered.firstOrNull,
      debugCandidates: debugCandidates,
    );
  }
}

extension MutliMatchers<W extends Widget> on SpotSnapshot<W> {
  SpotSnapshot<W> any(void Function(WidgetMatcher<W>) matcher) {
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }
    final found = discovered.any((element) {
      final wm = WidgetMatcher(
        element: element.element,
        selector: element.selector,
      );
      try {
        matcher(wm);
        return true;
      } catch (e) {
        return false;
      }
    });

    if (found) {
      return this;
    }
    throw TestFailure('Expected at least one match for $this, but found none.');
  }

  SpotSnapshot<W> all(void Function(WidgetMatcher<W>) matcher) {
    if (discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }
    final missMatches = discovered.whereNot((element) {
      final wm = WidgetMatcher(
        element: element.element,
        selector: element.selector,
      );
      try {
        matcher(wm);
        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    if (missMatches.isEmpty) {
      return this;
    }
    throw TestFailure(
        'Expected that all candidates match $this, but only ${discovered.length - missMatches.length} of ${discovered.length} did.\n'
        'Missmatches: ${missMatches.map((e) => e.element.toStringDeep()).join(', ')}');
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
        ..createSync()
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
    matcherSb.writeln(
        'extension ${widgetType}Matcher on WidgetMatcher<$widgetType> {');

    final selectorSb = StringBuffer();
    selectorSb.writeln(
      'extension ${widgetType}Selector on WidgetSelector<$widgetType> {',
    );

    for (final DiagnosticsNode prop in props) {
      String matcherVerb = 'has';

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
      if (humanPropName == 'enabled') {
        matcherVerb = 'is';
      }

      addedMethods = true;
      matcherSb.writeln('''
  WidgetMatcher<$widgetType> $matcherVerb${humanPropName.capitalize()}Where(MatchProp<$propType> match) {
    return hasProp<$propType>('$propName', match);
  }
  
  WidgetMatcher<$widgetType> $matcherVerb${humanPropName.capitalize()}($propType value) {
    return hasProp<$propType>('$propName', (it) => it.equals(value));
  }
''');

      selectorSb.writeln('''
  WidgetSelector<$widgetType> with${humanPropName.capitalize()}Matching(MatchProp<$propType> match) {
    return withProp<$propType>('$propName', match);
  }
  
  WidgetSelector<$widgetType> with${humanPropName.capitalize()}($propType value) {
    return withProp<$propType>('$propName', (it) => it.equals(value));
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

import 'package:checks/checks.dart';
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
      return 'bool?';
    }

    if (this is DoubleProperty) {
      return 'double?';
    }

    if (this is IntProperty) {
      return 'int?';
    }
    if (this is IconDataProperty) {
      return 'IconData?';
    }
    if (this is ColorProperty) {
      return 'IconData?';
    }

    if (this is AttributedStringProperty) {
      return 'String?';
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
        return '$genericType';
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
        return '$genericType';
      }
    }

    return 'Object?';
  }
}
