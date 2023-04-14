import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

SpotSnapshot<W> snapshot<W extends Widget>(WidgetSelector<W> selector) {
  final rootElement = WidgetsBinding.instance.renderViewElement!;
  final origin = SpotNode(
    selector: WidgetSelector.all,
    parent: null,
    value: rootElement,
    matchesChildren: [rootElement],
    matchesProps: [rootElement],
    matchesParents: [rootElement],
    candidates: [rootElement],
  );

  if (selector.parents.isEmpty) {
    return _takeScopedSnapshot(selector, origin);
  }

  // convert parents to SpotHierarchy
  final Iterable<SpotSnapshot<Widget>> parentSnapshots =
      selector.parents.map((selector) => selector.snapshot());

  // Take a sn from parentSnapshots that exist in all snapshots
  final List<SpotNode<W>> discovered =
      parentSnapshots.map((SpotSnapshot<Widget> snapshot) {
    final selectorWithoutParents = selector.copyWith(parents: []);

    if (snapshot.discovered.isEmpty) {
      return <SpotNode<W>>[];
    }

    final groups = snapshot.discovered.associateWith((parent) {
      return _takeScopedSnapshot(selectorWithoutParents, parent).discovered;
    });

    final common = groups.values.reduce((value, element) {
      return value.intersectWithSelector(element, (it) => it.value).toList();
    }) as List<SpotNode<W>>;

    return common;
  }).reduce((value, element) {
    return value.intersectWithSelector(element, (it) => it.value).toList();
  });

  return SpotSnapshot<W>(
    selector: selector,
    discovered: discovered,
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

extension IterableIntersect<E> on Iterable<E> {
  Iterable<E> intersectWithSelector(
      Iterable<E> other, Object Function(E) select) sync* {
    final second = HashSet.from(other.map(select));
    final output = HashSet<E>();
    for (final current in this) {
      final mapped = select(current);
      if (second.contains(mapped)) {
        if (output.add(current)) {
          yield current;
        }
      }
    }
  }
}

SpotSnapshot<W> _takeScopedSnapshot<W extends Widget>(
    WidgetSelector<W> selector, SpotNode origin) {
  // TODO pass in as argument?
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
      candidates.where((e) => selector.query.predicate(e)).map((e) {
    return SpotNode<W>(
      selector: selector,
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
    if (selector.children.isEmpty) {
      matchingChildNodes.add(queryMatch);
    } else {
      for (final WidgetSelector<Widget> childMatcher in selector.children) {
        final SpotSnapshot<Widget> snapshot =
            _takeScopedSnapshot(childMatcher, queryMatch);
        if (snapshot.discovered.isNotEmpty) {
          // final selector = childMatcher.constrain(children: [childMatcher]);
          // childSearchResults.putIfAbsent(selector, () => snapshot);
          matchingChildNodes.add(queryMatch);
        }
      }
    }

    // TODO remove when commenting in lines below
    matchingPropNodes.add(queryMatch);

    // if (props.isEmpty) {
    //   matchingPropNodes.add(queryMatch);
    // } else {
    //   for (final PropSelector<W> prop in props) {
    //     try {
    //       final selector = queryMatch.selector;
    //       prop.call(selector);
    //       final selectorWithSingleProp =
    //           selector.copyWith(children: [], props: [prop]);
    //       propMatches.add(
    //         SpotNode(
    //           selector: selectorWithSingleProp,
    //           parent: queryMatch.parent,
    //           value: queryMatch.value,
    //           candidates: queryMatch.parent!.candidates,
    //         ),
    //       );
    //     } catch (e) {
    //       // allPropsMatch = false;
    //     }
    //   }
    // }
  }

  final List<SpotNode<W>> discovered = () {
    final List<SpotNode<W>> matchesBoth = [];
    for (final childMatch in matchingChildNodes) {
      if (matchingPropNodes.contains(childMatch)) {
        matchesBoth.add(childMatch);
      }
    }
    return matchesBoth;
  }();

  return SpotSnapshot(
    selector: selector,
    discovered: discovered,
    candidates: candidates,
    searchResults: {
      // selector: discovered,
      // ...childSearchResults.map(
      //   (key, value) {
      //     return MapEntry(key, value.discovered);
      //   },
      // ),
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

extension WidgetSelectorMatcher<W extends Widget> on SpotSnapshot<W> {
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

  // TODO move to snapshot
  // List<Element> get elements {
  //   final snapshot = this.snapshot();
  //   return snapshot.matchingElements;
  // }
  //
  // Element get element {
  //   final elements = this.elements;
  //   if (elements.isEmpty) {
  //     throw Exception('Could not find $selector in widget tree');
  //   }
  //   return elements.first;
  // }

  SpotSnapshot<W> existsOnce() {
    final errorBuilder = StringBuffer();

    if (matchingElements.length == 1) {
      return this;
    }

    // early exit when finder finds nothing
    if (matchingElements.isEmpty) {
      if (selector.parents.isNotEmpty) {
        final selectorWithoutParents = selector.copyWith(parents: []);
        final selectorWithoutParentsSnapshot =
            selectorWithoutParents.snapshot();
        if (selectorWithoutParentsSnapshot.matchingElements.isNotEmpty) {
          errorBuilder.writeln('Could not find $selector in widget tree, '
              'but found matches when searching (without parents) $selectorWithoutParentsSnapshot');

          errorBuilder.writeln(
              'Please check the ${selectorWithoutParentsSnapshot.matchingElements.length} '
              'matches for ${selector.toStringBreadcrumb()} and adjust the parent constraints of $selector accordingly:');
          int index = 0;
          for (final Widget match in selectorWithoutParentsSnapshot.matches) {
            index++;
            errorBuilder
                .writeln('Possible match #$index: ${match.toStringDeep()}');
          }
          fail(errorBuilder.toString());
        }
      }

      if (selector.children.isNotEmpty) {
        final selectorWithoutChildren = selector.copyWith(children: []);
        final selectorWithoutChildrenSnapshot =
            selectorWithoutChildren.snapshot();
        if (selectorWithoutChildrenSnapshot.matchingElements.isNotEmpty) {
          errorBuilder.writeln('Could not find $selector in widget tree, '
              'but found matches when searching (without children) $selectorWithoutChildrenSnapshot');
          errorBuilder.writeln(
              'Please check the ${selectorWithoutChildrenSnapshot.matchingElements.length} '
              'matches for ${selector.toStringBreadcrumb()} and adjust the child constraints of $selector accordingly:');
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
      errorBuilder.writeln('Could not find $selector in widget tree');
      _dumpWidgetTree(errorBuilder);
      errorBuilder.writeln('Could not find $selector in widget tree');
      fail(errorBuilder.toString());
    }

    final List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria = [];
    criteria.add((selector) {
      return selector.copyWith(query: selector.query);
    });
    if (selector.props != null) {
      criteria.add((selector) {
        return selector.copyWith(props: selector.props);
      });
    }
    for (final parent in selector.parents) {
      criteria.add((selector) {
        return selector.copyWith(parents: [...selector.parents, parent]);
      });
    }
    for (final child in selector.children) {
      criteria.add((selector) {
        return selector.copyWith(children: [...selector.children, child]);
      });
    }

    final criteriaSubset = subset(criteria);

    WidgetSelector<W> buildSelector(
      List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria,
    ) {
      WidgetSelector<W> s = selector.copyWith(
        query: selector.query,
        props: selector.props,
        parents: [],
        children: [],
      );
      for (final criteria in criteria) {
        s = criteria(s);
      }
      return s;
    }

    print('criteriaSubset: $criteriaSubset');
    if (criteriaSubset.length > 1) {
      for (final lessSpecificCriteria in criteriaSubset) {
        final lessSpecificSelector = buildSelector(lessSpecificCriteria);
        final lessSpecificSnapshot = lessSpecificSelector.snapshot();
        // error that selector could not be found, but instead spot detected lessSpecificSnapshot, which might be useful
        if (lessSpecificSnapshot.matchingElements.isNotEmpty) {
          errorBuilder.writeln(
              'Could not find $selector in widget tree, but found matches when searching $lessSpecificSnapshot');
          errorBuilder.writeln(
              'Please check the ${lessSpecificSnapshot.matchingElements.length} '
              'matches for ${selector.toStringBreadcrumb()} and adjust the constraints of $selector accordingly:');
          int index = 0;
          for (final Widget match in lessSpecificSnapshot.matches) {
            index++;
            errorBuilder
                .writeln('Possible match #$index: ${match.toStringDeep()}');
          }
          fail(errorBuilder.toString());
        }
      }
    }
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
    //       'Could not find $selector as child of #$i ${parent.toStringBreadcrumb()}',
    //     );
    //     errorBuilder.writeln(
    //       'There are ${possibleParents.length} possible parents for '
    //       '$selector matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
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
    //     'Could not find $selector as child of ${parents.toStringBreadcrumb()}',
    //   );
    //   fail(errorBuilder.toString());
    // }
    //
    if (discovered.length > 1) {
      if (selector.parents.isEmpty) {
        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector in widget tree, '
          'expected only one',
        );
        _dumpWidgetTree(errorBuilder);

        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector in widget tree, '
          'expected only one',
        );
        fail(errorBuilder.toString());
      } else {
        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector as child of ${selector.parents.toStringBreadcrumb()}, '
          'exepcting only one',
        );
        int index = 0;
        for (final candidate in discovered) {
          errorBuilder.writeln("Possible candidate $index:");
          errorBuilder.writeln(candidate.value.toStringDeep());
          index++;
        }

        errorBuilder.writeln(
          'Found more than one $selector as child of ${selector.parents.toStringBreadcrumb()}',
        );
        fail(errorBuilder.toString());
      }
    }

    // all fine, found 1 element
    assert(
      matchingElements.length == 1,
      'Found ${matchingElements.length} elements',
    );
    // return WidgetSelector<T>._(predicate, parents, children);
    // return WidgetSelector<T>._(
    //     ElementTreeQuery((e) => false, description: 'Exactly Element X'),
    //     parents,
    //     children);
    return this;
  }

  SpotSnapshot<W> existsAtLeastOnce() {
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
    //     errorBuilder.writeln('Could not find $selector in widget tree');
    //     _dumpWidgetTree(errorBuilder);
    //     errorBuilder.writeln('Could not find $selector in widget tree');
    //     fail(errorBuilder.toString());
    //   } else {
    //     errorBuilder.writeln(
    //       'Could not find $selector as child of ${parents.toStringBreadcrumb()}',
    //     );
    //     int i = 0;
    //     for (final parent in parents) {
    //       i++;
    //       errorBuilder.writeln('Children of #$i $parent:');
    //       errorBuilder.writeln(parent.finder.evaluate().first.toStringDeep());
    //       errorBuilder.writeln(
    //         'Could not find $selector as child of #$i ${parent.toStringBreadcrumb()}',
    //       );
    //       fail(errorBuilder.toString());
    //     }
    //   }
    // }

    // all fine, found at least 1 element
    // assert(elements.isNotEmpty);
    return this;
  }

  SpotSnapshot<W> doesNotExist() {
    // TODO
    // expect(finder, findsNothing);
    return this;
  }

  List<List<T>> subset<T>(List<T> list) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j <= list.length; j++) {
        result.add(list.sublist(i, j));
      }
    }
    return result.sortedByDescending((it) => it.length);
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

//
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
