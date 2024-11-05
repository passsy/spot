import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  test('roboto is loaded per default', () async {
    int exitCode = -1;
    late Directory tempDir;
    try {
      tempDir = Directory.systemTemp.createTempSync('robot_test');
      // Copy virtual/robot to test folder
      final testProjectDir = tempDir.path;
      Directory(
        '${Directory.current.path}/test/util/load_app_fonts/virtual/roboto',
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
