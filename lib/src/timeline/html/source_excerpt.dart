import 'dart:io';

import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:stack_trace/stack_trace.dart';

const _maximumLineLength = 500;

/// Files longer than this are cut off.
///
/// A test file is a few hundred lines. Anything past this is generated or
/// concatenated, and nobody reads it in a timeline report.
const _maximumLineCount = 5000;

/// Reads the whole source file a captured caller points into.
///
/// The report shows the caller in its surroundings, and any fixed window of
/// lines cuts off the interesting part of some method. Files are stored once
/// per path however many events point at them, see [readTimelineSourceFiles].
TimelineSourceFile? readTimelineSourceFile(Frame? caller) {
  if (caller == null || caller.line == null || caller.line! < 1) {
    return null;
  }

  final file = _sourceFile(caller.uri);
  if (file == null || !file.existsSync()) {
    return null;
  }

  try {
    final lines = file.readAsLinesSync();
    if (lines.isEmpty || caller.line! > lines.length) {
      return null;
    }
    return TimelineSourceFile(
      path: _displayPath(file),
      lines: [
        for (final line in lines.take(_maximumLineCount)) _boundedLine(line),
      ],
      truncated: lines.length > _maximumLineCount,
    );
  } on FileSystemException {
    return null;
  }
}

/// Reads every distinct file [callers] point into, keyed by display path.
Map<String, TimelineSourceFile> readTimelineSourceFiles(
  Iterable<Frame?> callers,
) {
  final filesByPath = <String, TimelineSourceFile>{};
  final visitedUris = <Uri>{};
  for (final caller in callers) {
    if (caller == null || !visitedUris.add(caller.uri)) {
      continue;
    }
    final file = readTimelineSourceFile(caller);
    if (file != null) {
      filesByPath[file.path] = file;
    }
  }
  return filesByPath;
}

/// The path [caller] is stored under, matching [TimelineSourceFile.path].
///
/// `null` when the file is not readable from here, for example a `package:`
/// URI pointing into a dependency.
String? sourceFilePathOf(Frame? caller) {
  final file = caller == null ? null : _sourceFile(caller.uri);
  if (file == null || !file.existsSync()) {
    return null;
  }
  return _displayPath(file);
}

File? _sourceFile(Uri uri) {
  if (uri.scheme == 'file') {
    return File.fromUri(uri);
  }
  if (uri.scheme.isEmpty) {
    return File(uri.toFilePath());
  }
  return null;
}

String _displayPath(File file) {
  final absolutePath = file.absolute.path;
  final projectPath = Directory.current.absolute.path;
  final projectPrefix = projectPath.endsWith(Platform.pathSeparator)
      ? projectPath
      : '$projectPath${Platform.pathSeparator}';
  if (absolutePath.startsWith(projectPrefix)) {
    return absolutePath.substring(projectPrefix.length);
  }
  return absolutePath;
}

String _boundedLine(String line) {
  if (line.length <= _maximumLineLength) {
    return line;
  }
  return '${line.substring(0, _maximumLineLength)}…';
}
