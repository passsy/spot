// ignore_for_file: unused_element

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final Spot spot = Spot();

class Spot with CommonSpots<Widget> {
  @override
  WidgetSelector? get _self => null;
}

abstract class WidgetProp {
  bool match(Element element);

  String describe(Element element);
}

/// create delegate for WidgetProp
class WidgetPropDelegate extends WidgetProp {
  final bool Function(Element element) _match;
  final String Function(Element element) _describe;

  WidgetPropDelegate(this._match, this._describe);

  @override
  bool match(Element element) => _match(element);

  @override
  String describe(Element element) => _describe(element);
}

final textWidget = TextWidgetAssertions();

class TextWidgetAssertions {
  WidgetProp hasText(String text) {
    return WidgetPropDelegate(
      (element) =>
          element.widget is Text && (element.widget as Text).data == text,
      (element) => 'Text widget with text "$text"',
    );
  }
}

Type _typeOf<T>() => T;

extension TextWidgetSelector on WidgetSelector<Text> {
  WidgetSelector<Text> hasText(String text) {
    final elements = this.elements;
    for (final element in elements) {
      final textWidget = element.widget as Text;
      if (textWidget.data != text) {
        throw TestFailure(
          'Expected to find text "$text" but found "${textWidget.data}" at ${toStringBreadcrumb()}',
        );
      }
    }
    return this;
  }

  WidgetSelector<Text> containsText(String text) {
    final elements = this.elements;
    for (final element in elements) {
      final textWidget = element.widget as Text;
      if (textWidget.data != text) {
        throw TestFailure(
          'Expected to find text "$text" but found "${textWidget.data}" at ${toStringBreadcrumb()}',
        );
      }
    }
    return this;
  }

  WidgetSelector<Text> hasMaxLines(int maxLines) {
    final elements = this.elements;
    for (final element in elements) {
      final textWidget = element.widget as Text;
      if (textWidget.data != text) {
        throw TestFailure(
          'Expected to find text "$text" but found "${textWidget.data}" at ${toStringBreadcrumb()}',
        );
      }
    }
    return this;
  }
}

PropSelector<Text> withText(String text) {
  return (w) => w.hasText(text);
}

typedef PropSelector<W extends Widget> = void Function(WidgetSelector<W>);

mixin CommonSpots<T extends Widget> {
  WidgetSelector? get _self;

  WidgetSelector<W> byType<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    // Very, very experimental, not likely to stay
    // List<WidgetProp> props = const [],
    List<PropSelector<W>> props = const [],
  }) {
    final type = _typeOf<W>();
    final selector = WidgetSelector<W>._(
      ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      [if (_self != null) _self!, ...parents],
      children,
      props,
    );

    return selector;
  }

  WidgetSelector<W> constrain<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    // Very, very experimental, not likely to stay
    // List<WidgetProp> props = const [],
    List<void Function(WidgetSelector<W>)> props = const [],
  }) {
    final type = _typeOf<W>();
    return WidgetSelector<W>._(
      ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector<W> byWidget<W extends Widget>(W widget) {
    return WidgetSelector<W>._(
      ElementTreeQuery(
        (Element e) => e.widget == widget,
        description: 'Widget matches $widget',
      ),
      [],
      [],
    );
  }

  WidgetSelector<W> byElement<W extends Widget>(Element element) {
    return WidgetSelector<W>._(
      ElementTreeQuery(
        (Element e) => e == element,
        description: 'Element matches $element',
      ),
      [],
      [],
    );
  }

  WidgetSelector childByType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      ElementTreeQuery(
        (Element e) => e.widget.runtimeType == type,
        description: 'Widget of type $type',
      ),
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector childByWidgetPredicate(
    ElementTreeQuery predicate, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      predicate,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector childByElementType(
    Type type, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      ElementTreeQuery(
        (Element e) => e.runtimeType == type,
        description: 'Element of type $type',
      ),
      [
        if (_self != null) _self!,
        ...parents,
      ],
      children,
    );
  }

  WidgetSelector text(
    String text, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    bool findRichText = false,
  }) {
    return WidgetSelector._(
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
      [if (_self != null) _self!, ...parents],
      children,
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
      ElementTreeQuery(
        (Element e) {
          if (e.widget is Icon) {
            return (e.widget as Icon).icon == icon;
          }
          return false;
        },
        description: 'Widget with icon: "$icon"',
      ),
      [if (_self != null) _self!, ...parents],
      children,
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
      ElementTreeQuery(
        (e) => evaluate().contains(e),
        description: 'Finder: $description',
      ),
    );
  }
}

