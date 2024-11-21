import 'dart:async';
import 'dart:io';

import 'package:spot/src/flutter/flutter_sdk.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

/// Runs a Flutter test in a new process and captures its output.
///
/// This function creates a temporary test file with the provided test code,
/// starts a new Flutter test process with the specified arguments, captures
/// the output of the process, and returns the captured output as a string.
/// The temporary test file is deleted after the test process completes.
/// If `captureStart` is provided, the output will be captured starting from the line that matches `captureStart`.
Future<String> runTestInProcessAndCaptureOutPut({
  required String testFileText,
  List<String> captureStart = const [],
  bool shouldFail = false,
  Iterable<String>? args,
}) async {
  final tempTestFile = await _createTempTestFile(testFileText);

  final arguments = [
    'test',
    tempTestFile.path,
    ...?args?.where((arg) => arg != 'test'),
  ];

  printOnFailure('$flutterExe ${arguments.join(' ')}');

  final testProcess = await TestProcess.start(
    flutterExe,
    arguments,
    environment: {
      'CI': 'true',
    },
  );
  final stdoutBuffer = StringBuffer();
  bool write = captureStart.isEmpty;

  final Completer<void> stdoutCompleter = Completer<void>();
  final Completer<void> stderrCompleter = Completer<void>();

  final stdoutStream = testProcess.stdoutStream();
  final stderrStream = testProcess.stderrStream();
  stdoutStream.listen(
    (line) {
      if (line.isEmpty) return;
      if (!write &&
          (captureStart.contains(line) || captureStart.any(line.contains))) {
        write = true;
      }
      if (write) {
        stdoutBuffer.writeln(line);
      }
    },
    onDone: () {
      stdoutCompleter.complete();
    },
  );
  stderrStream.listen(
    (line) {
      // ignore: avoid_print
      print("ERR: $line");
    },
    onDone: () {
      stderrCompleter.complete();
    },
  );

  await testProcess.shouldExit(shouldFail ? 1 : 0);
  await Future.wait([stdoutCompleter.future, stderrCompleter.future]);

  final stdout = stdoutBuffer.toString();

  return stdout;
}

Future<File> _createTempTestFile(String content) async {
  final tempDir = Directory.systemTemp.createTempSync();
  final tempTestFile = File('${tempDir.path}/temp_test.dart');
  await tempTestFile.writeAsString(content);
  addTearDown(() {
    _deleteTempDir(tempDir);
  });
  return tempTestFile;
}

void _deleteTempDir(Directory tempDir) {
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}
