import 'package:flutter_test/flutter_test.dart';

import '../util/run_test_in_process.dart' as process;
import 'timeline_test_shared.dart' as shared;

/// A widget test that fails with a plain `expect`, which spot knows nothing
/// about. Run in its own process, because the point is that it fails.
String _failingTest({required String failure}) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('failing test', (tester) async {
    timeline.mode = TimelineMode.always;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Counter: 3'))),
    );
    spotText('Counter: 3').existsOnce();
    $failure
  });
}
''';
}

Future<String?> _outputOfFailingTest({required String failure}) {
  return process.runTestInProcessAndCaptureOutPut(
    shouldFail: true,
    testFileText: () => _failingTest(failure: failure),
    captureStart: const [shared.timelineHeader],
  );
}

void main() {
  test(
    'a failed expect becomes the last event of the timeline',
    () async {
      final output = await _outputOfFailingTest(
        failure: "expect(1, 2, reason: 'the counter never moved');",
      );
      if (output == null) {
        return;
      }

      expect(output, contains('Event Type: Test Failed'));
      // The real failure, not the 'Test failed. See exception logs above.'
      // placeholder that the test framework reports in its place.
      expect(output, contains('the counter never moved'));
      expect(output, contains('Expected: <2>'));
      expect(output, contains('Actual: <1>'));
      // The line that failed, so the report can point at it.
      expect(output, contains(RegExp(r'Caller: at .*temp_test\.dart:12:')));

      // Last, and only once.
      final events = 'Event Type: '.allMatches(output).length;
      final failures = 'Event Type: Test Failed'.allMatches(output).length;
      expect(failures, 1);
      expect(output.lastIndexOf('Event Type: Test Failed'), greaterThan(0));
      expect(events, greaterThan(failures));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'a thrown exception becomes the last event of the timeline',
    () async {
      final output = await _outputOfFailingTest(
        failure: "throw StateError('the widget is gone');",
      );
      if (output == null) {
        return;
      }

      expect(output, contains('Event Type: Test Failed'));
      expect(output, contains('Bad state: the widget is gone'));
      expect(output, contains(RegExp(r'Caller: at .*temp_test\.dart:12:')));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
