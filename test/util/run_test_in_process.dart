import 'dart:io';

import 'package:test_process/test_process.dart';

/// Runs a Flutter test in a new process and captures its output.
///
/// This function creates a temporary test file with the provided test code,
/// starts a new Flutter test process with the specified arguments, captures
/// the output of the process, and returns the captured output as a string.
/// The temporary test file is deleted after the test process completes.
///
/// The `args` parameter allows additional arguments to be passed to the test
/// process. The `'test'` argument is always included automatically and should
/// not be repeated in the `args` list. If `captureStart` is provided, the
/// output will be captured starting from the line that matches `captureStart`.
Future<String> runTestInProcessAndCaptureOutPut({
  required String testAsString,
  String? captureStart,
  bool shouldFail = false,
  Iterable<String>? args,
}) async {
  final tempTestFile = await _createTempTestFile(testAsString);

  final arguments = [
    'test',
    tempTestFile.path,
    ...?args?.where((arg) => arg != 'test'),
  ];

  final testProcess = await TestProcess.start('flutter', arguments);
  final stdoutBuffer = StringBuffer();
  bool write = captureStart == null;

  await for (final line in testProcess.stdoutStream()) {
    if (line.isEmpty) continue;
    if (!write && line == captureStart) {
      write = true;
    }
    if (write) {
      stdoutBuffer.writeln(line);
    }
  }

  await testProcess.shouldExit(shouldFail ? 1 : 0);

  final stdout = stdoutBuffer.toString();

  _deleteTempDir(tempTestFile.parent);
  return stdout;
}

Future<File> _createTempTestFile(String content) async {
  final tempDir = Directory.systemTemp.createTempSync();
  final tempTestFile = File('${tempDir.path}/temp_test.dart');
  await tempTestFile.writeAsString(content);
  return tempTestFile;
}

void _deleteTempDir(Directory tempDir) {
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}
