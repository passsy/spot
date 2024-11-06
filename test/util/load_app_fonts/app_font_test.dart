import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  test('When defined in pubspec a third-party font is loaded', () async {
    int exitCode = -1;
    late Directory tempDir;
    try {
      // Copy virtual/montserrat to test folder
      tempDir = Directory.systemTemp.createTempSync('app_font_test');
      final testProjectDir = tempDir.path;

      Directory(
        '${Directory.current.path}/test/util/load_app_fonts/virtual/app_font',
      ).copyTo(testProjectDir);

      // Run pub get
      await Process.run(
        flutterPath,
        ['pub', 'get'],
        workingDirectory: testProjectDir,
      );

      // Run tests
      final test = await Process.start(
        flutterPath,
        ['test'],
        workingDirectory: testProjectDir,
      );

      // Run tests
      test.stdout.transform(utf8.decoder).listen((event) {
        debugPrint(event);
      });
      test.stderr.transform(utf8.decoder).listen((event) {
        throw Exception(event);
      });
      exitCode = await test.exitCode;
    } catch (e) {
      rethrow;
    } finally {
      expect(exitCode, equals(0));
      tempDir.deleteSync(recursive: true);
    }
  });
}
