import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartx/dartx_io.dart';

final _spotTempDir = Directory.systemTemp.directory('spot');

/// Writes bytes to a temp file
///
/// Returns an absolute path to the screenshot file
String writePngToDisk(String screenshotFileName, Uint8List bytes) {
  if (!_spotTempDir.existsSync()) {
    _spotTempDir.createSync();
  }
  final file = _spotTempDir.file('$screenshotFileName.png');
  if (file.existsSync()) {
    file.deleteSync();
  }
  file.writeAsBytesSync(bytes);
  return file.absolute.path;
}