class ElementTreeQuery {
  final bool Function(Element) predicate;
  final String description;

  ElementTreeQuery(this.predicate, {required this.description});
}

class DirectionalElementTreeQuery extends ElementTreeQuery
    implements DirectionalQuery {
  @override
  final Direction direction;

  DirectionalElementTreeQuery(
    super.predicate, {
    required this.direction,
    required super.description,
  });
}

abstract class DirectionalQuery {
  Direction get direction;
}

enum Direction {
  parent,
  child,
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<W extends Widget> with CommonSpots<W> {
  static final WidgetSelector root = WidgetSelector._(
    ElementTreeQuery(
      (e) => true,
      description: 'Root',
    ),
  );

  WidgetSelector._(
    this.query, [
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    List<PropSelector<W>>? props,
  ])  : parents = parents ?? [],
        children = children ?? [],
        props = props ?? [];

  final List<WidgetSelector> parents;
  final List<WidgetSelector> children;

  // TODO combine
  final ElementTreeQuery query;
  final List<PropSelector<W>> props;

  @override
  String toString() {
    final children = this.children.isNotEmpty
        ? 'children: [${this.children.map((e) => e.toString()).join(', ')}]'
        : null;
    final parents = this.parents.isNotEmpty
        ? 'parents: [${this.parents.map((e) => e.toString()).join(', ')}]'
        : null;
    final props = this.props.isNotEmpty
        ? 'props: [${this.props.map((e) => e.toString()).join(', ')}]'
        : null;

    if (this.children.isEmpty && this.parents.isEmpty && this.props.isEmpty) {
      return "'${query.description}'";
    }

    final constraints = [children, parents, props].where((e) => e != null);
    return "'${query.description} with ${constraints.join(', ')}'";
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      return query.description;
    }
    final parentBreadcrumbs = parents.map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return '${parentBreadcrumbs.first} > ${toString()}';
    } else {
      return '[${parentBreadcrumbs.join(' && ')}] > ${toString()}';
    }
  }

  @override
  WidgetSelector get _self => this;

  WidgetSelector copyWith({
    ElementTreeQuery? query,
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
    List<PropSelector<W>>? props,
  }) {
    return WidgetSelector<W>._(
      query ?? this.query,
      parents ?? this.parents,
      children ?? this.children,
      props ?? this.props,
    );
  }
}

extension WidgetTreeSnapshotter<W extends Widget> on WidgetSelector<W> {
  SpotSnapshot<W> snapshot() {
    final rootElement = WidgetsBinding.instance.renderViewElement!;
    final origin = SpotNode(
      selector: WidgetSelector.root,
      parent: null,
      value: rootElement,
      matchesChildren: [rootElement],
      matchesProps: [rootElement],
      matchesParents: [rootElement],
      candidates: [rootElement],
    );

    if (parents.isEmpty) {
      return _takeScopedSnapshot(origin);
    }

    // convert parents to SpotHierarchy
    final Iterable<SpotSnapshot<Widget>> parentSnapshots =
        parents.map((selector) => selector.snapshot());

    return SpotSnapshot(
      selector: this,
      discovered: parentSnapshots.expand((SpotSnapshot<Widget> snapshot) {
        return snapshot.discovered.expand((hierarchy) {
          return _takeScopedSnapshot(hierarchy).discovered;
        });
      }).toList(),
      candidates:
          parentSnapshots.expand((element) => element.candidates).toList(),
      // matchingElements: [], // TODO
      searchResults: {
        // for (final snapshot in hierarchies)
        //   for (final result in snapshot.searchResults.entries)
        //     ..._takeScopedSnapshot(result.value).searchResults,
      },

      //
      // hierarchies.expand((SpotSnapshot<Widget> snapshot) {
      //   return snapshot.matchHierarchies.expand((hierarchy) {
      //     return _takeScopedSnapshot(hierarchy).matchHierarchies;
      //   });
      // }).toList(),
    );
  }

