import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/spot/element_extensions.dart';

/// caching the tree for the current frame
WidgetTreeSnapshot? _cachedTree;

/// Creates a snapshot of the currently pumped widget via [WidgetTester.pumpWidget].
///
/// This snapshot is only made once per frame and cached for further use.
WidgetTreeSnapshot currentWidgetTreeSnapshot() {
  if (_cachedTree != null && _cachedTree!.isFromThisFrame) {
    return _cachedTree!;
  }

  return _cachedTree = createWidgetTreeSnapshot();
}

/// Creates a new snapshot of the widget tree. Might be useful for testing and
/// can be called repeatedly within the same frame
@visibleForTesting
WidgetTreeSnapshot createWidgetTreeSnapshot() {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement!;

  WidgetTreeNode build(
    Element element, {
    WidgetTreeNode? parent,
    bool isOffstage = false,
  }) {
    // Get all onstage children of the parent
    final allOnstageChildren = parent?.element.onstageChildren.toList();

    final bool isOffstageElement;
    if (allOnstageChildren == null) {
      // If there is no parent use isOffstage which is false by default
      isOffstageElement = isOffstage;
    } else {
      // Check if the current element is offstage or use the parent's state
      isOffstageElement = !allOnstageChildren.contains(element) || isOffstage;
    }

    final snapshot = WidgetTreeNode(
      element: element,
      parent: parent,
      isOffstage: isOffstageElement,
    );

    for (final child in element.children) {
      snapshot.addChild(build(
        child,
        parent: snapshot,
        isOffstage: isOffstageElement,
      ));
    }
    return snapshot;
  }

  final origin = build(rootElement);

  return WidgetTreeSnapshot(
    origin: origin,
    timestamp: DateTime.now(),
  );
}

/// A node in [WidgetTreeSnapshot] holding a single [element] and knows about
/// parent and children.
class WidgetTreeNode {
  /// The actual element in the element tree holding the widget of type `W`.
  final Element element;

  List<WidgetTreeNode> _children = const [];

  /// Gets the list of child nodes of this widget tree node.
  ///
  /// It provides access to the children of this node, allowing traversal of
  /// the widget tree.
  List<WidgetTreeNode> get children => _children;

  /// Adds a child node to this widget tree node.
  ///
  /// This method updates the list of children by adding [child]. The list of
  /// children remains unmodifiable to external modifications.
  void addChild(WidgetTreeNode child) {
    _children = List.unmodifiable([..._children, child]);
  }

  /// The parent widget tree node of this node.
  ///
  /// This is a nullable reference to the parent node. It's `null` for the root
  /// node of the tree.
  final WidgetTreeNode? parent;

  final bool isOffstage;

  /// Creates an [Element] in the element tree.
  ///
  /// Do not forget to call [addChild] manually after creation!
  WidgetTreeNode({
    required this.element,
    required this.parent,
    this.isOffstage = false,
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
  /// Represents the precise point in time at which the state of
  /// the widget tree was recorded.
  final DateTime timestamp;

  bool _isNextFrame = false;

  /// Creates a snapshot of the widget tree at the given [timestamp].
  ///
  /// The snapshot is initialized with the `origin` of the current widget scope
  /// and the specified [timestamp]. It sets up a post-frame callback to mark
  /// the snapshot as outdated when the next frame is pumped.
  ///
  /// The snapshot captures the state of the widget tree at the exact moment of
  /// its creation, allowing for analysis of the tree state at that specific
  /// point in time.
  ///
  /// - [origin]: The origin widget of this snapshot.
  /// - [timestamp]: The time at which the snapshot was taken.
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

/// A snapshot representing a specific subtree within a [WidgetTreeSnapshot].
///
/// This class provides a focused view of a subtree starting from the [origin]
/// node. It is used to analyze and interact with a specific part of the widget
/// tree, isolated from the rest. Each instance of this class captures the state
/// and structure of the subtree at a specific point in time, facilitating
/// targeted analysis and debugging within that scope.
///
/// The snapshot includes various utility methods to traverse and inspect the
/// subtree, such as obtaining all elements, widgets, and nodes in depth-first
/// order. It also manages the lifecycle of the snapshot, ensuring its validity
/// only within the current frame.
class ScopedWidgetTreeSnapshot {
  /// This constructor initializes a snapshot of a subtree, starting at the
  /// provided [origin]. It captures the state of the subtree for further
  /// analysis or operations.
  ScopedWidgetTreeSnapshot({
    required this.origin,
    required this.parentScope,
  });

  /// The root node of the subtree to be captured in this snapshot.
  final WidgetTreeNode origin;

  /// The parent scope from which this subtree snapshot is derived.
  final ScopedWidgetTreeSnapshot? parentScope;

  /// Returns `true` if the snapshot represents the state of the widgets
  /// as of the current frame. If a new frame has been pumped,
  /// it returns `false`, indicating that the snapshot is outdated.
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

  /// Returns a detailed string representation of the subtree starting at the
  /// origin.
  ///
  /// This method provides a depth-first traversal representation of the
  /// subtree, showing detailed information about each widget in the hierarchy.
  /// It is particularly useful for debugging and visualizing the structure of
  /// the subtree.
  ///
  /// #### Example usage:
  /// ```dart
  /// final WidgetTreeSnapshot snapshot = currentWidgetTreeSnapshot();
  /// final ScopedWidgetTreeSnapshot scopedSnapshot = snapshot.scope(snapshot.origin);
  /// final String deepString = scopedSnapshot.toStringDeep();
  /// ```
  String toStringDeep() {
    return origin.element.toStringDeep();
  }
}
