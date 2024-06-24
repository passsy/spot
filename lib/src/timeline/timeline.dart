// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:spot/src/timeline/script.js.dart';
import 'package:spot/src/timeline/styles.css.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

/// Records the timeline and prints events as they happen.
void recordLiveTimeline() {
  final isRecordingLive = timeline.mode == TimelineMode.live;
  final message = isRecordingLive ? 'Already recording' : 'Now recording';
  // ignore: avoid_print
  print('🔴 - $message live timeline');
  timeline.mode = TimelineMode.live;
}

/// Records the timeline but only prints it in case of an error.
void recordOnErrorTimeline() {
  final isRecordingError = timeline.mode == TimelineMode.record;
  final message = isRecordingError ? 'Already' : 'Now';
  // ignore: avoid_print
  print('🔴 - $message recording error output timeline');
  timeline.mode = TimelineMode.record;
}

/// Stops the timeline from recording.
void stopRecordingTimeline() {
  final isRecording = timeline.mode != TimelineMode.off;
  final message = isRecording ? 'stopped' : 'is off';
  // ignore: avoid_print
  print('⏸︎ - Timeline recording $message');
  timeline.mode = TimelineMode.off;
}

/// Use to set the timeline mode for all tests in a test file.
///
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
TimelineMode globalTimelineMode =
    getTimelineModeFromEnv() ?? TimelineMode.record;

/// Use --dart-define=SPOT_TIMELINE_MODE=live|record|off to set the [TimlineMode]
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
  newTimeline.mode = globalTimelineMode;

  Invoker.current!.addTearDown(() {
    if (!test.state.result.isPassing &&
        newTimeline.mode == TimelineMode.record) {
      newTimeline.printToConsole();
      newTimeline._printHTML();
    } else if (newTimeline.mode == TimelineMode.live) {
      // printToConsole() here would lead to duplicate output since
      // the timeline is already being printed live
      newTimeline._printHTML();
    }
    _timelines.remove(test);
  });

  _timelines[test] = newTimeline;
  return newTimeline;
}

/// Records a timeline of events during a test.
///
/// Usage:
/// ```dart
/// testWidgets('Live timeline', (tester) async {
///   recordOnErrorTimeline(); // start recording the timeline, output on Error
///   recordLiveTimeline(); // start recording the timeline with live output
///   await tester.pumpWidget(const IncrementCounter());
///   spotText('Counter: 0').existsOnce();
///   final addButton = spotIcon(Icons.add)..existsOnce();
///   await act.tap(addButton);
///   spotText('Counter: 1').existsOnce();
///   stopRecordingTimeline(); // stops recording the timeline
/// });
/// ```
class Timeline {
  final List<TimelineEvent> _events = [];

  /// The mode of the timeline. Defaults to [TimelineMode.off].
  TimelineMode mode = TimelineMode.off;

  /// Adds a screenshot to the timeline.
  void addScreenshot(
    Screenshot screenshot, {
    String? name,
    TimelineEventType? eventType,
  }) {
    _addEvent(
      TimelineEvent.now(
        name: name,
        screenshot: screenshot,
        initiator: screenshot.initiator,
        eventType: eventType,
      ),
    );
  }