  SpotSnapshot<W> _takeScopedSnapshot(SpotNode origin) {
    final candidates = [origin.value] +
        collectAllElementsFrom(origin.value, skipOffstage: true).toList();

    // final node = SpotNode(
    //   selector: this,
    //   parent: origin,
    //   value: origin.value,
    //   candidates: candidates,
    // );

    // First find all elements matching the query
    final List<SpotNode<W>> queryMatches =
        candidates.where((e) => query.predicate(e)).map((e) {
      return SpotNode<W>(
        selector: this,
        parent: origin,
        value: e,
        candidates: candidates,
      );
    }).toList();

    final List<SpotNode> propMatches = [];
    final Map<WidgetSelector, SpotSnapshot> childSearchResults = {};

    final List<SpotNode<W>> matchingChildNodes = [];
    final List<SpotNode<W>> matchingPropNodes = [];

    // Then check for every queryMatch if the children and props match
    for (final SpotNode<W> queryMatch in queryMatches) {
      if (children.isEmpty) {
        matchingChildNodes.add(queryMatch);
      } else {
        for (final WidgetSelector<Widget> childMatcher in children) {
          final SpotSnapshot<Widget> snapshot =
              childMatcher._takeScopedSnapshot(queryMatch);
          if (snapshot.discovered.isNotEmpty) {
            // final selector = childMatcher.constrain(children: [childMatcher]);
            // childSearchResults.putIfAbsent(selector, () => snapshot);
            matchingChildNodes.add(queryMatch);
          }
        }
      }

      if (props.isEmpty) {
        matchingPropNodes.add(queryMatch);
      } else {
        for (final PropSelector<W> prop in props) {
          try {
            final selector = queryMatch.selector;
            prop.call(selector);
            final selectorWithSingleProp =
                selector.copyWith(children: [], props: [prop]);
            propMatches.add(
              SpotNode(
                selector: selectorWithSingleProp,
                parent: queryMatch.parent,
                value: queryMatch.value,
                candidates: queryMatch.parent!.candidates,
              ),
            );
          } catch (e) {
            // allPropsMatch = false;
          }
        }
      }
    }

    final List<SpotNode> discovered = () {
      final List<SpotNode> matchesBoth = [];
      for (final childMatch in matchingChildNodes) {
        if (matchingPropNodes.contains(childMatch)) {
          matchesBoth.add(childMatch);
        }
      }
      return matchesBoth;
    }();

    return SpotSnapshot(
      selector: this,
      discovered: discovered,
      candidates: candidates,
      searchResults: {
        this: discovered,
        ...childSearchResults.map((key, value) {
          return MapEntry(key, value.discovered);
        }),
      },
    );

    //
    // // walk all children until we find all child matches
    // final List<Element> childrenMatches = [];
    // for (final childMatcher in children) {
    //   final SpotSnapshot<Widget> childSnapshot = childMatcher.snapshot();
    //   if (childSnapshot.matchingElements.isNotEmpty) {
    //     childrenMatches.addAll(childSnapshot.matchingElements);
    //   }
    // }
    // //
    // // final childrenMatches = children.isEmpty
    // //     ? candidates
    // //     : candidates.where((candidate) {
    // //         final matchingConstraints = children
    // //             .where((constraint) => constraint.query.predicate(candidate));
    // //         // must match all children
    // //         return matchingConstraints.length == children.length;
    // //       }).toList();
    //
    // // TODO make this work
    // final propMatches = candidates;
    //
    // // final matches = queryMatches.map((e) {
    // //   return MapEntry(
    // //     e.value,
    // //     SpotHierarchy(
    // //       origin: origin,
    // //       actual: e.key,
    // //       matchesChildren: childrenMatches,
    // //       candidates: candidates,
    // //       matchesProps: propMatches,
    // //       // no parents, all candidates match
    // //       matchesParents: candidates,
    // //       selector: origin.selector,
    // //     ),
    // //   );
    // // }).toList();
    //
    // return SpotSnapshot(
    //   selector: this,
    //   matchingElements: [],
    //   searchResults: {
    //     query: [
    //       SpotHierarchy(
    //         origin: origin,
    //         actual: origin.actual,
    //         matchesChildren: childrenMatches,
    //         candidates: candidates,
    //         matchesProps: propMatches,
    //         // no parents, all candidates match
    //         matchesParents: candidates,
    //         selector: origin.selector,
    //       )
    //     ],
    //   },
    //   // searchResults: {
    //   //   for (final match in matches) match.key: match.value,
    //   // },
    // );
  }

