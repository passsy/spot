import 'dart:io';

String get flutterPath => '${Platform.environment['FLUTTER_ROOT']}/bin/flutter';

extension CopyExtension on Directory {
  void copyTo(String path) {
    final targetDir = Directory(path);
    targetDir.createSync(recursive: true);
    listSync().forEach((element) {
      if (element is File) {
        // if the file is _test.dart, rename to _dart.test
        if (element.path.endsWith('_test.dart')) {
          element.copySync(
            '${targetDir.path}/${element.path.split('/').last.replaceAll('_test.dart', '_test.dart')}',
          );
        } else if (element.path.endsWith('pubspec.yaml')) {
          final stopAbsolutePath = Platform.script.path
              .split('/')
              .sublist(0, Platform.script.path.split('/').length - 1)
              .join('/');
          final test = element
              .readAsStringSync()
              .replaceAll('../../../../../.', stopAbsolutePath);
          File('${targetDir.path}/${element.path.split('/').last.replaceAll('pubspec.yaml', 'pubspec.yaml')}')
              .writeAsStringSync(test);
        } else {
          element.copySync('${targetDir.path}/${element.path.split('/').last}');
        }
      } else if (element is Directory) {
        element.copyTo('${targetDir.path}/${element.path.split('/').last}');
      }
    });
  }
}
