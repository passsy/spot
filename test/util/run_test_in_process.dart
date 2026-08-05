import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:spot/src/flutter/flutter_sdk.dart';
import 'package:spot/src/utils/invoker.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

/// Runs a Flutter test in a new process and captures its output.
///
/// This function creates a temporary test file with the provided test code,
/// starts a new Flutter test process with the specified arguments, captures
/// the output of the process, and returns the captured output as a string.
/// The temporary test file is deleted after the test process completes.
/// If `captureStart` is provided, the output will be captured starting from the line that matches `captureStart`.
Future<String?> runTestInProcessAndCaptureOutPut({
  required String Function() testFileText,
  List<String> captureStart = const [],
  bool shouldFail = false,
  Iterable<String>? args,
}) async {
  if (kIsWeb) {
    markTestSkipped('Running a Test process is unsupported on platform web');
    return null;
  }
  final tempTestFile = await _createTempTestFile(testFileText());

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
      ..._ownBuildDirectory(),
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

/// Environment that sends the nested `flutter test` to a build directory of its
/// own instead of the one this repository is being tested in.
///
/// The nested process inherits the working directory, so without this every run
/// writes into the same `build/`. `flutter test` empties
/// `build/native_assets/<os>/` on startup, writes the `native_assets.json` it
/// copies into the test assets into that same directory, and copies it only
/// after building the asset bundle. A run that starts while another one is
/// between those two steps deletes the file that run is about to copy:
///
/// ```text
/// Flutter failed to copy file from ".../build/native_assets/linux/native_assets.json"
/// to ".../build/unit_test_assets/NativeAssetsManifest.json".
/// The file or directory could not be found.
/// ```
///
/// The build directory is only settable through Flutter's config file, so the
/// nested process gets a config file of its own. Every test file gets one build
/// directory, not every run: runs of one file are sequential and cannot collide,
/// and sharing keeps their compilation cache warm.
Map<String, String> _ownBuildDirectory() {
  final configDir = Directory.systemTemp.createTempSync('spot_flutter_config');
  addTearDown(() {
    _deleteTempDir(configDir);
  });

  final settings = jsonEncode({'build-dir': _buildDirectoryOfTestFile()});
  // Linux and macOS read `$XDG_CONFIG_HOME/settings`, Windows reads
  // `$APPDATA/.flutter_settings`. Writing both means not caring which one runs.
  File('${configDir.path}/settings').writeAsStringSync(settings);
  File('${configDir.path}/.flutter_settings').writeAsStringSync(settings);

  final home = Platform.environment['HOME'];
  if (!Platform.isWindows &&
      home != null &&
      File('$home/.flutter_settings').existsSync()) {
    printOnFailure(
      'Nested test runs share one build directory on this machine, because '
      '$home/.flutter_settings takes precedence over the config file they were '
      'given. Deleting that file (Flutter has not written it since 2021) makes '
      'them independent again.',
    );
  }

  return {
    'XDG_CONFIG_HOME': configDir.path,
    'APPDATA': configDir.path,
  };
}

/// A directory under `build/`, named after the test file that is running.
///
/// The path has to be relative, Flutter rejects an absolute one.
String _buildDirectoryOfTestFile() {
  final path = getLiveTest()?.suite.path;
  if (path == null) {
    // Only null outside a running test, which is not where nested runs start.
    return 'build/nested_test/unknown';
  }
  final current = Directory.current.path;
  final relative =
      path.startsWith(current) ? path.substring(current.length) : path;
  final name = relative
      .replaceAll(RegExp('[^A-Za-z0-9]+'), '_')
      .replaceFirst(RegExp('^_'), '');
  return 'build/nested_test/$name';
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
