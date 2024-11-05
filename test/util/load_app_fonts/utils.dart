import 'dart:io';

String get flutterPath => '${Platform.environment['FLUTTER_ROOT']}/bin/flutter';

extension CopyExtension on Directory {
  void copyTo(String path) {
    final targetDir = Directory(path);
    targetDir.createSync(recursive: true);
    listSync().forEach((element) {
      if (element is File) {
        // if the file is test.dart, rename to _dart.test
        if (element.path.endsWith('test.dart')) {
          element.copySync(
            '${targetDir.path}/${element.path.split('/').last.replaceAll('test.dart', '_test.dart')}',
          );
        } else if (element.path.endsWith('pubspec_template.yaml')) {
          final stopAbsolutePath = Platform.script.path
              .split('/')
              .sublist(0, Platform.script.path.split('/').length - 1)
              .join('/');
          final test = element
              .readAsStringSync()
              .replaceAll('../../../../../.', stopAbsolutePath);
          File('${targetDir.path}/${element.path.split('/').last.replaceAll('pubspec_template.yaml', 'pubspec.yaml')}')
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
