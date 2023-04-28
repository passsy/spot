import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/element_extensions.dart';

/// Creates a snapshot of the currently pumped widget via [WidgetTester.pumpWidget].
WidgetTreeSnapshot snapshotWidgetTree() {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement!;

  WidgetTreeNode build(Element element, {WidgetTreeNode? parent}) {
    final snapshot = WidgetTreeNode(
      element: element,
      parent: parent,
    );

    for (final child in element.children) {
      snapshot.addChild(build(child, parent: snapshot));
    }
    return snapshot;
  }

  final origin = build(rootElement);

  // TODO add caching for the current frame
  return WidgetTreeSnapshot(
    origin: origin,
    timestamp: DateTime.now(),
  );
}

/// A node in [WidgetTreeSnapshot] holding a single [element] and knows about
/// parent and children.
class WidgetTreeNode {
  /// The actual element in the element tree holding the widget of type [W]
  final Element element;

  List<WidgetTreeNode> _children = const [];

  List<WidgetTreeNode> get children => _children;

  void addChild(WidgetTreeNode child) {
    _children = List.unmodifiable([..._children, child]);
  }

  final WidgetTreeNode? parent;

  WidgetTreeNode({
    required this.element,
    required this.parent,
  });

  @override
  String toString() {
    return 'snapshot: ${element.widget.toStringShallow()}';
  }
}

/// A complete snapshot of the widget tree at point [timestamp] to be used for
/// further analysis.
///
/// This tree is a tree of [WidgetTreeNode]s, which are wrappers around [Element]
/// with additional information about the widget.
class WidgetTreeSnapshot extends ScopedWidgetTreeSnapshot {
  final DateTime timestamp;

  bool _isNextFrame = false;

  WidgetTreeSnapshot({
    required super.origin,
    required this.timestamp,
  }) : super(parentScope: null) {
    // A snapshot is only valid until the next frame is pumped
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNextFrame = true;
    });
  }

  @override
  bool get isFromThisFrame {
    if (_isNextFrame) {
      // A new frame has been pumped
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'WidgetTreeSnapshot{timestamp: $timestamp, origin: $origin}';
  }
}

/// A subtree of [WidgetTreeSnapshot] that starts at [origin]
class ScopedWidgetTreeSnapshot {
  final WidgetTreeNode origin;
  final ScopedWidgetTreeSnapshot? parentScope;

  ScopedWidgetTreeSnapshot({
    required this.origin,
    required this.parentScope,
  });

  bool get isFromThisFrame => root.isFromThisFrame;

  void _ensureSnapshotIsFromThisFrame() {
    if (isFromThisFrame) return;
    throw StateError('WidgetTreeSnapshot is not valid anymore. '
        'It is only valid until the next frame is pumped.');
  }

  /// Returns all [WidgetTreeNode] in tree in depth-first order
  List<WidgetTreeNode> get allNodes {
    _ensureSnapshotIsFromThisFrame();
    final List<WidgetTreeNode> depthFirstElements = [];
    final List<WidgetTreeNode> stack = [];

    void fill(WidgetTreeNode snapshot) {
      final List<WidgetTreeNode> reversed = <WidgetTreeNode>[];
      for (final WidgetTreeNode child in snapshot.children) {
        reversed.add(child);
      }
      while (reversed.isNotEmpty) {
        stack.add(reversed.removeLast());
      }
    }

    fill(origin);
    while (stack.isNotEmpty) {
      final next = stack.removeLast();
      depthFirstElements.add(next);
      fill(next);
    }
    return depthFirstElements.toList();
  }

  /// Returns the Elements in depth-first order
  List<Element> get allElements {
    _ensureSnapshotIsFromThisFrame();
    return allNodes.map((it) => it.element).toList();
  }

  /// Returns the Widgets in depth-first order
  List<Widget> get allWidgets {
    _ensureSnapshotIsFromThisFrame();
    return allNodes.map((it) => it.element.widget).toList();
  }

  /// The root of the widget tree
  WidgetTreeSnapshot get root {
    if (parentScope == null) {
      return this as WidgetTreeSnapshot;
    }
    return parentScope!.root;
  }

  /// Creates a scoped snapshot of the subtree starting at [origin]
  ScopedWidgetTreeSnapshot scope(WidgetTreeNode origin) {
    _ensureSnapshotIsFromThisFrame();
    return ScopedWidgetTreeSnapshot(
      origin: origin,
      parentScope: this,
    );
  }

  /// Returns the scopes from closest to root
  List<ScopedWidgetTreeSnapshot> get scopes {
    _ensureSnapshotIsFromThisFrame();
    final List<ScopedWidgetTreeSnapshot> list = [];
    ScopedWidgetTreeSnapshot? next = parentScope;
    while (next != null) {
      list.add(next);
      next = next.parentScope;
    }
    return list;
  }

  @override
  String toString() {
    return 'ScopedWidgetTreeSnapshot{origin: ${origin.element.widget.runtimeType}}';
  }
}
