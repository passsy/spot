// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:spot/src/timeline/html/print_html.dart';
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
  final test = Invoker.current?.liveTest;
  if (test == null) {
    throw StateError('timeline must be called within a test');
  }
  final timeline = _timelines[test];
  if (timeline != null) {
    // existing timeline
    return timeline;
  }

  // create new timeline
  final newTimeline = Timeline();

  Invoker.current!.addTearDown(() {
    if (!test.state.result.isPassing &&
        newTimeline.mode == TimelineMode.record) {
      newTimeline.printToConsole();
      printHTML(newTimeline._events);
    } else if (newTimeline.mode == TimelineMode.live) {
      // printToConsole() here would lead to duplicate output since
      // the timeline is already being printed live
      printHTML(newTimeline._events);
    }
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
  final List<TimelineEvent> _events = [];

  TimelineMode _mode = _globalTimelineMode;

  /// The mode of the timeline. Defaults to [TimelineMode.off].
  TimelineMode get mode => _mode;

  set mode(TimelineMode value) {
    if (value == _mode) {
      return;
    }
    // ignore: avoid_print
    print(value.message);

    _mode = value;
  }

  /// Adds an event to the timeline.
  void addEvent({
    required String details,
    Frame? initiator,
    Screenshot? screenshot,
    required String eventType,
    String? description,
  }) {
    addRawEvent(
      TimelineEvent(
        details: details,
        screenshot: screenshot,
        initiator: _mostRelevantCaller(
          fallbackFrame: initiator ?? screenshot?.initiator,
        ),
        timestamp: DateTime.now(),
        treeSnapshot: currentWidgetTreeSnapshot(),
        eventType: TimelineEventType(label: eventType),
      ),
    );
  }

  /// Adds a screenshot to the timeline.
  void addScreenshot(
    Screenshot screenshot, {
    required String details,
    required TimelineEventType eventType,
  }) {
    addRawEvent(
      TimelineEvent.now(
        details: details,
        screenshot: screenshot,
        initiator: _mostRelevantCaller(fallbackFrame: screenshot.initiator),
        eventType: eventType,
      ),
    );
  }

  /// Adds an event to the timeline.
  void addRawEvent(TimelineEvent event) {
    if (mode == TimelineMode.off) {
      return;
    }
    _events.add(event);
    if (mode == TimelineMode.live) {
      _printEvent(event);
    }
  }

  /// Prints the complete timeline to the console.
  void printToConsole() {
    // ignore: avoid_print
    print('Timeline');
    for (final event in _events) {
      _printEvent(event);
    }
  }

  void _printEvent(TimelineEvent event) {
    final StringBuffer buffer = StringBuffer();
    final frame = event.initiator;
    final caller = frame != null
        ? 'at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : 'N/A';

    buffer.writeln('==================== Timeline Event ====================');
    buffer.writeln('Event Type: ${event.eventType}');
    buffer.writeln('Details: ${event.details}');
    buffer.writeln('Caller: $caller');
    if (event.screenshot != null) {
      buffer.writeln('Screenshot: file://${event.screenshot!.file.path}');
    }
    buffer.writeln('Timestamp: ${event.timestamp.toIso8601String()}');
    buffer.writeln('========================================================');

    // ignore: avoid_print
    print(buffer);
  }

  /// Adds an assertion event to the timeline, if the timeline is not off.
  void maybeAddAssertion(String description) {
    if (timeline.mode == TimelineMode.off) return;
    const String label = 'Assertion';
    timeline.addEvent(details: description, eventType: label);
  }

  /// Adds an error event to the timeline, if the timeline is not off.
  Future<void> maybeAddErrorEvent(
    Object error, {
    required String details,
  }) async {
    if (timeline.mode != TimelineMode.off) {
      final binding = TestWidgetsFlutterBinding.instance;
      const String eventType = 'Error';

      if (binding is! LiveTestWidgetsFlutterBinding) {
        final screenshot = await takeScreenshot();
        timeline.addScreenshot(
          screenshot,
          details: details,
          eventType: const TimelineEventType(label: eventType),
        );
      } else {
        timeline.addEvent(details: details, eventType: eventType);
      }
    }
  }
}

/// The type of event that occurred during a test.
class TimelineEventType {
  /// The name of the event.
  final String label;

  // TODO add styling information like color?
  /// Creates a new timeline event type.
  const TimelineEventType({
    required this.label,
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
  });

  /// Creates a new timeline event with the current time and widget tree snapshot.
  factory TimelineEvent.now({
    required TimelineEventType eventType,
    required String details,
    Screenshot? screenshot,
    Frame? initiator,
  }) {
    return TimelineEvent(
      screenshot: screenshot,
      details: details,
      initiator: initiator,
      timestamp: DateTime.now(),
      treeSnapshot: currentWidgetTreeSnapshot(),
      eventType: eventType,
    );
  }

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
}

/// The mode of the timeline.
/// Available modes:
/// - [TimelineMode.live] - The timeline is recording and printing events as they happen.
/// - [TimelineMode.record] - The timeline is recording but not printing events unless the test fails.
/// - [TimelineMode.off] - The timeline is not recording.
enum TimelineMode {
  /// The timeline is recording and printing events as they happen.
  live('🔴 - Recording live timeline'),

  /// The timeline is recording but not printing events unless the test fails.
  record('🔴 - Recording error output timeline'),

  /// The timeline is not recording.
  off('⏸︎ - Timeline recording is off');

  const TimelineMode(this.message);

  /// The message to display when the timeline mode is set.
  final String message;
}

Frame? _mostRelevantCaller({Frame? fallbackFrame}) {
  final frames = Trace.current().frames;

  final nonPackageFrames = frames.where((frame) => frame.package == null);
  final testFileCaller = nonPackageFrames.lastWhereOrNull((frame) {
    final location = frame.location;
    return location.startsWith('test/') && location.endsWith('_test.dart');
  });

  final preferredFrame =
      testFileCaller ?? nonPackageFrames.lastOrNull ?? fallbackFrame;

  if (preferredFrame != null) {
    // remove any '<fn>' parts
    final memberName = preferredFrame.member?.split('.').first ?? '';
    return Frame(
      preferredFrame.uri,
      preferredFrame.line,
      preferredFrame.column,
      memberName,
    );
  }

  return null;
}
