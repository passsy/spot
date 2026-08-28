import 'dart:typed_data';

/// Reads [path] from disk, or returns null when there is no such file.
///
/// A browser has no file system to read fonts from, so this always returns
/// null and the caller falls back to the asset bundle.
Uint8List? readFileBytesSync(String path) => null;

/// Returns the paths of all files directly in [dirPath] ending in one of
/// [extensions].
///
/// A browser has no file system to enumerate, so this is always empty.
List<String> listFilesWithExtension(String dirPath, List<String> extensions) =>
    const [];

/// Reads the `name:` field from the test target's pubspec.yaml.
///
/// There is no pubspec.yaml next to a browser test, so this is always null.
String? readPackageNameFromPubspec() => null;
