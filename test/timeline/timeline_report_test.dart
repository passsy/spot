// Starting `flutter test` is slower than the default timeout allows for on a
// cold CI machine.
@Timeout(Duration(minutes: 3))
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../util/run_test_in_process.dart';
import 'printed_timeline.dart';
import 'timeline_test_widget.dart';

/// What the timeline prints after a test ended, which depends on whether the
/// test failed, and the global mode set in `main()`.
///
/// Only the test runner fails a test and runs its tearDowns, so the cases run
/// in a `flutter test` of their own, one per test here, as a `main()` sets only
/// one global mode. What is recorded while a test runs is tested in-process in
/// `timeline_mode_test.dart`.
void main() {
  test(
    'with a global live, prints the timeline after a test per mode',
    () async {
      final printed = await _runTimelineTests(
        globalMode: 'live',
        tests: _tests,
      );

      // A global live, set in main(), prints every event without announcing it.
      final globalLive = printed['global live, passes']!;
      expect(globalLive, isNot(contains('🔴')));
      expect(printedEvents(globalLive).map((e) => e.summary), tapCounterEvents);
      _expectHtmlReport(globalLive);

      // Live prints each event once, also when the test fails.
      final liveFails = printed['live, fails']!;
      expect(printedEvents(liveFails).map((e) => e.summary), [
        ...tapCounterEvents,
        _failedAssertion,
        _testFailed,
      ]);
      expect(liveFails, isNot(contains('Timeline of test:')));
      expect(
        liveFails,
        isNot(contains('Test failed, generating timeline report')),
      );
      _expectHtmlReport(liveFails);

      // reportOnError prints nothing but the mode change when the test passes.
      expect(
        printed['reportOnError, passes'],
        '🔴 - Shows the timeline when the test fails\n',
      );

      // reportOnError prints the timeline when the test fails.
      final reportOnErrorFails = printed['reportOnError, fails']!;
      expect(
        reportOnErrorFails,
        contains('Test failed, generating timeline report'),
      );
      expect(
        reportOnErrorFails,
        contains('Timeline of test: $_group reportOnError, fails'),
      );
      expect(printedEvents(reportOnErrorFails).map((e) => e.summary), [
        ...tapCounterEvents,
        _failedAssertion,
        _testFailed,
      ]);
      _expectHtmlReport(reportOnErrorFails);

      // always prints the timeline when the test passes.
      final alwaysPasses = printed['always, passes']!;
      expect(alwaysPasses, contains('Generating timeline report'));
      expect(
        alwaysPasses,
        contains('Timeline of test: $_group always, passes'),
      );
      expect(
        printedEvents(alwaysPasses).map((e) => e.summary),
        tapCounterEvents,
      );
      _expectHtmlReport(alwaysPasses);

      // off prints nothing when the test fails.
      final offFails = printed['off, fails']!;
      expect(offFails, startsWith('⏸︎ - Timeline recording is off\n'));
      expect(printedEvents(offFails), isEmpty);
      expect(offFails, isNot(contains('View timeline here:')));
    },
  );

  test(
    'a global reportOnError prints the timeline only when a test fails',
    () async {
      final printed = await _runTimelineTests(
        globalMode: 'reportOnError',
        tests: _globalReportOnErrorTests,
      );

      expect(printed['global reportOnError, passes'], isEmpty);
      final globalReportOnErrorFails = printed['global reportOnError, fails']!;
      expect(globalReportOnErrorFails, isNot(contains('🔴')));
      expect(
        globalReportOnErrorFails,
        contains('Test failed, generating timeline report'),
      );
      expect(
        globalReportOnErrorFails,
        contains('Timeline of test: $_group global reportOnError, fails'),
      );
      expect(printedEvents(globalReportOnErrorFails).map((e) => e.summary), [
        ...tapCounterEvents,
        _failedAssertion,
        _testFailed,
      ]);
      _expectHtmlReport(globalReportOnErrorFails);
    },
  );
}

/// Makes the names of the nested tests, and with them the directories of their
/// reports, unique to this run.
final String _group = 'nested-${Random().nextInt(1 << 32).toRadixString(36)}';

/// The tests of the nested run. All tap the counter, which records
/// [tapCounterEvents], and the failing ones add [_failedAssertion].
/// A test passes when its name ends with `passes`, and fails otherwise.
///
/// The nested run has `CI` set, so a report prints the full timeline next to
/// the link to the HTML report.
const String _tests = '''
    testWidgets('global live, passes', (tester) async {
      await tapCounter(tester);
    });

    testWidgets('live, fails', (tester) async {
      await tapCounter(tester);
      spotText('Counter: 99').existsOnce();
    });

    testWidgets('reportOnError, passes', (tester) async {
      timeline.mode = TimelineMode.reportOnError;
      await tapCounter(tester);
    });

    testWidgets('reportOnError, fails', (tester) async {
      timeline.mode = TimelineMode.reportOnError;
      await tapCounter(tester);
      spotText('Counter: 99').existsOnce();
    });

    testWidgets('always, passes', (tester) async {
      timeline.mode = TimelineMode.always;
      await tapCounter(tester);
    });

    testWidgets('off, fails', (tester) async {
      timeline.mode = TimelineMode.off;
      await tapCounter(tester);
      spotText('Counter: 99').existsOnce();
    });
''';

