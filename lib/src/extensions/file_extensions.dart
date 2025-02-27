import 'package:universal_io/io.dart';

///
extension UniversalFileSystemEntityExtensions on FileSystemEntity {
  /// Gets the part of [path] after the last separator.
  /// dart
  /// File('path/to/foo.dart').name; // -> 'foo.dart'
  /// Directory('path/to').name;          // -> 'to'
  ///
  ///
  /// Trailing separators are ignored.
  /// dart
  /// Directory('path/to/').name; // -> 'to'
  /// "
  String get name {
    // Remove any trailing separators.
    String normalizedPath = path;
    while (normalizedPath.endsWith('/') || normalizedPath.endsWith('\\')) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }

    // Find the last separator in the normalized path.
    final lastForward = normalizedPath.lastIndexOf('/');
    final lastBack = normalizedPath.lastIndexOf('\\');
    final lastSeparator = lastForward > lastBack ? lastForward : lastBack;

    // Return the part after the last separator.
    return lastSeparator == -1
        ? normalizedPath
        : normalizedPath.substring(lastSeparator + 1);
  }
}

///
extension DirectoryDirectoryExtension on Directory {
  /// Returns a directory within the [Directory]
  ///
  /// ```dart
  /// Directory androidDir = Directory('flutter-app/android');
  /// Directory mainSrc = androidDir.directory("app/src/main");
  /// ```
  Directory directory(String dirPath) {
    final sb = StringBuffer(absolute.path);
    final path = sb.toString();
    if (!path.endsWith(Platform.pathSeparator) &&
        !dirPath.startsWith(Platform.pathSeparator)) {
      // no separator between dir and filePath
      sb.write(Platform.pathSeparator);
    }
    if (path.startsWith(Platform.pathSeparator) &&
        dirPath.startsWith(Platform.pathSeparator)) {
      // joining would cause a double //
      final path = dirPath.replaceFirst(Platform.pathSeparator, '');
      sb.write(path);
    } else {
      sb.write(dirPath);
    }
    return Directory(sb.toString());
  }

  /// Returns a [File] within the [Directory]
  File file(String filePath) {
    final sb = StringBuffer(absolute.path);
    final path = sb.toString();
    if (!path.endsWith(Platform.pathSeparator) &&
        !filePath.startsWith(Platform.pathSeparator)) {
      // no separator between dir and filePath
      sb.write(Platform.pathSeparator);
    }
    if (path.startsWith(Platform.pathSeparator) &&
        filePath.startsWith(Platform.pathSeparator)) {
      // joining would cause a double //
      final path = filePath.replaceFirst(Platform.pathSeparator, '');
      sb.write(path);
    } else {
      sb.write(filePath);
    }
    return File(sb.toString());
  }
}
