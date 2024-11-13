import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_test/flutter_test.dart';

String get flutterPath => '${Platform.environment['FLUTTER_ROOT']}/bin/flutter';

class FontTestProject {
  final Directory _templateDir;

  Directory get workingDir => _workingDir;
  late Directory _workingDir;

  FontTestProject(String path) : _templateDir = Directory(path);

  Future<void> create({Directory? dir}) async {
    final temp = dir ?? Directory.systemTemp.createTempSync();
    _workingDir = temp;
    addTearDown(() {
      // temp.deleteSync(recursive: true);
    });
    await _templateDir.copyRecursively(temp);
    for (final file in temp.listSync(recursive: true)) {
      if (file is File) {
        if (file.name == 'pubspec_template.yaml') {
          // rename to correct pubspec.yaml. (Not using it in template because other tools might use it)
          final pubspec = file.copySync(
            file.path.replaceFirst('pubspec_template.yaml', 'pubspec.yaml'),
          );

          // overwrite the spot dependencies path
          final repoRoot = File(Platform.script.path).parent.path;
          final content = pubspec
              .readAsStringSync()
              .replaceAll('../../../../../.', repoRoot);
          pubspec.writeAsStringSync(content);
        }
        if (file.name == 'test.dart') {
          // rename to correct _test.dart file. (Not using it in template because flutter test would execute them)
          file.copySync(file.path.replaceFirst('test.dart', 'test_test.dart'));
        }
      }
    }
  }
}