/// The tests of the run with `reportOnError` as the global mode.
const String _globalReportOnErrorTests = '''
    testWidgets('global reportOnError, passes', (tester) async {
      await tapCounter(tester);
    });

    testWidgets('global reportOnError, fails', (tester) async {
      await tapCounter(tester);
      spotText('Counter: 99').existsOnce();
    });
''';

/// Runs [tests] with [globalMode] set in `main()`, expects each to pass or fail
/// as its name says, and returns what each printed, by test name without
/// group.
Future<Map<String, String>> _runTimelineTests({
  required String globalMode,
  required String tests,
}) async {
  final imports = RegExp(r'^(// ignore: .*\n)?import .*$', multiLine: true);
  final widget = File(
    'test/timeline/timeline_test_widget.dart',
  ).readAsStringSync().replaceAll(imports, '');
  final json = await runTestInProcessAndCaptureOutPut(
    shouldFail: true,
    args: ['--reporter', 'json'],
    testFileText: () =>
        '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

$widget

void main() {
  globalTimelineMode = TimelineMode.$globalMode;
  group('$_group', () {
$tests
  });
}
''',
  );

  final names = <int, String>{};
  final printed = <String, StringBuffer>{};
  final results = <String, String>{};
  for (final line in LineSplitter.split(json!)) {
    if (!line.startsWith('{')) {
      continue;
    }
    final event = jsonDecode(line) as Map<String, dynamic>;
    switch (event['type']) {
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        final name = test['name'] as String;
        if (name.startsWith('$_group ')) {
          final short = name.substring(_group.length + 1);
          names[test['id'] as int] = short;
          printed[short] = StringBuffer();
        }
      case 'print':
        final name = names[event['testID']];
        if (name != null) {
          printed[name]!.writeln(event['message']);
        }
      case 'testDone':
        final name = names[event['testID']];
        if (name != null) {
          results[name] = event['result'] as String;
        }
    }
  }
  // Spot shortens long report paths, so the links tell where they are.
  final reports = RegExp(
    r'View timeline here: file://(.*)index\.html',
  ).allMatches(json).map((match) => Directory(match.group(1)!));
  addTearDown(() {
    for (final report in reports) {
      if (report.existsSync()) {
        report.deleteSync(recursive: true);
      }
    }
  });
  printOnFailure('Output of the nested run:\n$json');
  final declared = RegExp(
    r"testWidgets\('([^']+)'",
  ).allMatches(tests).map((match) => match.group(1)!);
  // flutter_test reports a failing widget test as an error.
  expect(results, {
    for (final name in declared)
      name: name.endsWith('passes') ? 'success' : 'error',
  });
  return printed.map((name, output) => MapEntry(name, output.toString()));
}

/// Expects the link to the HTML report in [output], and the report on disk.
void _expectHtmlReport(String output) {
  final link = output
      .split('\n')
      .firstWhere((line) => line.startsWith('View timeline here: file://'));
  final html = File(link.substring('View timeline here: file://'.length));
  expect(html.path, endsWith('index.html'));
  expect(html.readAsStringSync(), isNotEmpty);
  final screenshots = Directory('${html.parent.path}/screenshots').listSync();
  expect(screenshots, isNotEmpty);

  // The tap marks where it landed in an overlay drawn over the frame capture,
  // and both are files next to the report.
  final events =
      (jsonDecode(File('${html.parent.path}/events.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();
  final tap = events.firstWhere(
    (event) => (event['overlayUrls'] as List).isNotEmpty,
  );
  final frameUrl = tap['screenshotUrl'] as String;
  final overlayUrl = (tap['overlayUrls'] as List).single as String;
  expect(frameUrl, startsWith('./screenshots/frame-'));
  for (final url in [frameUrl, overlayUrl]) {
    expect(
      File('${html.parent.path}/${url.substring(2)}').existsSync(),
      isTrue,
    );
  }
}

const _failedAssertion =
    'Assertion Failed: Could not find Widget with text '
    'contains text "Counter: 99" in widget tree, expected exactly 1.';

/// What failed the test, which the timeline records as its last event.
const _testFailed =
    'Test Failed: Could not find Widget with text '
    'contains text "Counter: 99" in widget tree, expected exactly 1.';
