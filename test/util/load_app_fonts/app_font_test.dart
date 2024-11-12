import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  print('flutterPath:');
  test('When defined in pubspec a third-party font is loaded', () async {
    int exitCode = -1;
    late Directory tempDir;
    print('flutterPath: ');
    print('flutterPath: $flutterPath');
    try {
      print('this should work right?');
      // Copy virtual/montserrat to test folder
      tempDir = Directory.systemTemp.createTempSync('app_font_test');
      final testProjectDir = tempDir.path;
      print('testProjectDir: $testProjectDir');
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

      exitCode = await test.exitCode;
    } catch (e) {
      rethrow;
    } finally {
      expect(exitCode, 0);
      tempDir.deleteSync(recursive: true);
    }
  });
}
