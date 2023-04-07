// ignore_for_file: unused_element

import 'package:collection/collection.dart';
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

void Function(WidgetSelector<Text>) withText(String text) {
  return (w) => w.hasText(text);
}

mixin CommonSpots<T extends Widget> {
  WidgetSelector? get _self;

  WidgetSelector<W> byType<W extends Widget>({
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
    // Very, very experimental, not likely to stay
    // List<WidgetProp> props = const [],
    List<void Function(WidgetSelector<W>)> props = const [],
  }) {
    final type = _typeOf<W>();
    return WidgetSelector<W>._(
      find.byElementPredicate((element) {
        if (element.widget.runtimeType != type) return false;
        for (final void Function(WidgetSelector<W>) prop in props) {
          try {
            prop.call(spot.byElement(element));
            continue;
          } catch (e) {
            return false;
          }
        }
        return true;
      }),
      [if (_self != null) _self!, ...parents],
      children,
    );
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
      find.byElementPredicate((element) {
        if (element.widget.runtimeType != type) return false;
        for (final void Function(WidgetSelector<W>) prop in props) {
          try {
            prop.call(spot.byElement(element));
            continue;
          } catch (e) {
            return false;
          }
        }
        return true;
      }),
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector<W> byWidget<W extends Widget>(W widget) {
    return WidgetSelector<W>._(
      find.byWidget(widget),
      [],
      [],
    );
  }

  WidgetSelector<W> byElement<W extends Widget>(Element element) {
    return WidgetSelector<W>._(
      find.byElementPredicate((e) => e == element),
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
      find.byType(type),
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector childByWidgetPredicate(
    WidgetPredicate predicate, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      find.byWidgetPredicate(predicate),
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
      find.byElementType(type),
      [
        if (_self != null) _self!,
        ...parents,
      ],
      children,
    );
  }

  WidgetSelector text(
    String text, {
    bool findRichText = false,
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.text(
      text,
      findRichText: findRichText,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  /// Caution: this is a very expensive operation.
  WidgetSelector childWidgetWithText(
    Type widgetType,
    String text, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.widgetWithText(
      widgetType,
      text,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector textContaining(
    Pattern pattern, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.textContaining(
      pattern,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector childByIcon(
    IconData icon, {
    bool skipOffstage = true,
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    final finder = find.byIcon(
      icon,
      skipOffstage: skipOffstage,
    );
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }

  WidgetSelector child(
    Finder finder, {
    List<WidgetSelector> parents = const [],
    List<WidgetSelector> children = const [],
  }) {
    return WidgetSelector._(
      finder,
      [if (_self != null) _self!, ...parents],
      children,
    );
  }
}

extension SpotFinder on Finder {
  WidgetSelector get spot {
    return WidgetSelector._(this);
  }
}

/// Represents a chain of widgets in the widget tree that can be asserted
///
/// Compared to normal [Finder], this gives great error messages along the chain
class WidgetSelector<T extends Widget> with CommonSpots<T> {
  WidgetSelector._(
    this.standaloneFinder, [
    List<WidgetSelector>? parents,
    List<WidgetSelector>? children,
  ])  : parents = parents ?? [],
        children = children ?? [];

  final Finder standaloneFinder;
  final List<WidgetSelector> parents;
  final List<WidgetSelector> children;

  Finder get finder {
    final ancestors = parents;
    final descendants = children;
    if (descendants.isEmpty && ancestors.isEmpty) {
      return standaloneFinder;
    }

    if (descendants.isEmpty) {
      if (ancestors.length == 1) {
        return find.descendant(
          of: ancestors.first.finder,
          matching: standaloneFinder,
        );
      }
      return _MultiAncestorDescendantFinder(
        ancestors.map((e) => e.finder).toList(),
        standaloneFinder,
      );
    }

    if (ancestors.isEmpty) {
      if (descendants.length == 1) {
        return find.ancestor(
          of: descendants.first.finder,
          matching: standaloneFinder,
        );
      }
      return _MultiDescendantsAncestorFinder(
        descendants.map((e) => e.finder).toList(),
        standaloneFinder,
      );
    }

    // this always works but produces unnecessary nesting and harder to read error messages
    return _MultiAncestorDescendantFinder(
      ancestors.map((e) => e.finder).toList(),
      _MultiDescendantsAncestorFinder(
        descendants.map((e) => e.finder).toList(),
        standaloneFinder,
      ),
    );
  }

  @override
  String toString() {
    return "'${standaloneFinder.description}'";
  }

  String toStringBreadcrumb() {
    final parents = this.parents;

    if (parents.isEmpty) {
      return standaloneFinder.description;
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
}

extension WidgetSelectorMatcher<T extends Widget> on WidgetSelector<T> {
  WidgetSelector forEach(
    void Function(Widget widget, Element element) matcher,
  ) {
    final elements = finder.evaluate().toList();
    for (final element in elements) {
      matcher(element.widget, element);
    }
    return this;
  }

  WidgetSelector<Widget> matchProps(List<WidgetProp> matchers) {
    final elements = finder.evaluate().toList();
    for (final element in elements) {
      for (final matcher in matchers) {
        final match = matcher.match(element);
        if (!match) {
          throw Exception(
            'Failed to match ${matcher.describe(element)} with ${element.widget}',
          );
        }
      }
    }
    return this;
  }

  WidgetSelector<T> whereWidget(
    bool Function(T widget) predicate,
  ) {
    final elements = finder.evaluate().toList();
    for (final element in elements) {
      final widget = element.widget as T;
      final matching = predicate(widget);
    }
    return WidgetSelector<T>._(standaloneFinder, parents, children);
  }

  List<Element> get elements => finder.evaluate().toList();

  Element get element {
    final list = finder.evaluate().toList();
    final first = list.firstOrNull;
    if (first == null) {
      throw Exception('Could not find $this in widget tree');
    }
    return first;
  }

  WidgetSelector<T> existsOnce() {
    final parents = this.parents;
    final elements = this.elements;

    final errorBuilder = StringBuffer();

    // early exit when finder finds nothing
    if (elements.isEmpty) {
      if (parents.isEmpty) {
        errorBuilder.writeln('Could not find $this in widget tree');
        _dumpWidgetTree(errorBuilder);
        errorBuilder.writeln('Could not find $this in widget tree');
        fail(errorBuilder.toString());
      } else {
        int i = 0;
        for (final parent in parents) {
          i++;
          final possibleParents = parent.finder.evaluate();
          errorBuilder.writeln(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
          errorBuilder.writeln(
            'There are ${possibleParents.length} possible parents for '
            '$this matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
            'The widget trees starting at #$i ${parent.finder.description} are:',
          );
          int index = 0;
          for (final possibleParent in possibleParents) {
            errorBuilder.writeln("Possible parent $index:");
            errorBuilder.writeln(possibleParent.toStringDeep());
            index++;
          }
        }
        errorBuilder.writeln(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
        fail(errorBuilder.toString());
      }
    }

    Iterable<Element> matches = elements;
    if (parents.isNotEmpty) {
      // check if elements matches parents
      matches = elements.where((candidate) {
        return parents.every((WidgetSelector parent) {
          final elementParents = candidate.parents;
          final found = parent.finder.apply(elementParents).toList();
          return found.isNotEmpty;
        });
      });

      if (matches.isEmpty) {
        int i = 0;
        for (final parent in parents) {
          i++;
          final possibleParents = parent.finder.evaluate();
          errorBuilder.writeln(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
          errorBuilder.writeln(
            'There are ${possibleParents.length} possible parents for '
            '$this matching #$i ${parent.toStringBreadcrumb()}. But non matched. '
            'The widget trees starting at #$i ${parent.finder.description} are:',
          );
          int index = 0;
          for (final possibleParent in possibleParents) {
            errorBuilder.writeln("Possible parent $index:");
            errorBuilder.writeln(possibleParent.toStringDeep());
            index++;
          }
        }

        errorBuilder.writeln(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
        fail(errorBuilder.toString());
      }
    }

    if (matches.length > 1) {
      if (parents.isEmpty) {
        errorBuilder.writeln(
          'Found ${matches.length} elements matching $this in widget tree, '
          'expected only one',
        );
        _dumpWidgetTree(errorBuilder);

        errorBuilder.writeln(
          'Found ${matches.length} elements matching $this in widget tree, '
          'expected only one',
        );
        fail(errorBuilder.toString());
      } else {
        errorBuilder.writeln(
          'Found ${matches.length} elements matching $this as child of ${parents.toStringBreadcrumb()}, '
          'exepcting only one',
        );
        int index = 0;
        for (final candidate in matches) {
          errorBuilder.writeln("Possible candidate $index:");
          errorBuilder.writeln(candidate.toStringDeep());
          index++;
        }

        errorBuilder.writeln(
          'Found more than one $this as child of ${parents.toStringBreadcrumb()}',
        );
        fail(errorBuilder.toString());
      }
    }

    // all fine, found 1 element
    assert(matches.length == 1);
    return WidgetSelector<T>._(standaloneFinder, parents, children);
  }

  WidgetSelector existsAtLeastOnce() {
    final Iterable<Element> elements = finder.evaluate();

    final match = elements.firstWhereOrNull((element) {
      if (parents.isEmpty) return true;
      return parents.any((WidgetSelector parent) {
        return parent.finder.apply(element.parents).isNotEmpty;
      });
    });

    final errorBuilder = StringBuffer();
    if (match == null) {
      if (parents.isEmpty) {
        errorBuilder.writeln('Could not find $this in widget tree');
        _dumpWidgetTree(errorBuilder);
        errorBuilder.writeln('Could not find $this in widget tree');
        fail(errorBuilder.toString());
      } else {
        errorBuilder.writeln(
          'Could not find $this as child of ${parents.toStringBreadcrumb()}',
        );
        int i = 0;
        for (final parent in parents) {
          i++;
          errorBuilder.writeln('Children of #$i $parent:');
          errorBuilder.writeln(parent.finder.evaluate().first.toStringDeep());
          errorBuilder.writeln(
            'Could not find $this as child of #$i ${parent.toStringBreadcrumb()}',
          );
          fail(errorBuilder.toString());
        }
      }
    }

    // all fine, found at least 1 element
    assert(elements.isNotEmpty);
    return this;
  }

  WidgetSelector doesNotExist() {
    expect(finder, findsNothing);
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
