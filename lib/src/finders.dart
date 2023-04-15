// ignore_for_file: unused_element

import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/snapshot.dart' as snapshot_file show snapshot;

class Spot with CommonSpots<Widget> {
  @override
  WidgetSelector? get _self => null;
}

Type _typeOf<T>() => T;

PropMatcher<Text> hasText(String text) {
  return PropMatcher<Text>(
    (it) => it.hasText(text),
    description: 'with text "$text"',
  );
}

PropMatcher<Container> hasColor(Color color) {
  return PropMatcher<Container>(
    (it) => it.widget.color == color,
    description: 'with color $color',
  );
}

extension TextSelector on WidgetSelector<Text> {
  WidgetSelector<Text> hasText(String text) {
    return whereText(
      (s) => text == s,
      description: 'with text "$text"',
    );
  }

  WidgetSelector<Text> containsText(Pattern text) {
    return whereText(
      (s) => s?.contains(text) ?? false,
      description: 'containing "$text"',
    );
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

  WidgetSelector<Text> hasMaxLines(int? maxLines) {
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

// PropMatcher<Text> withText(String text) {
//   return (w) => w.hasText(text);
// }

class WidgetMatcher<W extends Widget> {
  W get widget => element.widget as W;
  final Element element;
  final WidgetSelector<W> selector;

  WidgetMatcher({
    required this.element,
    required this.selector,
  }) : assert(element.widget is W);
}

class PropMatcher<W extends Widget> {
  final void Function(WidgetMatcher<W>) matcher;
  final String description;

  const PropMatcher(
    this.matcher, {
    required this.description,
  });
}

// typedef PropSelector<W extends Widget> = void Function(WidgetSelector<W>);

mixin CommonSpots<T extends Widget> {
  WidgetSelector<T>? get _self;

  WidgetSelector<W> byType<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],

    // TODO decide which one is better
    void Function(WidgetMatcher<W>)? propsFn,
    List<PropMatcher<W>> propsList = const [],
    List<ElementTreeQuery> props = const [],
  }) {
    final type = _typeOf<W>();
    final selector = WidgetSelector<W>._(
      props: [
        ElementTreeQuery(
          (Element e) => e.widget.runtimeType == type,
          description: '$type',
        ),
        ...props
      ],
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );

    return selector;
  }

  WidgetSelector<W> byWidget<W extends Widget>(W widget) {
    return WidgetSelector<W>._(
      props: [
        ElementTreeQuery(
          (Element e) => e.widget == widget,
          description: 'Widget matches $widget',
        )
      ],
    );
  }

  WidgetSelector<W> byElement<W extends Widget>(Element element) {
    return WidgetSelector<W>._(
      props: [
        ElementTreeQuery(
          (Element e) => e == element,
          description: 'Element matches $element',
        ),
      ],
    );
  }