  /// Adds an event to the timeline.
  void _addEvent(TimelineEvent event) {
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

  /// Prints the timeline as an HTML file.
  void _printHTML() {
    final spotTempDir = Directory.systemTemp.createTempSync();
    String name = Invoker.current?.liveTest.test.name ?? '';
    if (name.isEmpty) {
      name = 'Unnamed test';
    }
    if (!spotTempDir.existsSync()) {
      spotTempDir.createSync();
    }

    final String nameForHtml = () {
      String name = Invoker.current?.liveTest.test.name ?? '';

      if (name.isEmpty) {
        name = 'Unnamed test';
      }

      // Replace spaces and underscores with hyphens
      name = name.replaceAll(RegExp('[ _]'), '-');

      // Remove problematic characters
      name = name.replaceAll(RegExp('[^a-zA-Z0-9-]'), '');

      // Collapse multiple hyphens into a single hyphen
      name = name.replaceAll(RegExp('-+'), '-');

      // Convert to lowercase
      name = name.toLowerCase();

      // Remove leading or trailing hyphens
      name = name.replaceAll(RegExp(r'^-+|-+$'), '');

      // Append .html extension
      return 'timeline-$name.html';
    }();

    final htmlFile = File(path.join(spotTempDir.path, nameForHtml));
    final content = _timelineAsHTML();
    htmlFile.writeAsStringSync(content);
    //ignore: avoid_print
    print('View time line here: file://${htmlFile.path}');
  }

  void _printEvent(TimelineEvent event) {
    final StringBuffer buffer = StringBuffer();
    final frame = event.initiator;
    final caller = frame != null
        ? 'at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : null;

    buffer.writeln('==================== Timeline Event ====================');
    buffer.writeln('Event: ${event.name}');
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

  /// Returns the events in the timeline as an HTML string.
  String _timelineAsHTML() {
    final htmlBuffer = StringBuffer();
    final nameWithHierarchy = _testNameWithHierarchy();

    htmlBuffer.writeln('<html>');
    htmlBuffer.writeln('<head>');
    htmlBuffer.writeln('<title>Timeline Events</title>');
    htmlBuffer.writeln(
      '<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">',
    );

    final String eventsForScript =
        _events.where((event) => event.screenshot != null).map((event) {
      return '{src: "file://${event.screenshot!.file.path}", title: "${event.eventType?.label ?? "Event ${_events.indexOf(event) + 1}"}"}';
    }).join(',\n  ');

    htmlBuffer.writeln('<script>');
    final script = timelineJS
        .replaceAll('{{events}}', eventsForScript)
        .replaceAll('{testName}', Invoker.current!.liveTest.test.name);
    htmlBuffer.write(script);
    htmlBuffer.writeln('</script>');

    htmlBuffer.writeln('<style>');
    htmlBuffer.write(timelineCSS);
    htmlBuffer.writeln('</style>');

    htmlBuffer.writeln('</head>');
    htmlBuffer.writeln('<body>');
    htmlBuffer.writeln('<div class="header">');
    htmlBuffer.writeln(
      '<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">',
    );
    htmlBuffer.writeln('<h1>Timeline</h1>');
    htmlBuffer.writeln('</div>');

    htmlBuffer.writeln('<div class = "horizontal-spacer"><h2>Info</h2></div>');

    htmlBuffer.writeln('<p><strong>Test:</strong> $nameWithHierarchy</p>');
    htmlBuffer.writeln(
      '<button class="button-spot" onclick="copyTestCommandToClipboard()">Copy test command</button>',
    );
    htmlBuffer.writeln('<div id="snackbar"></div>');

    if (_events.isNotEmpty) {
      htmlBuffer
          .writeln('<div class = "horizontal-spacer"><h2>Events</h2></div>');
    }

    final events = () {
      final eventBuffer = StringBuffer();
      for (final event in _events) {
        final part = () {
          final index = _events.indexOf(event);
          final caller = event.initiator != null
              ? 'at ${event.initiator!.member} ${event.initiator!.uri}:${event.initiator!.line}:${event.initiator!.column}'
              : 'N/A';
          final type = event.eventType != null
              ? event.eventType!.label
              : "Unknown event type";
          final screenshot = event.screenshot != null
              ? '<img src="file://${event.screenshot!.file.path}" class="thumbnail" alt="Screenshot" onclick="openModal($index)">'
              : '';

          return '''
<h2>#${index + 1}</h2>
<div class="event">
  $screenshot
  <div class="event-details">
    <p><strong>Name:</strong> ${event.name ?? "Unnamed Event"}</p>
    <p><strong>Event Type:</strong> $type</p>
    <p><strong>Timestamp:</strong> ${event.timestamp.toIso8601String()}</p>
    <p><strong>Caller:</strong> $caller</p>
  </div>
</div>
''';
        }();
        eventBuffer.write(part);
      }
      return eventBuffer.toString();
    }();

    htmlBuffer.write(events);

    htmlBuffer.writeln('<div id="myModal" class="modal">');
    htmlBuffer
        .writeln('<span class="close" onclick="closeModal()">&times;</span>');
    htmlBuffer.writeln('<div class="modal-content">');
    htmlBuffer.writeln('<img id="img01" alt="Screenshot of the Event"/>');
    htmlBuffer.writeln('<div id="caption">');
    htmlBuffer
        .writeln('<a class="nav nav-left" onclick="showPrev()">&#10094;</a>');
    htmlBuffer.writeln('<div id="captionText"></div>');
    htmlBuffer
        .writeln('<a class="nav nav-right" onclick="showNext()">&#10095;</a>');
    htmlBuffer.writeln('</div>'); // close caption
    htmlBuffer.writeln('</div>'); // close modal-content
    htmlBuffer.writeln('</div>'); // close modal
    htmlBuffer.writeln('</body>');
    htmlBuffer.writeln('</html>');

    return htmlBuffer.toString();
  }
}

/// The type of event that occurred during a test.
enum TimelineEventType {
  /// A tap event.
  tap(
    'Tap Event (crosshair indicator)',
  ),

  /// A drag event.
  drag(
    'Drag Event (crosshair indicator)',
  );

  const TimelineEventType(this.label);

  /// The name of the event.
  final String label;
}

/// An event that occurred during a test.
class TimelineEvent {
  /// Creates a new timeline event.
  const TimelineEvent({
    this.screenshot,
    this.name,
    this.initiator,
    this.eventType,
    required this.timestamp,
    required this.treeSnapshot,
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
  off,
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
          .whereNotNull()
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
