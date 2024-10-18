// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:spot/src/timeline/html/print_html.dart';
import 'package:spot/src/timeline/html/script.js.dart';
import 'package:spot/src/timeline/html/styles.css.dart';
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

  /// Adds a screenshot to the timeline.
  void addScreenshot(
    Screenshot screenshot, {
    String? name,
    TimelineEventType? eventType,
  }) {
    addRawEvent(
      TimelineEvent.now(
        name: name,
        screenshot: screenshot,
        initiator: _mostRelevantCaller(fallbackFrame: screenshot.initiator),
        eventType: eventType,
      ),
    );
  }

  /// Adds an event to the timeline.
  void addEvent({
    String? name,
    Frame? initiator,
    Screenshot? screenshot,
    String? eventType,
    String? description,
  }) {
    addRawEvent(
      TimelineEvent(
        name: name,
        screenshot: screenshot,
        initiator: _mostRelevantCaller(
          fallbackFrame: initiator ?? screenshot?.initiator,
        ),
        timestamp: DateTime.now(),
        treeSnapshot: currentWidgetTreeSnapshot(),
        eventType:
            eventType != null ? TimelineEventType(label: eventType) : null,
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
        : null;

    buffer.writeln('==================== Timeline Event ====================');
    if (event.eventType != null) {
      buffer.writeln('Event Type: ${event.eventType}');
    }
    buffer.writeln('Name: ${event.name}');
    if (caller != null) {
      buffer.writeln('Caller: $caller');
    }
    if (event.screenshot != null) {
      buffer.writeln('Screenshot: file://${event.screenshot!.file.path}');
    }
    buffer.writeln('Timestamp: ${event.timestamp.toIso8601String()}');
    buffer.writeln('========================================================');

    // ignore: avoid_print
    print(buffer);
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
    this.name,
    this.eventType,
    this.description,
    this.initiator,
    this.screenshot,
  });

  /// Creates a new timeline event with the current time and widget tree snapshot.
  factory TimelineEvent.now({
    Screenshot? screenshot,
    String? name,
    Frame? initiator,
    TimelineEventType? eventType,
  }) {
    return TimelineEvent(
      screenshot: screenshot,
      name: name,
      initiator: initiator,
      timestamp: DateTime.now(),
      treeSnapshot: currentWidgetTreeSnapshot(),
      eventType: eventType,
    );
  }

  /// The type of event that occurred.
  final TimelineEventType? eventType;

  /// The screenshot taken at the time of the event.
  final Screenshot? screenshot;

  /// The name of the event.
  final String? name;

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

/// Returns the test name including the group hierarchy.
String _testNameWithHierarchy() {
  final test = Invoker.current?.liveTest;
  if (test == null) {
    return 'No test found';
  }

  // Group names are concatenated with the name of the previous group
  final rawGroupNames = Invoker.current?.liveTest.groups
          .map((group) {
            if (group.name.isEmpty) {
              return null;
            }
            return group.name;
          })
          .nonNulls
          .toList() ??
      [];

  List<String> removeRedundantParts(List<String> inputList) {
    if (inputList.length < 2) {
      return inputList;
    }

    final List<String> outputList = [];
    for (int i = 0; i < inputList.length - 1; i++) {
      outputList.add(inputList[i]);
    }

    String lastElement = inputList.last;
    final String previousElement = inputList[inputList.length - 2];

    // Remove the part of the last element that is included in the previous one
    if (lastElement.startsWith(previousElement)) {
      lastElement = lastElement.substring(previousElement.length).trim();
    }

    if (lastElement.isNotEmpty) {
      outputList.add(lastElement);
    }

    return outputList;
  }

  final cleanedGroups = removeRedundantParts(rawGroupNames);
  if (cleanedGroups.isNotEmpty) {
    final joinedGroups = cleanedGroups.join(' ');

    final List<String> fullNameParts = [joinedGroups, test.test.name];
    final String finalTestName = removeRedundantParts(fullNameParts).last;
    final String groupHierarchy = cleanedGroups.join(' => ');
    return '$finalTestName in group(s): $groupHierarchy';
  } else {
    return test.test.name;
  }
}

Frame? _mostRelevantCaller({Frame? fallbackFrame}) {
  final frames = Trace.current().frames;

  final nonPackageFrames = frames.where((frame) => frame.package == null);

  final testFileCaller = nonPackageFrames.firstWhereOrNull((frame) {
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
