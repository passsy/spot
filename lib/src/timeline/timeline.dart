// ignore_for_file: depend_on_referenced_packages

import 'package:ci/ci.dart';
import 'package:clock/clock.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
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
    getTimelineModeFromEnv() ?? TimelineMode.reportOnError;

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

/// Use --dart-define=SPOT_TIMELINE_MODE=live|always|reportOnError|off to set the [TimelineMode]
/// for all tests
TimelineMode? getTimelineModeFromEnv() {
  final mode = const String.fromEnvironment('SPOT_TIMELINE_MODE').toLowerCase();
  return switch (mode) {
    'live' => TimelineMode.live,
    'always' => TimelineMode.always,
    'reportOnError' => TimelineMode.reportOnError,
    // ignore: deprecated_member_use_from_same_package
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

  /// The mode of the timeline. Defaults to [TimelineMode.reportOnError].
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
        TimelineMode.always => '🔴 - Always shows the timeline',
        TimelineMode.reportOnError =>
          '🔴 - Shows the timeline when the test fails',
        // ignore: deprecated_member_use_from_same_package
        TimelineMode.record =>
          '🔴 - Recording, but only showing on test failure',
        TimelineMode.off => '⏸︎ - Timeline recording is off',
      },
    );

    _mode = value;
  }

  /// Adds an event to the timeline.
  ///
  /// Returns a unique identifier for the event which can be used to update
  /// its details later.
  TimelineEventId addEvent({
    required String details,
    required String eventType,
    Screenshot? screenshot,
    Frame? initiator,
    Color? color,
  }) {
    final id = TimelineEventId.random();
    final event = TimelineEvent(
      id: id,
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
    return id;
  }

  /// Removes a previously added event from the timeline.
  void removeEvent(TimelineEventId id) {
    _events.removeWhere((event) => event.id == id);
  }

  /// Allows updating an event with more information after it has been added.
  ///
  /// With this message assertions can be added and later updated when they
  /// failed with additional information about the error.
  late void Function({
    required TimelineEventId id,
    String? eventType,
    String? details,
    Screenshot? screenshot,
    Color? color,
    String? description,
  }) updateEvent = _updateEvent;

  void _updateEvent({
    required TimelineEventId id,
    Object? eventType = _undefined,
    Object? details = _undefined,
    Object? screenshot = _undefined,
    Object? color = _undefined,
    Object? description = _undefined,
  }) {
    final event = _events.firstOrNullWhere((event) => event.id == id);
    if (event == null) {
      throw StateError('Event with id $id not found');
    }

    if (!event.treeSnapshot.isFromThisFrame) {
      throw StateError(
        'You can not update an event after a new frame has been rendered',
      );
    }

    // ignore: cast_nullable_to_non_nullable
    final updatedColor = color == _undefined ? event.color : color as Color;
    final updatedDetails =
        // ignore: cast_nullable_to_non_nullable
        details == _undefined ? event.details : details as String;
    final updatedEventType = eventType == _undefined
        ? event.eventType
        : TimelineEventType(
            // ignore: cast_nullable_to_non_nullable
            label: eventType as String,
            color: updatedColor,
          );
    final updatedScreenshot =
        screenshot == _undefined ? event.screenshot : screenshot as Screenshot?;

    final updated = TimelineEvent(
      id: id,
      details: updatedDetails,
      eventType: updatedEventType,
      color: updatedColor,
      screenshot: updatedScreenshot,
      timestamp: event.timestamp,
      treeSnapshot: event.treeSnapshot,
      initiator: event.initiator,
    );
    final index = _events.indexOf(event);
    _events[index] = updated;
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
      await process();
    }
  }

  /// Event handler after the [test] has completed.
  ///
  /// Prints the timeline to console, as link to a html file or plain text
  Future<void> _onPostTest() async {
    Future<void> reportOnError() async {
      if (!test.state.result.isPassing) {
        // ignore: avoid_print
        print('Test failed, generating timeline report');
        await processPendingScreenshots();
        if (isCI) {
          // best for CI, prints the full timeline and doesn't require archiving the html timeline file
          printToConsole();
        }
        // best for humans
        await printHTML();
      }
    }

    switch (mode) {
      case TimelineMode.live:
        // during live mode the events are written directly to the console.
        // Finalize with html report
        await processPendingScreenshots();
        await printHTML();
      case TimelineMode.always:
        // ignore: avoid_print
        print('Generating timeline report');
        await processPendingScreenshots();
        if (isCI) {
          // best for CI, prints the full timeline and doesn't require archiving the html timeline file
          printToConsole();
        }
        // best for humans
        await printHTML();
      // ignore: deprecated_member_use_from_same_package
      case TimelineMode.record:
        await reportOnError();
      case TimelineMode.reportOnError:
        await reportOnError();
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
    required this.id,
    required this.timestamp,
    required this.treeSnapshot,
    required this.details,
    required this.eventType,
    this.initiator,
    this.screenshot,
    required this.color,
  });

  /// The unique identifier of the event used to update the event later.
  final TimelineEventId id;

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

  /// The color of the event.
  final Color color;
}

/// A unique identifier for a [TimelineEvent].
class TimelineEventId {
  /// Creates a fixed id for a [TimelineEvent].
  const TimelineEventId(this.value);

  /// Creates a new unique id for a [TimelineEvent].
  TimelineEventId.random() : value = nanoid();

  /// The actual value of the id.
  final String value;
}

/// The mode of the [Timeline] and how it should be generated
enum TimelineMode {
  /// The timeline is recording and printing events to the console as they happen.
  /// The timeline is also generated at the end of the test.
  live,

  /// Always prints the timeline at the end of the test
  always,

  /// In case the test fails, the timeline is generated at the end of the test.
  reportOnError,

  /// The timeline is recording but not printing events unless the test fails.
  ///
  /// Deprecated: It's the same as `reportOnError` but the new name is more descriptive.
  @Deprecated('Use reportOnError')
  record,

  /// No events will be recorded, the timeline is not generated after the test
  off;
}

/// Returns the most relevant caller that is part of the user code.
Frame? mostRelevantCaller({Trace? trace, Frame? fallback}) {
  final frames = (trace ?? Trace.current()).frames;

  final nonPackageFrames = frames.where((frame) => frame.package == null);
  final testFileCaller = nonPackageFrames.where((frame) {
    final lib = frame.library;
    return lib.startsWith('test/') && lib.endsWith('_test.dart');
  }).lastOrNull;

  final preferredFrame =
      testFileCaller ?? nonPackageFrames.lastOrNull ?? fallback;

  return preferredFrame;
}

const Object _undefined = Object();
