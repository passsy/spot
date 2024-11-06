// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:ci/ci.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:spot/src/timeline/html/print_html.dart';
import 'package:spot/src/timeline/print_console.dart';
import 'package:stack_trace/stack_trace.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

TimelineMode _globalTimelineMode =
    getTimelineModeFromEnv() ?? TimelineMode.record;

/// Returns the global timeline mode than can be used across multiple tests
TimelineMode get globalTimelineMode => _globalTimelineMode;

set globalTimelineMode(TimelineMode value) {
  final test = Invoker.current?.liveTest;
  if (test != null) {
    throw StateError('''
Cannot change global timeline mode within a test.
Use "timeline.mode" instead.
Example: timeline.mode = $value;
      ''');
  }
  _globalTimelineMode = value;
}

/// Use --dart-define=SPOT_TIMELINE_MODE=live|record|off to set the [TimelineMode]
/// for all tests
TimelineMode? getTimelineModeFromEnv() {
  final mode = const String.fromEnvironment('SPOT_TIMELINE_MODE').toLowerCase();
  return switch (mode) {
    'live' => TimelineMode.live,
    'record' => TimelineMode.record,
    'off' => TimelineMode.off,
    _ => null,
  };
}

final Map<LiveTest, Timeline> _timelines = {};

/// Returns the current timeline for the test or creates a new one if
/// it doesn't exist.
Timeline get timeline {
  final LiveTest? test = Invoker.current?.liveTest;
  if (test == null) {
    throw StateError('timeline must be called within a test');
  }
  final timeline = _timelines[test];
  if (timeline != null) {
    // existing timeline
    return timeline;
  }

  // create new timeline
  final newTimeline = Timeline._(test);

  Invoker.current!.addTearDown(() async {
    await newTimeline._onPostTest();
    _timelines.remove(test);
  });

  _timelines[test] = newTimeline;
  return newTimeline;
}

/// Allows for tracking a timeline of events during a test.
///
/// Usage:
/// ```dart
/// void main() {
///  globalTimelineMode = TimelineMode.live;
///
///  testWidgets('Test 1', (tester) async {
///    // ...
///  });
///
///  testWidgets('Test 2', (tester) async {
///    // ...
///  });
/// }
/// ```
/// See also:
/// - [TimelineMode] for the available modes.
class Timeline {
  Timeline._(this.test);

  /// The test that the timeline is associated with.
  final LiveTest test;

  /// The events that have recording during the test.
  List<TimelineEvent> get events => List.unmodifiable(_events);
  final List<TimelineEvent> _events = [];

  TimelineMode _mode = _globalTimelineMode;

  /// The mode of the timeline. Defaults to [TimelineMode.off].
  TimelineMode get mode => _mode;

  set mode(TimelineMode value) {
    if (value == _mode) {
      return;
    }
    // ignore: avoid_print
    print(
      switch (value) {
        TimelineMode.live =>
          '🔴 - Live! Shows all timeline events as they happen',
        TimelineMode.record =>
          '🔴 - Recording, but only showing on test failure',
        TimelineMode.off => '⏸︎ - Timeline recording is off',
      },
    );

    _mode = value;
  }

  /// Adds an event to the timeline.
  void addEvent({
    required String details,
    required String eventType,
    Screenshot? screenshot,
    Frame? initiator,
    Color? color,
    String? description,
  }) {
    final event = TimelineEvent(
      details: details,
      screenshot: screenshot,
      initiator: mostRelevantCaller(
        fallback: initiator ?? screenshot?.initiator,
      ),
      timestamp: clock.now(),
      color: color ?? Colors.white,
      treeSnapshot: currentWidgetTreeSnapshot(),
      eventType: TimelineEventType(
        label: eventType,
        color: color,
      ),
    );
    _addRawEvent(event);
  }