  /// Finds all matches for a parent in the widget tree
  List<SpotNode> _findMatchesForParent(WidgetSelector parent) {
    return [];
    // final parentSnapshot = parent.snapshot();
    // return parentSnapshot.matches.map((e) {
    //   collectAllElementsFrom(parentSnapshot.matches, skipOffstage: true)
    //       .toList();
    //   final queryMatches = candidates.where((e) => query.predicate(e)).toList();
    //   final childrenMatches = queryMatches.where((e) {
    //     final children = collectAllElementsFrom(e, skipOffstage: true);
    //     return children.any((e) => children.any((e) => query.predicate(e)));
    //   }).toList();
    //   return SpotSnapshot(
    //     selector: this,
    //     matchHierarchies: queryMatches.map((e) {
    //       return SpotHierarchy(
    //         parent: rootElement,
    //         actual: e,
    //         matchesChildren: childrenMatches,
    //         candidates: candidates,
    //       );
    //     }).toList(),
    //     matchesWithoutParents: [],
    //   );
    // })
    // .;
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

  /// All [candidates] that match the [WidgetSelector.children] constraints
  final List<Element>? matchesChildren;

  /// All [candidates] that match the [WidgetSelector.props] constraints
  final List<Element>? matchesProps;

  /// All [candidates] that match the [WidgetSelector.parents] constraints
  final List<Element>? matchesParents;

  const SpotNode({
    required this.parent,
    required this.selector,
    required this.value,
    required this.candidates,
    this.matchesChildren,
    this.matchesProps,
    this.matchesParents,
  });

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType{parent: ${parent?.value.toStringShort()}, value: ${value.widget.toStringShallow()}}';
  }
}

class SpotSnapshot<W extends Widget> {
  final WidgetSelector selector;

  final List<SpotNode> discovered;

  final List<Element> candidates;

  final Map<WidgetSelector, List<SpotNode>> searchResults;

  List<W> get matches => discovered.map((e) => e.value.widget as W).toList();

  List<Element> get matchingElements => discovered.map((e) => e.value).toList();

  SpotSnapshot({
    required this.selector,
    required this.searchResults,
    required this.discovered,
    required this.candidates,
  }) {
    // matches = searchResults.values.map((e) => e.actual!.widget as W).toList();
    // matchingElements = searchResults.values.map((e) => e.actual!).toList();
  }

  @override
  String toString() {
    return 'SpotSnapshot{selector: $selector, matches: ${matchingElements.map((it) => it.toStringShallow()).join(', ')},}';
  }
}

