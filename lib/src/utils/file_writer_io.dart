import 'dart:io';

/// Writes [content] to [path], creating parent directories as needed.
///
/// Deletes the file at [path] when [content] is null.
void writeStringToFile(String path, String? content) {
  final file = File(path);
  if (content == null) {
    if (file.existsSync()) {
      file.deleteSync();
    }
    return;
  }
  file
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
}
