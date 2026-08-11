import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../util/run_test_in_process.dart' as process;
import 'timeline_test_shared.dart' as shared;

/// A widget test that fails with a plain `expect`, which spot knows nothing
/// about. Run in its own process, because the point is that it fails.
///
/// [teardown] is registered after the timeline exists, so it runs before
/// spot's own teardown, the way a test's own cleanup does.
String _failingTest({required String failure, String teardown = ''}) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('failing test', (tester) async {
    timeline.mode = TimelineMode.always;
    addTearDown(() async {
      $teardown
    });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Counter: 3'))),
    );
    spotText('Counter: 3').existsOnce();
    $failure
  });
}
''';
}

Future<String?> _outputOfFailingTest({
  required String failure,
  String teardown = '',
}) {
  return process.runTestInProcessAndCaptureOutPut(
    shouldFail: true,
    testFileText: () => _failingTest(failure: failure, teardown: teardown),
    captureStart: const [shared.timelineHeader],
  );
}

/// The 1-based line [needle] sits on in [source].
///
/// Computed rather than written down, so growing the test template by a line
/// does not silently move what the caller assertions point at.
int _lineOf(String source, String needle) {
  final lines = const LineSplitter().convert(source);
  final index = lines.indexWhere((line) => line.contains(needle));
  expect(index, greaterThan(-1), reason: '"$needle" is not in the test file');
  return index + 1;
}

/// The console block the timeline printed for the failure event.
String _failureEventBlock(String output) {
  final start = output.lastIndexOf('Event Type: Test Failed');
  expect(start, greaterThan(-1), reason: 'no Test Failed event in:\n$output');
  final end = output.indexOf(shared.timelineSeparator, start);
  return output.substring(start, end == -1 ? output.length : end);
}

void main() {
  test(
    'a failed expect becomes the last event of the timeline',
    () async {
      const failure = "expect(1, 2, reason: 'the counter never moved');";
      final output = await _outputOfFailingTest(failure: failure);
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
      final line = _lineOf(_failingTest(failure: failure), failure);
      expect(output, contains(RegExp('Caller: at .*temp_test\\.dart:$line:')));

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
      const failure = "throw StateError('the widget is gone');";
      final output = await _outputOfFailingTest(failure: failure);
      if (output == null) {
        return;
      }

      expect(output, contains('Event Type: Test Failed'));
      expect(output, contains('Bad state: the widget is gone'));
      final line = _lineOf(_failingTest(failure: failure), failure);
      expect(output, contains(RegExp('Caller: at .*temp_test\\.dart:$line:')));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'the failure is captured while the failing frame is still on screen',
    () async {
      final output = await _outputOfFailingTest(failure: 'expect(1, 2);');
      if (output == null) {
        return;
      }

      expect(_failureEventBlock(output), contains('Screenshot: file://'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'no capture once a teardown has drawn over the failing frame',
    () async {
      // Teardowns run before spot's, so this replaces what was on screen when
      // the test failed. A capture taken now would be this widget, not the
      // failure, so the event goes without one.
      final output = await _outputOfFailingTest(
        failure: 'expect(1, 2);',
        teardown: '''
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('torn down'))),
      );
''',
      );
      if (output == null) {
        return;
      }

      final block = _failureEventBlock(output);
      expect(block, isNot(contains('Screenshot: file://')));
      // The failure itself is still reported, only its capture is missing.
      expect(block, contains('Expected: <2>'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
