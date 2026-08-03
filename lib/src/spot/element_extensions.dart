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

  /// Returns only onstage children of [Element], only direct children
  ///
  /// Children of [Offstage] or [Overlay] are eventually not returned,
  /// thus marking them as offstage
  Iterable<Element> get onstageChildren sync* {
    final List<Element> found = [];
    debugVisitOnstageChildren(found.add);
    yield* found;
  }
}

/// Caches the [WidgetLocation] of a [Widget], including a `null` result.
///
/// Keyed by [Widget], not by [Element], because an [Element] survives a
/// rebuild that replaces its widget with one created at a different location,
/// while a [Widget] instance always originates from a single constructor call.
class _CachedWidgetLocation {
  _CachedWidgetLocation(this.location);

  final WidgetLocation? location;
}

final Expando<_CachedWidgetLocation> _widgetLocationCache =
    Expando<_CachedWidgetLocation>('debugWidgetLocation');

/// Grants access to the location of a Widget via [WidgetInspectorService].
extension WidgetLocationExt on Element {
  /// Returns where the widget was created in code.
  ///
  /// The result is cached per [Widget]. Resolving a location serializes a
  /// diagnostics node to JSON, and hit test diagnostics ask for the location
  /// of the same handful of widgets thousands of times.
  WidgetLocation? get debugWidgetLocation {
    final widget = this.widget;
    final cached = _widgetLocationCache[widget];
    if (cached != null) {
      return cached.location;
    }

    final location = _resolveDebugWidgetLocation();
    _widgetLocationCache[widget] = _CachedWidgetLocation(location);
    return location;
  }

  WidgetLocation? _resolveDebugWidgetLocation() {
    try {
      final delegate = InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
      );
      final json = toDiagnosticsNode().toJsonMap(delegate);
      final creationLocation =
          json['creationLocation'] as Map<String, Object?>?;
      final file = creationLocation!['file'] as String?;
      final line = creationLocation['line'] as int?;
      final column = creationLocation['column'] as int?;
      final location = '$file:$line:$column';
      final createdByLocalProject = json['createdByLocalProject'] as bool?;

      return WidgetLocation(
        file: WidgetLocationFile(location),
        createdByLocalProject: createdByLocalProject,
      );
    } catch (_) {
      return null;
    }
  }
}

/// A source path reported by Flutter's widget inspector.
class WidgetLocationFile {
  /// Creates a source path reference.
  WidgetLocationFile(this.path);

  /// The source path, including line and column when Flutter reports them.
  final String path;

  /// The final path segment.
  String get name {
    return path.split('/').last;
  }
}

/// The location where a Widget constructor was called.
class WidgetLocation {
  /// Creates a new [WidgetLocation].
  WidgetLocation({
    required this.file,
    required this.createdByLocalProject,
  });

  /// The pointer to the file.
  final WidgetLocationFile file;

  /// Whether [WidgetInspectorService] reports this location as local project code.
  final bool? createdByLocalProject;

  /// Whether this location is useful for user-facing diagnostics.
  bool get isUserCode {
    if (file.path.contains('packages/flutter/')) {
      return false;
    }
    final createdByLocalProject = this.createdByLocalProject;
    if (createdByLocalProject != null) {
      return createdByLocalProject;
    }
    return true;
  }

  @override
  String toString() {
    return 'WidgetLocation{userCode: $isUserCode, ${file.name}';
  }
}
