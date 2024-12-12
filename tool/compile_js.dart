// ignore_for_file: avoid_print

import 'dart:io';

/// Compiles the timeline web app to JavaScript.
void main() {
  final outputJsFile = File('build/timeline/script.js');
  if (outputJsFile.existsSync()) {
    outputJsFile.deleteSync();
  }

  final dartVersionResult = Process.runSync('dart', ['--version']);
  final dartVersion = dartVersionResult.stdout.toString();

  final result = Process.runSync('dart', [
    'compile',
    'js',
    'lib/src/timeline/html/web/client_app.dart',
    '-O2',
    '--output=${outputJsFile.path}',
    '--no-source-maps',
  ]);
  stderr.write(result.stderr);
  stdout.write(result.stdout);

  final outputJsContent = outputJsFile.readAsStringSync();

  final scriptDartContent = "// AUTO GENERATED FILE. DO NOT MODIFY.\n\n"
      "/// The script used in the HTML file that is generated for the timeline.\n"
      "/// Generate it with `dart run tool/compile_js.dart`\n"
      "/// Using $dartVersion\n"
      "\n"
      "// language=javascript\n"
      "const String timelineJS = r'''\n$outputJsContent\n''';\n";

  File('lib/src/timeline/html/sources/script.js.g.dart')
      .writeAsStringSync(scriptDartContent);
  outputJsFile.deleteSync();
  File('${outputJsFile.path}.deps').deleteSync();
  print('Generated ${outputJsFile.path}');
}
