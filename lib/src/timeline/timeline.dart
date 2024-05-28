// ignore_for_file: depend_on_referenced_packages
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

final Map<LiveTest, Timeline> _timelines = {};

/// Records the timeline and prints events as they happen.
void recordLiveTimeline() {
  final timeline = currentTimeline();
  final isRecordingLive = timeline.mode == TimelineMode.live;
  final message = isRecordingLive ? 'Already recording' : 'Now recording';
  // ignore: avoid_print
  print('🔴 - $message live timeline');
  timeline.mode = TimelineMode.live;
}

/// Records the timeline but only prints it in case of an error.
void recordOnErrorTimeline() {
  final timeline = currentTimeline();
  final isRecordingError = timeline.mode == TimelineMode.record;
  final message = isRecordingError ? 'Already' : 'Now';
  // ignore: avoid_print
  print('🔴 - $message recording error output timeline');
  timeline.mode = TimelineMode.record;
}

/// Stops the timeline from recording.
void stopRecordingTimeline() {
  final timeline = currentTimeline();
  final isRecording = timeline.mode != TimelineMode.off;
  final message = isRecording ? 'stopped' : 'is off';
  // ignore: avoid_print
  print('⏸︎ - Timeline recording $message');
  timeline.mode = TimelineMode.off;
}

/// Returns the current timeline for the test or creates a new one if
/// it doesn't exist.
Timeline currentTimeline() {
  final test = Invoker.current?.liveTest;
  if (test == null) {
    throw StateError('currentTimeline() must be called within a test');
  }
  final timeline = _timelines[test];
  if (timeline != null) {
    // existing timeline
    return timeline;
  }

  // create new timeline
  final newTimeline = Timeline();

  Invoker.current!.addTearDown(() {
    if (newTimeline.mode == TimelineMode.record &&
        !test.state.result.isPassing) {
      newTimeline.printToConsole();
    }
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
  void addScreenshot(Screenshot screenshot, {String? name}) {
    addEvent(
      TimelineEvent.now(
        name: name,
        screenshot: screenshot,
        initiator: screenshot.initiator,
      ),
    );
  }

  /// Adds an event to the timeline.
  void addEvent(TimelineEvent event) {
    if (mode == TimelineMode.off) {
      return;
    }
    _events.add(event);
    if (mode == TimelineMode.live) {
      _printEvent(event);
    }
  }

  /// Prints the timeline to the console.
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

    buffer.write('${event.name}');
    if (caller != null) {
      buffer.write(' $caller');
    }

    if (event.screenshot != null) {
      buffer.write('\nScreenshot: file://${event.screenshot!.file.path}');
    }
// ignore: avoid_print
    print(buffer);
  }
}

/// An event that occurred during a test.
class TimelineEvent {
  /// Creates a new timeline event.
  const TimelineEvent({
    this.screenshot,
    this.name,
    this.initiator,
    required this.timestamp,
    required this.treeSnapshot,
  });

  /// Creates a new timeline event with the current time and widget tree snapshot.
  factory TimelineEvent.now({
    Screenshot? screenshot,
    String? name,
    Frame? initiator,
  }) {
    return TimelineEvent(
      screenshot: screenshot,
      name: name,
      initiator: initiator,
      timestamp: DateTime.now(),
      treeSnapshot: currentWidgetTreeSnapshot(),
    );
  }

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
