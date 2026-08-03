import 'package:flutter/widgets.dart';

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
    return 'WidgetLocation{userCode: $isUserCode, ${file.name}}';
  }
}

/// A source path reported by Flutter's widget inspector.
class WidgetLocationFile {
  /// Creates a source path reference.
  WidgetLocationFile(this.path);

  /// The source path, including line and column when Flutter reports them.
  ///
  /// For example `file:///src/my_widget.dart:42:7`, not a path a file API can
  /// open.
  final String path;

  /// The last segment of [path], including line and column.
  ///
  /// For example `my_widget.dart:42:7`.
  String get name {
    return path.split('/').last;
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
