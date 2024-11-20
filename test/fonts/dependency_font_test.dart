import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'font_test_project.dart';

void main() {
  test('When defined in pubspec a third-party font is loaded', () async {
    final dependencyProject =
        FontTestProject('test/fonts/templates/dependency_font');
    await dependencyProject.create();

    final testProject = FontTestProject('test/fonts/templates/app_font');
    await testProject.create(
      dir: Directory(
        '${dependencyProject.workingDir.path}/packages/app_font',
      ),
    );

    debugPrint('Run pub get');
    await Process.run(
      flutterExe,
      ['pub', 'get'],
      workingDirectory: dependencyProject.workingDir.path,
    );
    debugPrint('Run tests');
    final test = await Process.start(
      flutterExe,
      ['test'],
      workingDirectory: dependencyProject.workingDir.path,
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
          Directory('${dependencyProject.workingDir.path}/test/failures');
      if (failuresDir.existsSync()) {
        final testFailureDirectory =
            Directory('test/fonts/dependency_font_test/');
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
