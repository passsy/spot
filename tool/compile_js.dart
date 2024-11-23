import 'dart:io';

/// Compiles the timeline web app to JavaScript.
void main() {
  Process.runSync('dart',
      'compile js lib/src/timeline/html/web/run_app.dart -O2 --output=tool/script.js --no-source-maps'.split(' '));

  final outputJsFile = File('tool/script.js');
  final outputJsContent = outputJsFile.readAsStringSync();

  final scriptDartContent = "// AUTO GENERATED FILE. DO NOT MODIFY.\n\n"
      "/// The script used in the HTML file that is generated for the timeline.\n"
      "// language=javascript\n"
      "const String timelineJS = r'''\n$outputJsContent\n''';\n";

  File('lib/src/timeline/html/sources/script.js.dart').writeAsStringSync(scriptDartContent);
  outputJsFile.deleteSync();
  File('${outputJsFile.path}.deps').deleteSync();
}
