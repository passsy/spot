import 'dart:core' as core show print;
import 'dart:core';
import 'dart:typed_data';

/// Writes bytes to a temp file
///
/// Returns an absolute path to the screenshot file
String createSpotTempFile(String name, Uint8List bytes) {
  throw 'Not supported on web';
}

/// Returns a File for dart:io
dynamic fileFromPath(String path) {
  throw 'Not supported on web';
}