  WidgetSelector childByType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      props: [
        ElementTreeQuery(
          (Element e) => e.widget.runtimeType == type,
          description: 'Widget of type $type',
        )
      ],
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  WidgetSelector childByWidgetPredicate(
    ElementTreeQuery predicate, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      props: [predicate],
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  WidgetSelector childByElementType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      props: [
        ElementTreeQuery(
          (Element e) => e.runtimeType == type,
          description: 'Element of type $type',
        )
      ],
      parents: [
        if (_self != null) _self!,
        ...parents,
      ],
      children: children,
    );
  }

  WidgetSelector<T> whereElement(
    bool Function(Element element) predicate, {
    required String description,
  }) {
    return WidgetSelector<T>._(
      props: [
        ElementTreeQuery(
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
    return _self!.copyWith(
      props: [
        ...this._self!.props,
        ElementTreeQuery(
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

  WidgetSelector text(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return WidgetSelector._(
      props: [
        ElementTreeQuery(
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
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }

  // /// Caution: this is a very expensive operation.
  // WidgetSelector childWidgetWithText(
  //   Type widgetType,
  //   String text, {
  //   bool skipOffstage = true,
  //   List<WidgetSelector> parents = const [],
  //   List<WidgetSelector> children = const [],
  // }) {
  //   final finder = find.widgetWithText(
  //     widgetType,
  //     text,
  //     skipOffstage: skipOffstage,
  //   );
  //   return WidgetSelector._(
  //     finder,
  //     [if (_self != null) _self!, ...parents],
  //     children,
  //   );
  // }

  // WidgetSelector textContaining(
  //   Pattern pattern, {
  //   bool skipOffstage = true,
  //   List<WidgetSelector> parents = const [],
  //   List<WidgetSelector> children = const [],
  // }) {
  //   final finder = find.textContaining(
  //     pattern,
  //     skipOffstage: skipOffstage,
  //   );
  //   return WidgetSelector._(
  //     finder,
  //     [if (_self != null) _self!, ...parents],
  //     children,
  //   );
  // }
  //
  WidgetSelector childByIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      props: [
        ElementTreeQuery(
          (Element e) {
            if (e.widget is Icon) {
              return (e.widget as Icon).icon == icon;
            }
            return false;
          },
          description: 'Widget with icon: "$icon"',
        ),
      ],
      parents: [if (_self != null) _self!, ...parents],
      children: children,
    );
  }
//
// WidgetSelector child(
//   Finder finder, {
//   List<WidgetSelector> parents = const [],
//   List<WidgetSelector> children = const [],
// }) {
//   return WidgetSelector._(
//     finder,
//     [if (_self != null) _self!, ...parents],
//     children,
//   );
// }
}

extension SpotFinder on Finder {
  WidgetSelector get spot {
    return WidgetSelector._(
      props: [
        ElementTreeQuery(
          (e) => evaluate().contains(e),
          description: 'Finder: $description',
        ),
      ],
    );
  }
}

class ElementTreeQuery {
  final bool Function(Element) predicate;
  final String description;

  ElementTreeQuery(this.predicate, {required this.description});
}

/// A [WidgetSelector] that only ever matches a single widget
class SingleWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  SingleWidgetSelector._({
    required super.props,
    super.parents,
    super.children,
  }) : super._(matchesSingleWidget: true);

  SingleSpotSnapshot<W> call() {
    // TODO the last single should not be required
    return single.snapshot().single;
  }
}

class MultiWidgetSelector<W extends Widget> extends WidgetSelector<W> {
  MultiWidgetSelector._({
    required super.props,
    super.parents,
    super.children,
  }) : super._(matchesSingleWidget: false);

  SpotSnapshot<W> call() {
    return snapshot_file.snapshot(this);
  }
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with CommonSpots<W> {
  static final WidgetSelector all = WidgetSelector._(
    props: [
      ElementTreeQuery(
        (e) => true,
        description: 'any Widget',
      )
    ],
  );

  WidgetSelector._({
    required this.props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    this.matchesSingleWidget,
  })  : parents = parents ?? [],
        children = children ?? [];

  final List<ElementTreeQuery> props;
  final List<WidgetSelector> parents;
  final List<WidgetSelector> children;

  /// True when this selector should only match a single widget
  final bool? matchesSingleWidget;

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
    return "${constraints.join(' ')}";
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      final props = this.props.isNotEmpty
          ? this.props.map((e) => e.description).join(' && ')
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
  WidgetSelector<W> get _self => this;

  WidgetSelector<W> copyWith({
    List<ElementTreeQuery>? props,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    bool? single,
  }) {
    return WidgetSelector<W>._(
      props: props ?? this.props,
      parents: parents ?? this.parents,
      children: children ?? this.children,
      matchesSingleWidget: single ?? this.matchesSingleWidget,
    );
  }
}

/// An [Element] in the widget tree that was found with a [WidgetSelector] query
class SpotNode<W extends Widget> {
  /// The parent node from where the node has been found
  final SpotNode? parent;

  /// The selector that has been used to find [value]
  final WidgetSelector<W> selector;

  /// The element that has been found
  final Element value;

  /// All candidates that have been checked with [selector]
  final List<Element> candidates;

  const SpotNode({
    required this.parent,
    required this.selector,
    required this.value,
    required this.candidates,
  });

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType{value: ${value.widget.toStringShallow()}, parent: ${parent?.value.toStringShort()}}';
  }
}

class SpotSnapshot<W extends Widget> {
  final WidgetSelector<W> selector;

  /// All widgets that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  final List<SpotNode<W>> discovered;

  List<W> get matches => discovered.map((e) => e.value.widget as W).toList();

  List<Element> get matchingElements => discovered.map((e) => e.value).toList();

  SpotSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
  });

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${matchingElements.length} matches)}';
  }

  SingleSpotSnapshot<W> get single {
    return SingleSpotSnapshot(
      selector: selector,
      discovered: discovered,
      debugCandidates: debugCandidates,
    );
  }
}

class SingleSpotSnapshot<W extends Widget> extends SpotSnapshot<W>
    implements WidgetMatcher<W> {
  SingleSpotSnapshot({
    required super.selector,
    required super.discovered,
    required super.debugCandidates,
  });

  @override
  Element get element => discovered.single.value;

  @override
  W get widget => element.widget as W;

  @override
  String toString() {
    return 'SingleSpotSnapshot of $selector (${matchingElements.isEmpty ? 'no' : 'one'} match)}';
  }
}

extension SnapshotSelector<W extends Widget> on WidgetSelector<W> {
  SpotSnapshot<W> snapshot() {
    return snapshot_file.snapshot(this);
  }

  MultiWidgetSelector<W> get multi {
    return MultiWidgetSelector<W>._(
      props: props,
      parents: parents,
      children: children,
    );
  }

  MultiWidgetSelector<W> existsAtLeastOnce() {
    return multi;
  }

  SingleWidgetSelector<W> get single {
    return SingleWidgetSelector<W>._(
      props: props,
      parents: parents,
      children: children,
    );
  }

  SingleSpotSnapshot<W> existsOnce() {
    return single.call().existsOnce();
  }

  WidgetSelector<W> any(void Function(WidgetMatcher<W>) matcher) {
    final snapshot = this.snapshot();
    if (snapshot.discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }
    final found = snapshot.discovered.any((element) {
      final wm = WidgetMatcher(
        element: element.value,
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

  WidgetSelector<W> all(void Function(WidgetMatcher<W>) matcher) {
    final snapshot = this.snapshot();
    if (snapshot.discovered.isEmpty) {
      throw Exception('Expected at least one match for $this, but found none');
    }
    final missMatches = snapshot.discovered.whereNot((element) {
      final wm = WidgetMatcher(
        element: element.value,
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
        'Expected that all candidates match $this, but only ${snapshot.discovered.length - missMatches.length} of ${snapshot.discovered.length} did.\n'
        'Missmatches: ${missMatches.map((e) => e.value.toStringDeep()).join(', ')}');
  }

  void doesNotExist() {
    final snapshot = this.snapshot();
    if (snapshot.discovered.isNotEmpty) {
      // TODO create a better error message
      throw Exception(
        'Expected no matches for $this, but found ${snapshot.discovered.length} matches',
      );
    }
  }
}

//
// class _MultiAncestorDescendantFinder extends Finder {
//   _MultiAncestorDescendantFinder(
//     this.ancestors,
//     this.finder, {
//     super.skipOffstage,
//   });
//
//   final List<Finder> ancestors;
//   final Finder finder;
//
//   @override
//   String get description {
//     return '${finder.description} that has ancestors with [${ancestors.map((e) => e.description).join(' && ')}]';
//   }
//
//   @override
//   Iterable<Element> apply(Iterable<Element> candidates) {
//     final evaluate = finder.evaluate().toSet();
//     return candidates.where((Element element) => evaluate.contains(element));
//   }
//
//   @override
//   Iterable<Element> get allCandidates sync* {
//     if (ancestors.isEmpty) {
//       yield* super.allCandidates;
//       return;
//     }
//     final List<Set<Element>> ancestorElements = ancestors.map((ancestor) {
//       return ancestor.evaluate().expand((element) {
//         return collectAllElementsFrom(element, skipOffstage: skipOffstage);
//       }).toSet();
//     }).toList();
//
//     // find elements that are in all iterables
//     final firstList = ancestorElements.removeAt(0);
//     for (final element in firstList) {
//       bool allMatch = true;
//       for (final ancestorElements in ancestorElements) {
//         if (!ancestorElements.contains(element)) {
//           allMatch = false;
//           break;
//         }
//       }
//       if (allMatch) {
//         // element in all ancestors
//         yield element;
//       }
//     }
//   }
// }
//
// class _MultiDescendantsAncestorFinder extends Finder {
//   _MultiDescendantsAncestorFinder(this.descendants, this.finder)
//       : super(skipOffstage: false);
//
//   final Finder finder;
//   final List<Finder> descendants;
//
//   @override
//   String get description {
//     return '${finder.description} which is an ancestor of  [${descendants.map((e) => e.description).join(' && ')}]';
//   }
//
//   @override
//   Iterable<Element> apply(Iterable<Element> candidates) {
//     final allPossible = finder.evaluate().toSet();
//     return candidates.where((Element element) => allPossible.contains(element));
//   }
//
//   @override
//   Iterable<Element> get allCandidates {
//     if (descendants.isEmpty) {
//       return super.allCandidates;
//     }
//     final Iterable<Element> possibleParents = descendants.expand((ancestor) {
//       return ancestor.evaluate().expand((element) {
//         return element.parents.toList();
//       });
//     });
//
//     return possibleParents;
//   }
// }
