import 'dart:io';

import 'package:dartx/dartx_io.dart';

/// Returns the path of the Flutter SDK root directory based on the current
/// flutter executable running the tests.
String flutterSdkRootPath() {
  final flutterTesterExe = Platform.executable;
  final String flutterRoot;
  if (Platform.isWindows) {
    flutterRoot = flutterTesterExe.split(r'\bin\cache\')[0];
  } else {
    flutterRoot = flutterTesterExe.split('/bin/cache/')[0];
  }
  return Directory(flutterRoot).absolute.path;
}

/// The Flutter executable in the Flutter SDK
String get flutterExe {
  final exe = Platform.isWindows ? '.bat' : '';
  return Directory(flutterSdkRootPath()).file('bin/flutter$exe').absolute.path;
}
