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

Future<void> _run({required bool shouldFail}) async {
  await process.runTestInProcessAndCaptureOutPut(
    shouldFail: shouldFail,
    testFileText: () => _testFile(shouldFail: shouldFail),
  );
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

      // A failing run writes the report the developer then opens.
      await _run(shouldFail: true);
      expect(
        report.file('index.html').existsSync(),
        isTrue,
        reason: 'a failing test should have written a report',
      );

      // They fix the test and run it again. Nothing is reported this time, and
      // the report from before must not stay behind: the link from the failing
      // run would keep opening it, showing source and events that no longer
      // describe anything.
      await _run(shouldFail: false);
      expect(report.existsSync(), isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
