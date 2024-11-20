import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/flutter_sdk.dart';

import 'font_test_project.dart';

void main() {
  test('When defined in pubspec a third-party font is loaded', () async {
    final dependencyFontProject =
        FontTestProject('test/fonts/templates/dependency_font');
    await dependencyFontProject.create();

    final appFontProject = FontTestProject('test/fonts/templates/app_font');
    await appFontProject.create(
      dir: Directory(
        '${dependencyFontProject.workingDir.path}/packages/app_font',
      ),
    );

    debugPrint('Run pub get');
    await Process.run(
      flutterExe,
      ['pub', 'get'],
      workingDirectory: dependencyFontProject.workingDir.path,
    );
    debugPrint('Run tests');
    final test = await Process.start(
      flutterExe,
      ['test'],
      workingDirectory: dependencyFontProject.workingDir.path,
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
          Directory('${dependencyFontProject.workingDir.path}/test/failures');
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
