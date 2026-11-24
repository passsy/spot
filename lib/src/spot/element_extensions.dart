import 'package:flutter/widgets.dart';

/// Extensions that help traversing the Element tree
extension ElementExtensions on Element {
  /// Returns the parent of [Element] or `null` if it is the root
  Element? get parent {
    Element? parent;
    visitAncestorElements((element) {
      parent = element;
      return false;
    });
    return parent;
  }

  /// Returns all parents of [Element] in order from the closest to the root
  Iterable<Element> get parents sync* {
    Element? element = this;
    while (element != null) {
      yield element;
      element = element.parent;
    }
  }

  /// Returns all children of [Element], only direct children
  Iterable<Element> get children sync* {
    final List<Element> found = [];
    visitChildren(found.add);
    yield* found;
  }

  /// Returns all children of [Element] of any depth
  Iterable<Element> get allChildren sync* {
    final List<Element> found = [];
    void visit(Element element) {
      found.add(element);
      element.visitChildren(visit);
    }

    visit(this);
    yield* found;
  }
}
