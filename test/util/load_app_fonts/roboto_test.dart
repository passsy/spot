import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  test('roboto is loaded per default', () async {
    int exitCode = -1;
    try {
      // Copy virtual/robot to test folder
      final testProjectDir = Directory.systemTemp.createTempSync('robot_test').path;
      Directory('${Directory.current.path}/test/util/load_app_fonts/virtual/roboto').copyTo(testProjectDir);

      // Run pub get
      await Process.run(flutterPath, ['pub', 'get'], workingDirectory: testProjectDir);

      // Run tests
      final test = await Process.start(flutterPath, ['test'], workingDirectory: testProjectDir);
      test.stdout.transform(utf8.decoder).listen((event) {
        print(event);
      });
      test.stderr.transform(utf8.decoder).listen((event) {
        print(event);
      });
      exitCode = await test.exitCode;
    } catch (e) {
      print(e);
    } finally {
      expect(exitCode, equals(0));

      // Cleanup: Remove the temporary directory after test
      // tempDir.deleteSync(recursive: true);
    }
  });
}
