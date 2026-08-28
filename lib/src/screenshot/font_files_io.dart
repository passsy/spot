import 'dart:io';
import 'dart:typed_data';

/// Reads [path] from disk, or returns null when there is no such file.
Uint8List? readFileBytesSync(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }
  return file.readAsBytesSync();
}

/// Returns the paths of all files directly in [dirPath] ending in one of
/// [extensions].
///
/// Returns an empty list when the directory does not exist.
List<String> listFilesWithExtension(String dirPath, List<String> extensions) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    return [];
  }
  return dir
      .listSync()
      .whereType<File>()
      .where((file) => extensions.any((ext) => file.path.endsWith(ext)))
      .map((file) => file.path)
      .toList();
}

/// Reads the `name:` field from the test target's pubspec.yaml.
///
/// `flutter test` creates a generated main.dart next to the package root, so
/// pubspec.yaml is expected next to [Platform.script]. Returns null when no
/// pubspec.yaml is found or it does not declare a name.
String? readPackageNameFromPubspec() {
  final pubspec = File.fromUri(Platform.script.resolve('pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return null;
  }
  final content = pubspec.readAsStringSync();
  final match = RegExp(
    '''^\\s*name\\s*:\\s*['"]?([a-zA-Z0-9_]+)['"]?''',
    multiLine: true,
  ).firstMatch(content);
  return match?.group(1);
}