extension WidgetSelectorMatcher<T extends Widget> on WidgetSelector<T> {
  // WidgetSelector forEach(
  //   void Function(Widget widget, Element element) matcher,
  // ) {
  //   final elements = finder.evaluate().toList();
  //   for (final element in elements) {
  //     matcher(element.widget, element);
  //   }
  //   return this;
  // }
  //
  // WidgetSelector<Widget> matchProps(List<WidgetProp> matchers) {
  //   final elements = finder.evaluate().toList();
  //   for (final element in elements) {
  //     for (final matcher in matchers) {
  //       final match = matcher.match(element);
  //       if (!match) {
  //         throw Exception(
  //           'Failed to match ${matcher.describe(element)} with ${element.widget}',
  //         );
  //       }
  //     }
  //   }
  //   return this;
  // }
  //
  // WidgetSelector<T> whereWidget(
  //   bool Function(T widget) predicate,
  // ) {
  //   final elements = finder.evaluate().toList();
  //   for (final element in elements) {
  //     final widget = element.widget as T;
  //     final matching = predicate(widget);
  //   }
  //   return WidgetSelector<T>._(predicate, parents, children);
  // }

  /// Returns the elements that match this selector
  // TODO Make errors better.
  // This method works great, but errors are impossible to formulate because we only get the result.
  // Therefore, move this method in to existsOnce() and co for better error messages.
  // Idea: Return whole search tree with all information, then use that to generate error messages.
  List<Element> get elements {
    final snapshot = this.snapshot();
    return snapshot.matchingElements;
  }

  Element get element {
    final elements = this.elements;
    if (elements.isEmpty) {
      throw Exception('Could not find $this in widget tree');
    }
    return elements.first;
  }

