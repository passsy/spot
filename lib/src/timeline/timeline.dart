// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:nanoid2/nanoid2.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

import 'package:path/path.dart' as path;

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

    createTimelineHtmlFile(_events);
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




/// Creates


void createTimelineHtmlFile(List<TimelineEvent> events) {
  final htmlBuffer = StringBuffer();

  htmlBuffer.writeln('<html>');
  htmlBuffer.writeln('<head>');
  htmlBuffer.writeln('<title>Timeline Events</title>');
  htmlBuffer.writeln(
      '<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">',);
  htmlBuffer.writeln('<style>');
  htmlBuffer.writeln('body {');
  htmlBuffer.writeln('  box-sizing: border-box;');
  htmlBuffer.writeln('  background-color: #F0FCFF;');
  htmlBuffer.writeln('  color: #4a4a4a;');
  htmlBuffer.writeln('  overflow-wrap: anywhere;');
  htmlBuffer.writeln(
      '  font-family: "Google Sans Text","Google Sans","Roboto",sans-serif;',);
  htmlBuffer.writeln('  -webkit-font-smoothing: antialiased;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln(
      '.header { display: flex; align-items: center; padding: 10px; }',);
  htmlBuffer.writeln('h1 {');
  htmlBuffer.writeln('  color: #4a4a4a;');
  htmlBuffer.writeln('  overflow-wrap: anywhere;');
  htmlBuffer.writeln('  -webkit-font-smoothing: antialiased;');
  htmlBuffer.writeln('  font-variant-ligatures: none;');
  htmlBuffer.writeln('  font-feature-settings: "liga" 0;');
  htmlBuffer.writeln('  box-sizing: border-box;');
  htmlBuffer.writeln('  font-weight: 400;');
  htmlBuffer.writeln(
      '  font-family: "Google Sans Display","Google Sans","Roboto",sans-serif;',);
  htmlBuffer.writeln('  margin: 0;');
  htmlBuffer.writeln('  font-size: 36px;');
  htmlBuffer.writeln('  padding-left: 10px;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.event {');
  htmlBuffer.writeln('  display: flex;'); // Make event a flex container
  htmlBuffer.writeln('  border: 2px solid #557783;');
  htmlBuffer.writeln('  margin: 10px;');
  htmlBuffer.writeln('  padding: 10px;');
  htmlBuffer.writeln('  background-color: #ffffff;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.event-details {');
  htmlBuffer.writeln('  margin-left: 20px;'); // Add some margin to the details
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.thumbnail {');
  htmlBuffer.writeln('  max-width: 150px;');
  htmlBuffer.writeln('  height: auto;');
  htmlBuffer.writeln('  cursor: pointer;');
  htmlBuffer.writeln('  border: 1px solid #557783;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.modal {');
  htmlBuffer.writeln('  display: none;');
  htmlBuffer.writeln('  position: fixed;');
  htmlBuffer.writeln('  z-index: 1;');
  htmlBuffer.writeln('  padding-top: 60px;');
  htmlBuffer.writeln('  left: 0;');
  htmlBuffer.writeln('  top: 0;');
  htmlBuffer.writeln('  width: 100%;');
  htmlBuffer.writeln('  height: 100%;');
  htmlBuffer.writeln('  overflow: auto;');
  htmlBuffer.writeln('  background-color: rgba(0,0,0,0.9);');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.modal-content {');
  htmlBuffer.writeln('  margin: auto;');
  htmlBuffer.writeln('  display: block;');
 // htmlBuffer.writeln('  height: 80%;');
  htmlBuffer.writeln('  max-width: 1200px;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.close {');
  htmlBuffer.writeln('  position: absolute;');
  htmlBuffer.writeln('  top: 15px;');
  htmlBuffer.writeln('  right: 35px;');
  htmlBuffer.writeln('  color: #f1f1f1;');
  htmlBuffer.writeln('  font-size: 40px;');
  htmlBuffer.writeln('  font-weight: bold;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.close:hover, .close:focus {');
  htmlBuffer.writeln('  color: #C97B2D;');
  htmlBuffer.writeln('  text-decoration: none;');
  htmlBuffer.writeln('  cursor: pointer;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.nav {');
  htmlBuffer.writeln('  padding: 10px;');
  htmlBuffer.writeln('  color: white;');
  htmlBuffer.writeln('  font-weight: bold;');
  htmlBuffer.writeln('  font-size: 30px;');
  htmlBuffer.writeln('  cursor: pointer;');
  htmlBuffer.writeln('  user-select: none;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.nav:hover {');
  htmlBuffer.writeln('  color: #C97B2D;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('.nav-left { left: 50%; }');
  htmlBuffer.writeln('.nav-right { right: 50%; }');
  htmlBuffer.writeln('#caption {');
  htmlBuffer.writeln('  margin: auto;');
  htmlBuffer.writeln('  display: flex;');
  htmlBuffer.writeln('  align-items: center;');
  htmlBuffer.writeln('  justify-content: space-between;');
  htmlBuffer.writeln('  width: 80%;');
  htmlBuffer.writeln('  max-width: 1200px;');
 // htmlBuffer.writeln('  max-width: 700px;');
  htmlBuffer.writeln('  text-align: center;');
  htmlBuffer.writeln('  color: #ccc;');
  htmlBuffer.writeln('  padding: 10px 0;');
  htmlBuffer.writeln('  height: 150px;');
  htmlBuffer.writeln('}');
  // htmlBuffer.writeln(
  //     '#caption .text { flex: 1; padding: 0 20px; }'); // Add padding between text and arrows
  htmlBuffer.writeln('</style>');
  htmlBuffer.writeln('<script>');
  htmlBuffer.writeln('let currentIndex = 0;');
  htmlBuffer.writeln('const events = [');
  for (int i = 0; i < events.length; i++) {
    if (events[i].screenshot != null) {
      htmlBuffer.writeln('  {src: "file://${events[i].screenshot!.file
          .path}", title: "Event ${i + 1}"},');
    }
  }
  htmlBuffer.writeln('];');
  htmlBuffer.writeln('function openModal(index) {');
  htmlBuffer.writeln('  currentIndex = index;');
  htmlBuffer.writeln('  var modal = document.getElementById("myModal");');
  htmlBuffer.writeln('  var modalImg = document.getElementById("img01");');
  htmlBuffer.writeln(
      '  var captionText = document.getElementById("captionText");',);
  htmlBuffer.writeln('  modal.style.display = "block";');
  htmlBuffer.writeln('  modalImg.src = events[index].src;');
  htmlBuffer.writeln('  captionText.innerHTML = events[index].title;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('function closeModal() {');
  htmlBuffer.writeln('  var modal = document.getElementById("myModal");');
  htmlBuffer.writeln('  modal.style.display = "none";');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('function showPrev() {');
  htmlBuffer.writeln(
      '  currentIndex = (currentIndex + events.length - 1) % events.length;',);
  htmlBuffer.writeln('  updateModal();');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('function showNext() {');
  htmlBuffer.writeln('  currentIndex = (currentIndex + 1) % events.length;');
  htmlBuffer.writeln('  updateModal();');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('function updateModal() {');
  htmlBuffer.writeln('  var modalImg = document.getElementById("img01");');
  htmlBuffer.writeln(
      '  var captionText = document.getElementById("captionText");',);
  htmlBuffer.writeln('  modalImg.src = events[currentIndex].src;');
  htmlBuffer.writeln('  captionText.innerHTML = events[currentIndex].title;');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('window.onclick = function(event) {');
  htmlBuffer.writeln('  var modal = document.getElementById("myModal");');
  htmlBuffer.writeln('  if (event.target == modal) {');
  htmlBuffer.writeln('    modal.style.display = "none";');
  htmlBuffer.writeln('  }');
  htmlBuffer.writeln('}');
  htmlBuffer.writeln('</script>');
  htmlBuffer.writeln('</head>');
  htmlBuffer.writeln('<body>');
  htmlBuffer.writeln('<div class="header">');
  htmlBuffer.writeln(
      '<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">',);
  htmlBuffer.writeln('<h1>Timeline Events</h1>');
  htmlBuffer.writeln('</div>');

  for (int i = 0; i < events.length; i++) {
    final event = events[i];
    final caller = event.initiator != null
        ? 'at ${event.initiator!.member} ${event.initiator!.uri}:${event
        .initiator!.line}:${event.initiator!.column}'
        : 'N/A';
    htmlBuffer.writeln('<h2>#${i + 1}</h2>');
    htmlBuffer.writeln('<div class="event">');
    if (event.screenshot != null) {
      final screenshotPath = event.screenshot!.file.path;
      htmlBuffer.writeln(
          '<img src="file://$screenshotPath" class="thumbnail" alt="Screenshot" onclick="openModal($i)">',);
    }
    htmlBuffer.writeln('<div class="event-details">');
    htmlBuffer.writeln(
        '<p><strong>Name:</strong> ${event.name ?? "Unnamed Event"}</p>',);
    htmlBuffer.writeln('<p><strong>Timestamp:</strong> ${event.timestamp
        .toIso8601String()}</p>');
    htmlBuffer.writeln('<p><strong>Caller:</strong> $caller</p>');
    htmlBuffer.writeln('</div>');
    htmlBuffer.writeln('</div>');
  }

  htmlBuffer.writeln('<div id="myModal" class="modal">');
  htmlBuffer.writeln(
      '<span class="close" onclick="closeModal()">&times;</span>',);
  htmlBuffer.writeln('<img class="modal-content" id="img01">');
  htmlBuffer.writeln('<div id="caption">');
  htmlBuffer.writeln(
      '<a class="nav nav-left" onclick="showPrev()">&#10094;</a>',);
  htmlBuffer.writeln(
      '<div id="captionText" class="text"></div>',); // Add text div
  htmlBuffer.writeln(
      '<a class="nav nav-right" onclick="showNext()">&#10095;</a>',);
  htmlBuffer.writeln('</div>');
  htmlBuffer.writeln('</div>');

  htmlBuffer.writeln('</body>');
  htmlBuffer.writeln('</html>');

  final tempDir = Directory.systemTemp.createTempSync();
  final htmlFile = File(path.join(tempDir.path, 'timeline_events.html'));
  htmlFile.writeAsStringSync(htmlBuffer.toString());

// Printing the file URL to console
  print('HTML file created: file://${htmlFile.path}');
}


// htmlBuffer.writeln('</body>');
// htmlBuffer.writeln('</html>');
//
// final spotTempDir = Directory.systemTemp.createTempSync();
// if (!spotTempDir.existsSync()) {
// spotTempDir.createSync();
// }
// // always append a unique id to avoid name collisions
// final uniqueId = nanoid(length: 5);
//
// final htmlFile = File(path.join(spotTempDir.path, 'timeline_events_$uniqueId.html'));