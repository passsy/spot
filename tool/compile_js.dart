// ignore_for_file: avoid_print

import 'dart:io';

/// Compiles the timeline web app to JavaScript.
void main() {
  final outputJsFile = File('build/timeline/script.js');
  if (outputJsFile.existsSync()) {
    outputJsFile.deleteSync();
  }

  final stopwatch = Stopwatch()..start();
  Process.runSync('dart', [
    'compile',
    'js',
    'lib/src/timeline/html/web/run_app.dart',
    '-O2',
    '--output=${outputJsFile.path}',
    '--no-source-maps',
  ]);
  stopwatch.stop();
  print('Compiled timline JS in ${stopwatch.elapsedMilliseconds}ms');

  final outputJsContent = outputJsFile.readAsStringSync();

  final scriptDartContent = "// AUTO GENERATED FILE. DO NOT MODIFY.\n\n"
      "/// The script used in the HTML file that is generated for the timeline.\n"
      "/// Generate it with `dart run tool/compile_js.dart` \n"
      "\n"
      "// language=javascript\n"
      "const String timelineJS = r'''\n$outputJsContent\n''';\n";

  File('lib/src/timeline/html/sources/script.js.g.dart')
      .writeAsStringSync(scriptDartContent);
  outputJsFile.deleteSync();
  File('${outputJsFile.path}.deps').deleteSync();
  print('Generated ${outputJsFile.path}');
}
