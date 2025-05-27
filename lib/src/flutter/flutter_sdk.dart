import 'dart:io';

import 'package:spot/src/utils/file_extensions.dart';

/// Returns the Flutter SDK root directory based on the current flutter
/// executable running the tests.
Directory flutterSdkRoot() {
  final flutterTesterExe = Platform.executable;
  final String flutterRoot;
  if (Platform.isWindows) {
    flutterRoot = flutterTesterExe.split(r'\bin\cache\')[0];
  } else {
    flutterRoot = flutterTesterExe.split('/bin/cache/')[0];
  }
  return Directory(flutterRoot);
}

/// The Flutter executable in the Flutter SDK
String get flutterExe {
  final exe = Platform.isWindows ? '.bat' : '';
  return flutterSdkRoot().file('bin/flutter$exe').absolute.path;
}
