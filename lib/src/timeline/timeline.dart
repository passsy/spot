// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:spot/src/flutter/frame_clock.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
import 'package:spot/src/timeline/html/print_html.dart';
import 'package:spot/src/timeline/print_console.dart';
import 'package:spot/src/utils/ci.dart';
import 'package:spot/src/utils/invoker.dart';
import 'package:stack_trace/stack_trace.dart';

TimelineMode _globalTimelineMode =
    getTimelineModeFromEnv() ?? TimelineMode.reportOnError;

/// Returns the global timeline mode than can be used across multiple tests
TimelineMode get globalTimelineMode => _globalTimelineMode;

set globalTimelineMode(TimelineMode value) {
  // Setting the mode at the top of main() is spot's earliest possible use,
  // before any test ran. When it runs before the binding exists, the counting
  // starts at the next spot use instead.
  FrameClock.startCounting();
  final test = getLiveTest();
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

/// Frames drawn since the first timeline of this process was created.
///
/// [SchedulerBinding] keeps no frame counter and persistent frame callbacks
/// cannot be removed again, so one callback counts for the whole process and
/// every timeline reads a delta off it.
int _renderedFrames = 0;
bool _isCountingRenderedFrames = false;

void _startCountingRenderedFrames() {
  if (_isCountingRenderedFrames) {
    return;
  }
  _isCountingRenderedFrames = true;
  SchedulerBinding.instance.addPersistentFrameCallback((_) {
    _renderedFrames++;
  });
}

final Map<LiveTest, Timeline> _timelines = {};

/// Returns the current timeline for the test or creates a new one if
/// it doesn't exist.
Timeline get timeline {
  final LiveTest? test = getLiveTest();
  if (test == null) {
    throw StateError('timeline must be called within a test');
  }
  final timeline = _timelines[test];
  if (timeline != null) {
    // existing timeline
    return timeline;
  }

  // create new timeline
  // A timeline coming alive is spot in use, and the earliest moment a test
  // that sets timeline.mode before its first assertion shows it.
  FrameClock.startCounting();
  final newTimeline = _Timeline._(test);

  addTearDown(() async {
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
abstract interface class Timeline {
  /// The test that the timeline is associated with.
  LiveTest get test;

  /// The events that have recording during the test.
  List<TimelineEvent> get events;

  /// How many frames the test has rendered since the timeline started.
  ///
  /// Counts every frame, not just the ones an event was recorded in. It is a
  /// direct measure of what a test costs: a `pumpAndSettle` where a single
  /// `pump` would do shows up here as hundreds of frames.
  int get renderedFrameCount;

  /// The mode of the timeline. Defaults to [TimelineMode.reportOnError].
  TimelineMode get mode;

  set mode(TimelineMode value);

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
  });

  /// Removes a previously added event from the timeline.
  void removeEvent(TimelineEventId id);

  /// Allows updating an event with more information after it has been added.
  ///
  /// With this message assertions can be added and later updated when they
  /// failed with additional information about the error.
  void updateEvent({
    required TimelineEventId id,
    String? eventType,
    String? details,
    Screenshot? screenshot,
    Color? color,
    String? description,
  });

  /// Adds a function that processes a pending [Screenshot] to be processed at a later time (or never).
  ///
  /// To speed up processing, the screenshots are only processed when actually needed in a report (console or html).
  void addScreenshotProcessing(Future<void> Function() process);

  /// Adds a function that will be called after the test completed and the timeline has been rendered.
  ///
  /// Use it instead of `addTearDown` from `flutter_test` to ensure that the timeline is rendered before
  void addTearDown(FutureOr<void> Function() tearDown);
}

/// The actual implementation of the [Timeline].
final class _Timeline extends Timeline {
  _Timeline._(this.test) : _renderedFramesAtStart = _renderedFrames {
    _startCountingRenderedFrames();
    _startCapturingFlutterErrors();
  }

  /// Frames the process had already drawn when this timeline started.
  ///
  /// The counter runs for the whole process, this is what makes the numbers
  /// relative to this test.
  final int _renderedFramesAtStart;

  @override
  int get renderedFrameCount => _renderedFrames - _renderedFramesAtStart;

  /// The test that the timeline is associated with.
  @override
  final LiveTest test;

  /// The first error [FlutterError.onError] saw, which is the only place the
  /// exception that failed the test survives.
  ///
  /// By the time the timeline is rendered, `test.errors` holds nothing but
  /// 'Test failed. See exception logs above.' with an empty stack trace.
  /// flutter_test dumps the real exception to the console and reports that
  /// placeholder to the test framework in its place, so reading it back from
  /// the test is not an option.
  FlutterErrorDetails? _firstFlutterError;

  /// The widget tree as it stood the moment the test failed.
  ///
  /// Kept because the failure event is built during teardown, which is long
  /// after. Snapshots are per frame, so this doubles as the answer to whether
  /// anything has been drawn since, see [_screenStillShowsTheFailure].
  WidgetTreeSnapshot? _treeWhenTestFailed;
  FlutterExceptionHandler? _previousOnError;
  FlutterExceptionHandler? _installedOnError;

  void _startCapturingFlutterErrors() {
    _previousOnError = FlutterError.onError;
    _installedOnError = (details) {
      // The first error ends the test. Whatever follows is its fallout.
      if (_firstFlutterError == null) {
        _firstFlutterError = details;
        _treeWhenTestFailed = _currentTreeSnapshotOrNull();
      }
      _previousOnError?.call(details);
    };
    FlutterError.onError = _installedOnError;
  }

  /// Whether the screen still shows what it showed when the test failed.
  ///
  /// A snapshot is only valid for the frame it was taken in, so getting the
  /// same object back means no frame has been drawn since. Teardowns run after
  /// the failure and are free to pump frames of their own, so without this a
  /// capture taken now could be whatever a teardown left behind, presented as
  /// the failure.
  bool get _screenStillShowsTheFailure {
    final atFailure = _treeWhenTestFailed;
    return atFailure != null &&
        identical(_currentTreeSnapshotOrNull(), atFailure);
  }

  void _stopCapturingFlutterErrors() {
    // A widget test's binding puts its own handler back once the test is over.
    // A plain test has no binding doing that, so it is done here.
    if (identical(FlutterError.onError, _installedOnError)) {
      FlutterError.onError = _previousOnError;
    }
  }

  /// The events that have recording during the test.
  @override
  List<TimelineEvent> get events => List.unmodifiable(_events);
  final List<TimelineEvent> _events = [];
  WidgetTreeSnapshot? _lastEventTreeSnapshot;
  String? _currentFrameWidgetTree;
  final Map<(RenderObject?, Rect?), Map<String, dynamic>>
  _currentFrameStructuredTrees = {};
  int _currentFrameNumber = 0;

  TimelineMode _mode = _globalTimelineMode;

  /// The mode of the timeline. Defaults to [TimelineMode.reportOnError].
  @override
  TimelineMode get mode => _mode;

  @override
  set mode(TimelineMode value) {
    if (value == _mode) {
      return;
    }
    debugPrint(switch (value) {
      TimelineMode.live =>
        '🔴 - Live! Shows all timeline events as they happen',
      TimelineMode.always => '🔴 - Always shows the timeline',
      TimelineMode.reportOnError =>
        '🔴 - Shows the timeline when the test fails',
      // ignore: deprecated_member_use_from_same_package
      TimelineMode.record => '🔴 - Recording, but only showing on test failure',
      TimelineMode.off => '⏸︎ - Timeline recording is off',
    });

    _mode = value;
  }

  /// Adds an event to the timeline.
  ///
  /// Returns a unique identifier for the event which can be used to update
  /// its details later.
  @override
  TimelineEventId addEvent({
    required String details,
    required String eventType,
    Screenshot? screenshot,
    Frame? initiator,
    Color? color,
  }) {
    final id = TimelineEventId.random();
    final treeSnapshot = currentWidgetTreeSnapshot();
    if (!identical(treeSnapshot, _lastEventTreeSnapshot)) {
      _lastEventTreeSnapshot = treeSnapshot;
      _currentFrameNumber++;
      _currentFrameWidgetTree = treeSnapshot.toStringDeep();
      _currentFrameStructuredTrees.clear();
    }
    final widgetTree = _currentFrameWidgetTree ??= treeSnapshot.toStringDeep();
    final structuredTreeKey = (
      screenshot?.captureRenderObject,
      screenshot?.capturePaintBounds,
    );
    final structuredWidgetTree = _currentFrameStructuredTrees.putIfAbsent(
      structuredTreeKey,
      () => treeSnapshot.toStructuredData(
        captureRenderObject: screenshot?.captureRenderObject,
        capturePaintBounds: screenshot?.capturePaintBounds,
      ),
    );
    final event = TimelineEvent(
      id: id,
      frameNumber: _currentFrameNumber,
      renderedFrameNumber: renderedFrameCount,
      details: details,
      screenshot: screenshot,
      initiator: mostRelevantCaller(
        fallback: initiator ?? screenshot?.initiator,
      ),
      timestamp: clock.now(),
      // Deliberately not clock.now(). Inside fakeAsync that returns the
      // simulated time, which is what `timestamp` already is. This is the one
      // place that wants the time that actually passed.
      wallTime: DateTime.now(),
      color: color ?? Colors.white,
      treeSnapshot: treeSnapshot,
      widgetTree: widgetTree,
      structuredWidgetTree: structuredWidgetTree,
      eventType: TimelineEventType(label: eventType, color: color),
    );
    _addRawEvent(event);
    return id;
  }

  /// Removes a previously added event from the timeline.
  @override
  void removeEvent(TimelineEventId id) {
    final event = _events.firstOrNullWhere((event) => event.id == id);
    if (event == null) {
      throw StateError("Event with id '${id.value}' not found");
    }
    _events.remove(event);
  }

  @override
  void updateEvent({
    required TimelineEventId id,
    Object? eventType = _undefined,
    Object? details = _undefined,
    Object? screenshot = _undefined,
    Object? color = _undefined,
    Object? description = _undefined,
  }) {
    final event = _events.firstOrNullWhere((event) => event.id == id);
    if (event == null) {
      throw StateError("Event with id '${id.value}' not found");
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
    final updatedScreenshot = screenshot == _undefined
        ? event.screenshot
        : screenshot as Screenshot?;

    final updated = TimelineEvent(
      id: id,
      frameNumber: event.frameNumber,
      renderedFrameNumber: event.renderedFrameNumber,
      details: updatedDetails,
      eventType: updatedEventType,
      color: updatedColor,
      screenshot: updatedScreenshot,
      timestamp: event.timestamp,
      wallTime: event.wallTime,
      treeSnapshot: event.treeSnapshot,
      widgetTree: event.widgetTree,
      structuredWidgetTree: event.structuredWidgetTree,
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
  @override
  void addScreenshotProcessing(Future<void> Function() process) {
    _toBeProcessedScreenshots.add(process);
  }

  // ignore: avoid_futureor_void
  final List<FutureOr<void> Function()> _tearDowns = [];

  @override
  void addTearDown(FutureOr<void> Function() tearDown) {
    _tearDowns.add(tearDown);
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

  /// Records whatever failed the test as the final event of the timeline.
  ///
  /// Only spot's own assertions report their failure through [addEvent]. A
  /// plain `expect`, or anything else the test throws, never reaches the
  /// timeline, so without this the report ends at the last thing that worked
  /// and never shows what went wrong.
  ///
  /// The failure gets a frame of its own at the end. No frame is pumped
  /// between the last event and the failure, so it would otherwise be filed
  /// under the preceding frame and sit behind the assertions that passed.
  Future<void> _addTestFailureEvent() async {
    if (mode == TimelineMode.off || test.state.result.isPassing) {
      return;
    }
    final failure = _testFailure();
    if (failure == null) {
      return;
    }
    final lastEvent = _events.lastOrNull;
    // The tree the test failed on, rather than whatever teardown is looking at
    // by now.
    final treeSnapshot =
        _treeWhenTestFailed ??
        _currentTreeSnapshotOrNull() ??
        lastEvent?.treeSnapshot;
    if (treeSnapshot == null) {
      // A test that never built a widget has no frame to show the failure in,
      // and its report would be empty either way.
      return;
    }
    // Only capture what is on screen when it is still the failing frame. A
    // capture of something else under a 'Test Failed' heading is worse than no
    // capture at all.
    final screenshot = _screenStillShowsTheFailure
        ? await _failureScreenshot()
        : null;
    final trace = _relevantTrace(failure.stackTrace);

    _currentFrameNumber++;
    _addRawEvent(
      TimelineEvent(
        id: TimelineEventId.random(),
        frameNumber: _currentFrameNumber,
        renderedFrameNumber: renderedFrameCount,
        details: '${failure.error.toString().trimRight()}\n\n$trace',
        screenshot: screenshot,
        initiator: mostRelevantCaller(trace: trace),
        timestamp: clock.now(),
        // Deliberately not clock.now(), for the reason given in addEvent.
        wallTime: DateTime.now(),
        color: Colors.red,
        treeSnapshot: treeSnapshot,
        // The tree is usually the one the last event already stringified.
        widgetTree: identical(treeSnapshot, lastEvent?.treeSnapshot)
            ? lastEvent!.widgetTree
            : treeSnapshot.toStringDeep(),
        structuredWidgetTree: treeSnapshot.toStructuredData(
          captureRenderObject: screenshot?.captureRenderObject,
          capturePaintBounds: screenshot?.capturePaintBounds,
        ),
        eventType: const TimelineEventType(
          label: 'Test Failed',
          color: Colors.red,
        ),
      ),
    );
  }

  /// What failed the test, or `null` when nothing did.
  ///
  /// Prefers what [FlutterError.onError] saw, because that is the real
  /// exception with the stack trace pointing at the line that threw it. The
  /// test's own error is the fallback for failures that never went through
  /// Flutter, such as one thrown from a plain `test`.
  AsyncError? _testFailure() {
    final flutterError = _firstFlutterError;
    if (flutterError != null) {
      return AsyncError(
        flutterError.exception,
        flutterError.stack ?? StackTrace.empty,
      );
    }
    return test.errors.firstOrNull;
  }

  /// The widget tree as it stands right now, or `null` when there is none.
  ///
  /// Reaching the tree force-unwraps the root element, which a test that never
  /// pumped a widget does not have.
  WidgetTreeSnapshot? _currentTreeSnapshotOrNull() {
    try {
      return currentWidgetTreeSnapshot();
      // Converted to a value right here, so the stack trace has nothing to add.
      // ignore: avoid_catching_errors
    } on Error {
      return null;
    }
  }

  /// A capture of the screen as the failing test left it, or `null` when one
  /// cannot be taken anymore.
  Future<Screenshot?> _failureScreenshot() async {
    try {
      return await takeScreenshot(name: 'test-failure', print: false);
      // Converted to a value right here, so the stack trace has nothing to add.
      // ignore: avoid_catching_errors
    } catch (_) {
      return null;
    }
  }

  /// Event handler after the [test] has completed.
  ///
  /// Prints the timeline to console, as link to a html file or plain text
  Future<void> _onPostTest() async {
    _stopCapturingFlutterErrors();
    await _addTestFailureEvent();
    await _renderTimeline();
    for (final tearDown in _tearDowns.toList()) {
      await tearDown();
      _tearDowns.remove(tearDown);
    }
  }

  Future<void> _renderTimeline() async {
    Future<void> reportOnError() async {
      if (test.state.result.isPassing) {
        _discardPreviousReport();
        return;
      }
      debugPrint('Test failed, generating timeline report');
      if (!kIsWeb) {
        await processPendingScreenshots();
      }
      if (isCI) {
        // best for CI, prints the full timeline and doesn't require archiving the html timeline file
        printToConsole();
      }
      // best for humans
      if (!kIsWeb) {
        await printHTML();
      }
    }

    switch (mode) {
      case TimelineMode.live:
        // during live mode the events are written directly to the console.
        // Finalize with html report
        if (!kIsWeb) {
          await processPendingScreenshots();
          await printHTML();
        }
      case TimelineMode.always:
        debugPrint('Generating timeline report');
        if (!kIsWeb) {
          await processPendingScreenshots();
        }
        if (isCI) {
          // best for CI, prints the full timeline and doesn't require archiving the html timeline file
          printToConsole();
        }
        // best for humans
        if (!kIsWeb) {
          await printHTML();
        }
      // ignore: deprecated_member_use_from_same_package
      case TimelineMode.record:
        await reportOnError();
      case TimelineMode.reportOnError:
        await reportOnError();
      case TimelineMode.off:
        _discardPreviousReport();
    }
  }

  /// Removes the report an earlier run of this test wrote.
  ///
  /// This run has nothing to show, and leaving the old report in place makes
  /// the link printed back then keep working while showing the source and the
  /// events of a run that no longer exists.
  void _discardPreviousReport() {
    if (kIsWeb) {
      return;
    }
    deleteHtmlReport();
  }
}

/// The type of event that occurred during a test.
class TimelineEventType {
  /// The name of the event.
  final String label;

  /// The color of the event currently used as border in the html export but that can change
  final Color? color;

  /// Creates a new timeline event type.
  const TimelineEventType({required this.label, this.color});

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
    required this.frameNumber,
    required this.renderedFrameNumber,
    required this.timestamp,
    required this.wallTime,
    required this.treeSnapshot,
    required this.widgetTree,
    required this.structuredWidgetTree,
    required this.details,
    required this.eventType,
    this.initiator,
    this.screenshot,
    required this.color,
  });

  /// The unique identifier of the event used to update the event later.
  final TimelineEventId id;

  /// The rendered frame this event belongs to.
  ///
  /// Multiple assertions can occur without pumping another frame. Those
  /// events share this number and therefore share one capture in reports.
  ///
  /// It counts the frames events were recorded in, not the frames the test
  /// rendered. See [renderedFrameNumber] for that.
  final int frameNumber;

  /// How many frames the test had rendered when this event was recorded.
  ///
  /// Unlike [frameNumber] this counts every frame, so the distance between two
  /// events says how much rendering happened in between.
  final int renderedFrameNumber;

  /// The type of event that occurred.
  final TimelineEventType eventType;

  /// The screenshot taken at the time of the event.
  final Screenshot? screenshot;

  /// The details of the event.
  final String details;

  /// The time at which the event occurred, on the test's clock.
  ///
  /// Widget tests run inside `fakeAsync`, so this is simulated time: it jumps
  /// by whatever a `pump(duration)` was given and stands still during work that
  /// does not await a timer. Use it to reason about what the test asked for.
  /// See [wallTime] for the time that actually passed.
  final DateTime timestamp;

  /// The time at which the event occurred, on the wall clock.
  ///
  /// Real time, unaffected by `fakeAsync`. Use it to reason about how long
  /// something really took, which [timestamp] cannot answer.
  final DateTime wallTime;

  /// The widget tree snapshot at the time of the event.
  final WidgetTreeSnapshot treeSnapshot;

  /// A serializable diagnostic representation of [treeSnapshot].
  ///
  /// The underlying snapshot references live Flutter elements, so this string
  /// is captured with the event while those elements still represent the
  /// intended frame.
  final String widgetTree;

  /// Structured widget data and optional screenshot-relative layout bounds.
  final Map<String, dynamic> structuredWidgetTree;

  /// The frame that initiated the event.
  final Frame? initiator;

  /// The color of the event.
  final Color color;

  @override
  String toString() {
    return 'TimelineEvent{id: $id, frameNumber: $frameNumber, eventType: $eventType, screenshot: $screenshot, details: $details, timestamp: $timestamp, treeSnapshot: $treeSnapshot, initiator: $initiator, color: $color}';
  }
}

/// A unique identifier for a [TimelineEvent].
class TimelineEventId {
  /// Creates a fixed id for a [TimelineEvent].
  const TimelineEventId(this.value);

  /// Creates a new unique id for a [TimelineEvent].
  TimelineEventId.random() : value = nanoid();

  /// The actual value of the id.
  final String value;

  @override
  String toString() {
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineEventId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
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
  off,
}

/// Packages that are never the reason a test failed.
const Set<String> _frameworkPackages = {
  'clock',
  'fake_async',
  'flutter',
  'flutter_test',
  'matcher',
  'spot',
  'stack_trace',
  'stream_channel',
  'test_api',
  'test_core',
};

bool _isFrameworkFrame(Frame frame) =>
    frame.isCore || _frameworkPackages.contains(frame.package);

/// The frames of [stackTrace] that belong to the code under test.
///
/// A failure inside Flutter is reached through a dozen frames of gesture
/// arenas, fake async and the test runner, and every async gap repeats them.
/// Dropping them leaves the path through the test and the app, which is the
/// part worth reading. The console still gets the full trace.
///
/// Falls back to the folded stack when the failure happened entirely inside a
/// package and nothing would be left otherwise.
Trace _relevantTrace(StackTrace stackTrace) {
  final full = Chain.forTrace(stackTrace).toTrace();
  final ownFrames = <Frame>[];
  final seen = <String>{};
  for (final frame in full.frames) {
    if (_isFrameworkFrame(frame)) {
      continue;
    }
    if (seen.add(frame.toString())) {
      ownFrames.add(frame);
    }
  }
  if (ownFrames.isEmpty) {
    return full.foldFrames(_isFrameworkFrame, terse: true);
  }
  return Trace(ownFrames);
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
