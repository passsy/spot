import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/live_test.dart';

final Map<LiveTest, Timeline> _timelines = {};

void liveTimeline() {
  print('🔴 Live timeline recording');
  final timeline = currentTimeline();
  timeline.mode = TimelineMode.live;
}

void printTimelineOnError() {
  print('🔴 timeline recording in case of error');
  final timeline = currentTimeline();
  timeline.mode = TimelineMode.record;
}

void stopTimeline() {
  print('Timeline recording is disabled');
  final timeline = currentTimeline();
  timeline.mode = TimelineMode.off;
}

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

class Timeline {
  final List<TimelineEvent> _events = [];

  TimelineMode mode = TimelineMode.off;

  void addScreenshot(Screenshot screenshot, {String? name}) {
    addEvent(TimelineEvent(
      name: name,
      screenshot: screenshot,
      timestamp: DateTime.now(),
      treeSnapshot: currentWidgetTreeSnapshot(),
      initiator: screenshot.initiator,
    ));
  }

  void addEvent(TimelineEvent event) {
    _events.add(event);
    if (mode == TimelineMode.live) {
      _printEvent(event);
    }
  }

  void printToConsole() {
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

    print(buffer);
  }
}

class TimelineEvent {
  final Screenshot? screenshot;
  final String? name;
  final DateTime timestamp;
  final WidgetTreeSnapshot treeSnapshot;
  final Frame? initiator;

  const TimelineEvent({
    this.screenshot,
    this.name,
    this.initiator,
    required this.timestamp,
    required this.treeSnapshot,
  });
}

enum TimelineMode {
  live,
  record,
  off,
}
