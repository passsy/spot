import 'dart:convert';
import 'dart:io';

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
      flutterPath,
      ['pub', 'get'],
      workingDirectory: dependencyProject.workingDir.path,
    );
    debugPrint('Run tests');
    final test = await Process.start(
      flutterPath,
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
    expect(exitCode, 0);
  });
}
