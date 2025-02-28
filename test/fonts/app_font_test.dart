import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/flutter_sdk.dart';

import 'font_test_project.dart';

void main() {
  test('When defined in pubspec a third-party font is loaded', skip: kIsWeb,
      () async {
    final testProject = FontTestProject('test/fonts/templates/app_font');
    await testProject.create();
    debugPrint('Run pub get');
    await Process.run(
      flutterExe,
      ['pub', 'get'],
      workingDirectory: testProject.workingDir.path,
    );
    debugPrint('Run tests');
    final test = await Process.start(
      flutterExe,
      ['test'],
      workingDirectory: testProject.workingDir.path,
    );
    test.stdout.transform(utf8.decoder).listen((event) {
      debugPrint(event);
    });
    test.stderr.transform(utf8.decoder).listen((event) {
      debugPrint(event);
    });
    final exitCode = await test.exitCode;
    if (exitCode != 0) {
      final failuresDir =
          Directory('${testProject.workingDir.path}/test/failures');
      if (failuresDir.existsSync()) {
        final testFailureDirectory = Directory('test/fonts/app_font_test/');
        if (testFailureDirectory.existsSync()) {
          testFailureDirectory.deleteSync(recursive: true);
        } else {
          testFailureDirectory.createSync(recursive: true);
        }
        await failuresDir.copyRecursively(testFailureDirectory);
      }
    }
    expect(exitCode, 0);
  });
}
