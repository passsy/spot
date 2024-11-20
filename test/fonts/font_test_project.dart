import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Directory _flutterSdkRoot() {
  final flutterTesterExe = Platform.executable;

  final components = p.split(flutterTesterExe);
  final path = p.posix.joinAll(components);
  final flutterRoot = path.split('/bin/cache/')[0];
  return Directory(flutterRoot);
}

String get flutterExe {
  final exe = Platform.isWindows ? '.bat' : '';
  return _flutterSdkRoot().file('bin/flutter$exe').absolute.path;
}

/// Loads a template from the `templates` directory and mounts it in a temporary folder
class FontTestProject {
  final Directory _templateDir;

  Directory get workingDir => _workingDir;
  late Directory _workingDir;

  FontTestProject(String path) : _templateDir = Directory(path);

  Future<void> create({Directory? dir}) async {
    final temp = dir ?? Directory.systemTemp.createTempSync();
    _workingDir = temp;
    addTearDown(() {
      temp.deleteSync(recursive: true);
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
          final repoRoot = File.fromUri(Platform.script).parent.path;
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
