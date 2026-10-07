// Runs tests in a process of their own, which a browser cannot start.
@TestOn('vm')
library;

import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/run_test_in_process.dart' as process;

/// A test that fails or passes on demand, run in its own process so the
/// failing variant does not fail this suite.
String _testFile({required bool shouldFail}) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('stale report probe', (tester) async {
    timeline.mode = TimelineMode.reportOnError;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Counter: 3'))),
    );
    spotText('Counter: 3').existsOnce();
    expect('marker', ${shouldFail ? "'boom'" : "'marker'"});
  });
}
''';
}

/// Runs the probe as [testFile], which is what makes two runs the same test.
Future<void> _run({required bool shouldFail, required File testFile}) async {
  await process.runTestInProcessAndCaptureOutPut(
    shouldFail: shouldFail,
    testFileText: () => _testFile(shouldFail: shouldFail),
    testFile: testFile,
  );
}

/// A test file in a directory of its own, removed with the test.
File _setupTestFile(String name) {
  final directory = Directory.systemTemp.createTempSync('spot_stale_report');
  addTearDown(() => directory.deleteSync(recursive: true));
  return directory.file(name);
}

void main() {
  test(
    'a run that reports nothing takes the previous report with it',
    () async {
      if (Platform.environment.containsKey('FLUTTER_TEST_BROWSER')) {
        return;
      }
      final report = Directory(
        'build',
      ).directory('timeline').directory('stale-report-probe');

      final testFile = _setupTestFile('probe_test.dart');

      // A failing run writes the report the developer then opens.
      await _run(shouldFail: true, testFile: testFile);
      expect(
        report.file('index.html').existsSync(),
        isTrue,
        reason: 'a failing test should have written a report',
      );

      // They fix the test and run it again. Nothing is reported this time, and
      // the report from before must not stay behind: the link from the failing
      // run would keep opening it, showing source and events that no longer
      // describe anything.
      await _run(shouldFail: false, testFile: testFile);
      expect(report.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'a passing test leaves the report of its namesake in another file alone',
    () async {
      final report = Directory(
        'build',
      ).directory('timeline').directory('stale-report-probe');

      await _run(shouldFail: true, testFile: _setupTestFile('a_test.dart'));
      expect(report.file('index.html').existsSync(), isTrue);

      // Reports are named after the test alone, so this one shares the
      // directory. It has nothing to report, and nothing to clean up either.
      await _run(shouldFail: false, testFile: _setupTestFile('b_test.dart'));
      expect(
        report.file('index.html').existsSync(),
        isTrue,
        reason: 'the failure report belongs to the other test file',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