  WidgetSelector<T> existsOnce() {
    final errorBuilder = StringBuffer();

    final snapshot = this.snapshot();
    if (snapshot.matchingElements.length == 1) {
      return this;
    }

    // early exit when finder finds nothing
    if (snapshot.matchingElements.isEmpty) {
      if (parents.isNotEmpty) {
        final selectorWithoutParents = copyWith(parents: []);
        final selectorWithoutParentsSnapshot =
            selectorWithoutParents.snapshot();
        if (selectorWithoutParentsSnapshot.matchingElements.isNotEmpty) {
          errorBuilder.writeln('Could not find $this in widget tree, '
              'but found matches when searching (without parents) $selectorWithoutParentsSnapshot');

          errorBuilder.writeln(
              'Please check the ${selectorWithoutParentsSnapshot.matchingElements.length} '
              'matches for ${toStringBreadcrumb()} and adjust the parent constraints of $this accordingly:');
          int index = 0;
          for (final Widget match in selectorWithoutParentsSnapshot.matches) {
            index++;
            errorBuilder
                .writeln('Possible match #$index: ${match.toStringDeep()}');
          }
          fail(errorBuilder.toString());
        }
      }

      if (children.isNotEmpty) {
        final selectorWithoutChildren = copyWith(children: []);
        final selectorWithoutChildrenSnapshot =
            selectorWithoutChildren.snapshot();
        if (selectorWithoutChildrenSnapshot.matchingElements.isNotEmpty) {
          errorBuilder.writeln('Could not find $this in widget tree, '
              'but found matches when searching (without children) $selectorWithoutChildrenSnapshot');
          errorBuilder.writeln(
              'Please check the ${selectorWithoutChildrenSnapshot.matchingElements.length} '
              'matches for ${toStringBreadcrumb()} and adjust the child constraints of $this accordingly:');
          int index = 0;
          for (final Widget match in selectorWithoutChildrenSnapshot.matches) {
            index++;
            errorBuilder
                .writeln('Possible match #$index: ${match.toStringDeep()}');
          }
          fail(errorBuilder.toString());
        }
      }

      // default when no matches are found and no better error message could be created
      errorBuilder.writeln('Could not find $this in widget tree');
      _dumpWidgetTree(errorBuilder);
      errorBuilder.writeln('Could not find $this in widget tree');
      fail(errorBuilder.toString());
    }
    //
    // final List<Element> matchingParents = [];
    // final List<Element> matchingChildren = [];
    // final List<Element> matchingProps = [];
    //
    // if (parents.isNotEmpty) {
    //   // check if elements matches parents
    //   final found = elements
    //       .where((candidate) {
    //         return parents.every((WidgetSelector parent) {
    //           final candidateParents = candidate.parents;
    //           return parent.elements.any((e) => candidateParents.contains(e));
    //         });
    //       })
    //       .toSet()
    //       .toList();
    //   matchingParents.addAll(found);
    // }
    // if (children.isNotEmpty) {
    //   final found = elements
    //       .where((candidate) {
    //         return candidate.children.contains(candidate);
    //       })
    //       .toSet()
    //       .toList();
    //   matchingChildren.addAll(found);
    // }
    //
    // final matches = <Element>{
    //   ...matchingParents,
    //   ...matchingChildren,
    //   ...matchingProps,
    // }.toList();
    // if (matches.isEmpty) {
    //   int i = 0;
    //   for (final parent in parents) {
    //     i++;
    //     final possibleParents = parent.elements;
    //     errorBuilder.writeln(
    //       'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
    //     );
    //     errorBuilder.writeln(
    //       'There are ${possibleParents.length} possible parents for '
    //       '$this matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
    //       'The widget trees starting at #$i ${parent.query.description} are:',
    //     );
    //     int index = 0;
    //     for (final possibleParent in possibleParents) {
    //       errorBuilder.writeln("Possible parent $index:");
    //       errorBuilder.writeln(possibleParent.toStringDeep());
    //       index++;
    //     }
    //   }
    //
    //   errorBuilder.writeln(
    //     'Could not find $this as child of ${parents.toStringBreadcrumb()}',
    //   );
    //   fail(errorBuilder.toString());
    // }
    //
    // if (matches.length > 1) {
    //   if (parents.isEmpty) {
    //     errorBuilder.writeln(
    //       'Found ${matches.length} elements matching $this in widget tree, '
    //       'expected only one',
    //     );
    //     _dumpWidgetTree(errorBuilder);
    //
    //     errorBuilder.writeln(
    //       'Found ${matches.length} elements matching $this in widget tree, '
    //       'expected only one',
    //     );
    //     fail(errorBuilder.toString());
    //   } else {
    //     errorBuilder.writeln(
    //       'Found ${matches.length} elements matching $this as child of ${parents.toStringBreadcrumb()}, '
    //       'exepcting only one',
    //     );
    //     int index = 0;
    //     for (final candidate in matches) {
    //       errorBuilder.writeln("Possible candidate $index:");
    //       errorBuilder.writeln(candidate.toStringDeep());
    //       index++;
    //     }
    //
    //     errorBuilder.writeln(
    //       'Found more than one $this as child of ${parents.toStringBreadcrumb()}',
    //     );
    //     fail(errorBuilder.toString());
    //   }
    // }

    // all fine, found 1 element
    assert(
      snapshot.matchingElements.length == 1,
      'Found ${snapshot.matchingElements.length} elements',
    );
    // return WidgetSelector<T>._(predicate, parents, children);
    // return WidgetSelector<T>._(
    //     ElementTreeQuery((e) => false, description: 'Exactly Element X'),
    //     parents,
    //     children);
    return this;
  }

  WidgetSelector existsAtLeastOnce() {
    // final Iterable<Element> elements = finder.evaluate();
    //
    // final match = elements.firstWhereOrNull((element) {
    //   if (parents.isEmpty) return true;
    //   return parents.any((WidgetSelector parent) {
    //     return parent.finder.apply(element.parents).isNotEmpty;
    //   });
    // });
    //
    // final errorBuilder = StringBuffer();
    // if (match == null) {
    //   if (parents.isEmpty) {
    //     errorBuilder.writeln('Could not find $this in widget tree');
    //     _dumpWidgetTree(errorBuilder);
    //     errorBuilder.writeln('Could not find $this in widget tree');
    //     fail(errorBuilder.toString());
    //   } else {
    //     errorBuilder.writeln(
    //       'Could not find $this as child of ${parents.toStringBreadcrumb()}',
    //     );
    //     int i = 0;
    //     for (final parent in parents) {
    //       i++;
    //       errorBuilder.writeln('Children of #$i $parent:');
    //       errorBuilder.writeln(parent.finder.evaluate().first.toStringDeep());
    //       errorBuilder.writeln(
    //         'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
    //       );
    //       fail(errorBuilder.toString());
    //     }
    //   }
    // }

    // all fine, found at least 1 element
    assert(elements.isNotEmpty);
    return this;
  }

