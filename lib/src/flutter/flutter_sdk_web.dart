/// Returns the path of the Flutter SDK root directory based on the current
/// flutter executable running the tests.
///
/// There is no Flutter SDK on disk when the tests run in a browser.
String flutterSdkRootPath() {
  throw UnsupportedError('The Flutter SDK is not accessible on the web');
}

/// The Flutter executable in the Flutter SDK
///
/// There is no Flutter SDK on disk when the tests run in a browser.
String get flutterExe {
  throw UnsupportedError('The Flutter SDK is not accessible on the web');
}