  /// Adds an event to the timeline.
  void _addRawEvent(TimelineEvent event) {
    if (mode == TimelineMode.off) {
      return;
    }
    _events.add(event);
    if (mode == TimelineMode.live) {
      printEventToConsole(event);
    }
  }

  final List<Future<void> Function()> _toBeProcessedScreenshots = [];

  /// Adds a function that processes a pending [Screenshot] to be processed at a later time (or never).
  ///
  /// To speed up processing, the screenshots are only processed when actually needed in a report (console or html).
  void addScreenshotProcessing(Future<void> Function() process) {
    _toBeProcessedScreenshots.add(process);
  }

  /// Processes all pending screenshots
  Future<void> processPendingScreenshots() async {
    if (_toBeProcessedScreenshots.isEmpty) {
      return;
    }
    for (final process in _toBeProcessedScreenshots.toList()) {
      stdout.write('.');
      await process();
    }
  }

  /// Event handler after the [test] has completed.
  ///
  /// Prints the timeline to console, as link to a html file or plain text
  Future<void> _onPostTest() async {
    switch (mode) {
      case TimelineMode.live:
        // during live mode the events are written directly to the console.
        // Finalize with html report
        await processPendingScreenshots();
        printHTML();
      case TimelineMode.record:
        if (!test.state.result.isPassing) {
          // ignore: avoid_print
          print('Test failed, generating timeline report');
          await processPendingScreenshots();
          if (isCI) {
            // best for CI, prints the full timeline and doesn't require archiving the html timeline file
            printToConsole();
          }
          // best for humans
          printHTML();
        } else {
          // do nothing
          break;
        }
      case TimelineMode.off:
        // do nothing
        break;
    }
  }
}

/// The type of event that occurred during a test.
class TimelineEventType {
  /// The name of the event.
  final String label;

  /// The color of the event currently used as border in the html export but that can change
  final Color? color;

  /// Creates a new timeline event type.
  const TimelineEventType({
    required this.label,
    this.color,
  });

  @override
  String toString() {
    return label;
  }
}

/// An event that occurred during a test.
class TimelineEvent {
  /// Creates a new timeline event.
  const TimelineEvent({
    required this.timestamp,
    required this.treeSnapshot,
    required this.details,
    required this.eventType,
    this.description,
    this.initiator,
    this.screenshot,
    required this.color,
  });

  /// The type of event that occurred.
  final TimelineEventType eventType;

  /// The screenshot taken at the time of the event.
  final Screenshot? screenshot;

  /// The details of the event.
  final String details;

  /// The time at which the event occurred.
  final DateTime timestamp;

  /// The widget tree snapshot at the time of the event.
  final WidgetTreeSnapshot treeSnapshot;

  /// The frame that initiated the event.
  final Frame? initiator;

  /// Custom plain-text information about the event.
  final String? description;

  /// The color of the event.
  final Color color;
}

/// The mode of the timeline.
/// Available modes:
/// - [TimelineMode.live] - The timeline is recording and printing events as they happen.
/// - [TimelineMode.record] - The timeline is recording but not printing events unless the test fails.
/// - [TimelineMode.off] - The timeline is not recording.
enum TimelineMode {
  /// The timeline is recording and printing events as they happen.
  live,

  /// The timeline is recording but not printing events unless the test fails.
  record,

  /// The timeline is not recording.
  off;
}

/// Returns the most relevant caller that is part of the user code.
Frame? mostRelevantCaller({Trace? trace, Frame? fallback}) {
  final frames = (trace ?? Trace.current()).frames;

  final nonPackageFrames = frames.where((frame) => frame.package == null);
  final testFileCaller = nonPackageFrames.lastWhereOrNull((frame) {
    final lib = frame.library;
    return lib.startsWith('test/') && lib.endsWith('_test.dart');
  });

  final preferredFrame =
      testFileCaller ?? nonPackageFrames.lastOrNull ?? fallback;

  return preferredFrame;
}