  WidgetSelector doesNotExist() {
    // TODO
    // expect(finder, findsNothing);
    return this;
  }
}

void _dumpWidgetTree(StringBuffer buffer) {
  final rootElement = WidgetsBinding.instance.renderViewElement;
  if (rootElement != null) {
    buffer.writeln(rootElement.toStringDeep());
  } else {
    buffer.writeln('<no tree currently mounted>');
  }
}

extension ElementParent on Element {
  Element? get parent {
    Element? parent;
    visitAncestorElements((element) {
      parent = element;
      return false;
    });
    return parent;
  }

  Iterable<Element> get parents sync* {
    Element? element = this;
    while (element != null) {
      yield element;
      element = element.parent;
    }
  }

  Iterable<Element> get children sync* {
    final List<Element> found = [];
    visitChildren(found.add);
    yield* found;
  }
}

extension on List<WidgetSelector> {
  String toStringBreadcrumb() {
    if (this.isEmpty) {
      return '[]';
    }
    final parentBreadcrumbs = map((e) => e.toStringBreadcrumb());
    if (parentBreadcrumbs.length == 1) {
      return parentBreadcrumbs.first;
    } else {
      return '[${parentBreadcrumbs.join(' && ')}]';
    }
  }
}

class _MultiAncestorDescendantFinder extends Finder {
  _MultiAncestorDescendantFinder(
    this.ancestors,
    this.finder, {
    super.skipOffstage,
  });

  final List<Finder> ancestors;
  final Finder finder;

  @override
  String get description {
    return '${finder.description} that has ancestors with [${ancestors.map((e) => e.description).join(' && ')}]';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final evaluate = finder.evaluate().toSet();
    return candidates.where((Element element) => evaluate.contains(element));
  }

  @override
  Iterable<Element> get allCandidates sync* {
    if (ancestors.isEmpty) {
      yield* super.allCandidates;
      return;
    }
    final List<Set<Element>> ancestorElements = ancestors.map((ancestor) {
      return ancestor.evaluate().expand((element) {
        return collectAllElementsFrom(element, skipOffstage: skipOffstage);
      }).toSet();
    }).toList();

    // find elements that are in all iterables
    final firstList = ancestorElements.removeAt(0);
    for (final element in firstList) {
      bool allMatch = true;
      for (final ancestorElements in ancestorElements) {
        if (!ancestorElements.contains(element)) {
          allMatch = false;
          break;
        }
      }
      if (allMatch) {
        // element in all ancestors
        yield element;
      }
    }
  }
}

class _MultiDescendantsAncestorFinder extends Finder {
  _MultiDescendantsAncestorFinder(this.descendants, this.finder)
      : super(skipOffstage: false);

  final Finder finder;
  final List<Finder> descendants;

  @override
  String get description {
    return '${finder.description} which is an ancestor of  [${descendants.map((e) => e.description).join(' && ')}]';
  }

  @override
  Iterable<Element> apply(Iterable<Element> candidates) {
    final allPossible = finder.evaluate().toSet();
    return candidates.where((Element element) => allPossible.contains(element));
  }

  @override
  Iterable<Element> get allCandidates {
    if (descendants.isEmpty) {
      return super.allCandidates;
    }
    final Iterable<Element> possibleParents = descendants.expand((ancestor) {
      return ancestor.evaluate().expand((element) {
        return element.parents.toList();
      });
    });

    return possibleParents;
  }
}
