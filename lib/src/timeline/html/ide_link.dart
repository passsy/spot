import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

/// A link that opens a source location in the IDE running the test.
class IdeLink {
  /// Creates a link for [name]'s URL scheme.
  const IdeLink({required this.url, required this.name});

  /// The URL, in the scheme the IDE registered a handler for.
  final String url;

  /// The IDE's name, shown on the button that opens [url].
  final String name;

  @override
  String toString() {
    return 'IdeLink{$name, $url}';
  }
}

/// Builds a link that opens [initiator] in the IDE that runs this test.
///
/// Returns `null` when [environment] shows no supported IDE, or when
/// [initiator] has no source location to point at. A test runs in one IDE, so
/// at most one link is built; VS Code is checked first because it identifies
/// itself precisely, while IntelliJ is only recognizable by its fingerprints in
/// the environment.
///
/// [workingDirectory] is where the search for the enclosing project starts,
/// which IntelliJ needs and VS Code does not.
IdeLink? ideLinkFor(
  Frame? initiator, {
  required Map<String, String> environment,
  required Directory workingDirectory,
}) {
  if (initiator == null) {
    return null;
  }

  if (_isVsCode(environment)) {
    return _vsCodeLink(initiator);
  }
  if (_isIntelliJ(environment)) {
    return _intelliJLink(initiator, workingDirectory: workingDirectory);
  }
  return null;
}

/// Whether this process was started by VS Code.
///
/// `TERM_PROGRAM` covers the integrated terminal, the `VSCODE_` variables cover
/// the debugger and the test runner, which do not go through a terminal.
bool _isVsCode(Map<String, String> environment) {
  if (environment['TERM_PROGRAM']?.toLowerCase() == 'vscode') {
    return true;
  }
  return environment.keys.any((key) => key.startsWith('VSCODE_'));
}

/// Whether this process was started by IntelliJ or another JetBrains IDE.
///
/// They announce themselves only by leaving their install path in variables
/// like `PATH` and `TERMINAL_EMULATOR`, so this looks at the values.
bool _isIntelliJ(Map<String, String> environment) {
  return environment.values.any(
    (value) => value.toLowerCase().contains('intellij'),
  );
}

/// `vscode://file/<absolute path>:<line>:<column>`, the scheme VS Code
/// registers on install.
IdeLink? _vsCodeLink(Frame initiator) {
  final path = _absolutePath(initiator.uri);
  if (path == null) {
    return null;
  }

  final line = initiator.line ?? 1;
  final column = initiator.column ?? 1;
  return IdeLink(url: 'vscode://file/$path:$line:$column', name: 'VS Code');
}

/// `jetbrains://idea/navigate/reference?project=<name>&path=<path>`, which
/// resolves the path against the open project rather than the file system.
///
/// The line is zero-based here, unlike [_vsCodeLink].
IdeLink? _intelliJLink(Frame initiator, {required Directory workingDirectory}) {
  final projectName = _projectName(workingDirectory);
  if (projectName == null) {
    return null;
  }

  final line = initiator.line ?? 1;
  final zeroBasedLine = line >= 1 ? line - 1 : 0;
  final column = initiator.column ?? 0;
  final location = '${initiator.uri}:$zeroBasedLine:$column';

  // Everything after the project directory is the path IntelliJ expects.
  if (!location.contains(projectName)) {
    return null;
  }
  final path = location.split(projectName).last.trim();
  final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
  if (normalizedPath.isEmpty) {
    return null;
  }

  return IdeLink(
    url:
        'jetbrains://idea/navigate/reference?project=$projectName&path=$normalizedPath',
    name: 'IDEA',
  );
}

/// The name of the closest directory at or above [start] that holds a `.idea`,
/// which is the name IntelliJ knows the open project by.
String? _projectName(Directory start) {
  Directory? dir = start;
  while (dir != null) {
    if (Directory('${dir.path}/.idea').existsSync()) {
      return dir.path.split(Platform.pathSeparator).lastOrNull;
    }
    final parent = dir.parent;
    if (dir.path == parent.path) {
      return null;
    }
    dir = parent;
  }
  return null;
}

String? _absolutePath(Uri uri) {
  if (uri.scheme == 'file') {
    return File.fromUri(uri).absolute.path;
  }
  if (uri.scheme.isEmpty) {
    return File(uri.toFilePath()).absolute.path;
  }
  return null;
}

extension on List<String> {
  String? get lastOrNull => isEmpty ? null : last;
}
