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
/// Only the test runner fails a test and runs its tearDowns, so these run in
/// a `flutter test` of their own. A `main()` sets one global mode, so there
/// is a run per global mode, started at the same time. What is recorded while a test runs is
/// tested in-process in `timeline_mode_test.dart`.
void main() {
  // The run is shared, and the tearDowns it registers in setUpAll run after
  // the last test, together with the reports it left in build/timeline.
  late final Map<String, String> printed;
  setUpAll(() async {
    final runs = await Future.wait([
      _runTimelineTests(globalMode: 'live', tests: _tests),
      _runTimelineTests(
        globalMode: 'reportOnError',
        tests: _globalReportOnErrorTests,
      ),
    ]);
    printed = {for (final run in runs) ...run};
  });

  test('the global mode from main() applies to every test', () {
    final output = printed['global live, passes']!;
    expect(output, isNot(contains('🔴')));
    expect(printedEvents(output).map((e) => e.summary), tapCounterEvents);
    _expectHtmlReport(output);
  });

  test('live prints each event once, also when the test fails', () {
    final output = printed['live, fails']!;
    expect(
      printedEvents(output).map((e) => e.summary),
      [...tapCounterEvents, _failedAssertion],
    );
    expect(output, isNot(contains('Timeline of test:')));
    expect(output, isNot(contains('Test failed, generating timeline report')));
    _expectHtmlReport(output);
  });

  test('reportOnError prints nothing when the test passes', () {
    expect(
      printed['reportOnError, passes'],
      '🔴 - Shows the timeline when the test fails\n',
    );
  });

  test('reportOnError prints the timeline when the test fails', () {
    final output = printed['reportOnError, fails']!;
    expect(output, contains('Test failed, generating timeline report'));
    expect(output, contains('Timeline of test: $_group reportOnError, fails'));
    expect(
      printedEvents(output).map((e) => e.summary),
      [...tapCounterEvents, _failedAssertion],
    );
    _expectHtmlReport(output);
  });

  test('always prints the timeline when the test passes', () {
    final output = printed['always, passes']!;
    expect(output, contains('Generating timeline report'));
    expect(output, contains('Timeline of test: $_group always, passes'));
    expect(printedEvents(output).map((e) => e.summary), tapCounterEvents);
    _expectHtmlReport(output);
  });

  test('a global reportOnError prints nothing when the test passes', () {
    expect(printed['global reportOnError, passes'] ?? '', isEmpty);
  });

  test('a global reportOnError prints the timeline when the test fails', () {
    final output = printed['global reportOnError, fails']!;
    expect(output, isNot(contains('🔴')));
    expect(output, contains('Test failed, generating timeline report'));
    expect(
      output,
      contains('Timeline of test: $_group global reportOnError, fails'),
    );
    expect(
      printedEvents(output).map((e) => e.summary),
      [...tapCounterEvents, _failedAssertion],
    );
    _expectHtmlReport(output);
  });

  test('off prints nothing when the test fails', () {
    final output = printed['off, fails']!;
    expect(output, startsWith('⏸︎ - Timeline recording is off\n'));
    expect(printedEvents(output), isEmpty);
    expect(output, isNot(contains('View timeline here:')));
  });
}

/// Makes the names of the nested tests, and with them the directories of their
/// reports, unique to this run.
final String _group = 'nested-${Random().nextInt(1 << 32).toRadixString(36)}';

/// The tests of the nested run. All tap the counter, which records
/// [tapCounterEvents], and the failing ones add [_failedAssertion].
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

/// Runs [tests] with [globalMode] set in `main()`, and returns what each
/// printed, by test name without group.
Future<Map<String, String>> _runTimelineTests({
  required String globalMode,
  required String tests,
}) async {
  final widget =
      File('test/timeline/timeline_test_widget.dart').readAsStringSync();
  final json = await runTestInProcessAndCaptureOutPut(
    shouldFail: true,
    args: ['--reporter', 'json'],
    testFileText: () => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

${widget.replaceAll(RegExp('^import .*\$', multiLine: true), '')}

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
          names[test['id'] as int] = name.substring(_group.length + 1);
        }
      case 'print':
        final name = names[event['testID']];
        if (name != null) {
          (printed[name] ??= StringBuffer()).writeln(event['message']);
        }
    }
  }
  addTearDown(() {
    for (final report in Directory('build/timeline').listSync()) {
      if (report.path.split(Platform.pathSeparator).last.startsWith(_group)) {
        report.deleteSync(recursive: true);
      }
    }
  });
  printOnFailure('Output of the nested run:\n$json');
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
}

const _failedAssertion = 'Assertion Failed: Could not find Widget with text '
    'contains text "Counter: 99" in widget tree, expected exactly 1.';
