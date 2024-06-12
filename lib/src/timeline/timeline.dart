// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:path/path.dart' as path;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/spot/tree_snapshot.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';


final Map<LiveTest, Timeline> _timelines = {};

/// Returns the test name including the group hierarchy.
String testNameWithHierarchy() {
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
      .toList() ?? [];

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
  void addScreenshot(Screenshot screenshot, {String? name, TimelineEventType? eventType,}) {
    addEvent(
      TimelineEvent.now(
        name: name,
        screenshot: screenshot,
        initiator: screenshot.initiator,
        eventType: eventType,
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
    _printHTML();
  }

  void _printHTML() {
    final spotTempDir = Directory.systemTemp.createTempSync();
    if (!spotTempDir.existsSync()) {
      spotTempDir.createSync();
    }
    // always append a unique id to avoid name collisions
    final uniqueId = nanoid(length: 5);
    final htmlFile = File(path.join(spotTempDir.path, 'timeline_events_$uniqueId.html'));
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
  String _timelineAsHTML(){
    final htmlBuffer = StringBuffer();
    final nameWithHierarchy = testNameWithHierarchy();
    const style = '''
<style>
body {
  box-sizing: border-box;
  background-color: #F0FCFF;
  color: #4a4a4a;
  overflow-wrap: anywhere;
  font-family: "Google Sans Text","Google Sans","Roboto",sans-serif;
  -webkit-font-smoothing: antialiased;
}
.header { 
  display: flex; 
  align-items: center; 
  padding: 10px; 
}
h1 {
  color: #4a4a4a;
  overflow-wrap: anywhere;
  -webkit-font-smoothing: antialiased;
  font-variant-ligatures: none;
  font-feature-settings: "liga" 0;
  box-sizing: border-box;
  font-weight: 400;
  font-family: "Google Sans Display","Google Sans","Roboto",sans-serif;
  margin: 0;
  font-size: 36px;
  padding-left: 10px;
}
.event {
  display: flex;
  border: 2px solid #557783;
  margin: 10px;
  padding: 10px;
  background-color: #ffffff;
}
.event-details {
  margin-left: 20px;
}
.thumbnail {
  height: 150px;
  cursor: pointer;
  border: 1px solid #557783;
  object-fit: contain;
}
.modal {
  display: none;
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgba(0,0,0,0.9);
}
.modal-content {
  margin: auto;
  display: block;
  max-width: 80%;
  height: auto;
}
.close {
  position: absolute;
  top: 15px;
  right: 35px;
  color: #f1f1f1;
  font-size: 40px;
  font-weight: bold;
}
.close:hover, .close:focus {
  color: #C97B2D;
  text-decoration: none;
  cursor: pointer;
}
.nav {
  padding: 10px;
  color: white;
  font-weight: bold;
  font-size: 30px;
  cursor: pointer;
  user-select: none;
}
.nav:hover {
  color: #C97B2D;
}
.nav-left {
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
}
.nav-right {
  position: absolute;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
}
#caption {
  text-align: center;
  color: #ccc;
  padding: 10px 0;
  height: 150px;
}
.horizontal-spacer {
  border-bottom: 1px solid #C97B2D;
  padding-top: 25px;
}
.horizontal-spacer h2 {
  margin: 0;
  padding: 0;
}
</style>
''';
    final script = '''
<script>
let currentIndex = 0;
const events = [
  ${_events.map((event) {
      if(event.screenshot == null ){
        return '';
      }
      return '{src: "file://${event.screenshot!.file.path}", title: "${event.eventType?.label ?? "Event ${_events.indexOf(event) + 1}"}"},';
    },).join('\n  ')}
];
function openModal(index) {
  currentIndex = index;
  var modal = document.getElementById("myModal");
  var modalImg = document.getElementById("img01");
  var captionText = document.getElementById("captionText");
  modal.style.display = "block";
  modalImg.src = events[index].src;
  captionText.innerHTML = events[index].title;
}
function closeModal() {
  var modal = document.getElementById("myModal");
  modal.style.display = "none";
}
function showPrev() {
  currentIndex = (currentIndex + events.length - 1) % events.length;
  updateModal();
}
function showNext() {
  currentIndex = (currentIndex + 1) % events.length;
  updateModal();
}
function updateModal() {
  var modalImg = document.getElementById("img01");
  var captionText = document.getElementById("captionText");
  modalImg.src = events[currentIndex].src;
  captionText.innerHTML = events[currentIndex].title;
}
window.onclick = function(event) {
  var modal = document.getElementById("myModal");
  if (event.target == modal) {
    modal.style.display = "none";
  }
}
window.addEventListener("keydown", function(event) {
  if (event.key === "ArrowLeft") {
    showPrev();
  } else if (event.key === "ArrowRight") {
    showNext();
  } else if (event.key === "Escape") {
    closeModal();
  }
});
</script>
''';
    final events = (){
      final eventBuffer = StringBuffer();
      for (final event in _events) {
        final part = () {
          final index = _events.indexOf(event);
          final caller = event.initiator != null
              ? 'at ${event.initiator!.member} ${event.initiator!.uri}:${event.initiator!.line}:${event.initiator!.column}'
              : 'N/A';
          final type = event.eventType != null ? event.eventType!.label : "Unknown event type";
          final screenshot = event.screenshot != null ? '<img src="file://${event.screenshot!.file.path}" class="thumbnail" alt="Screenshot" onclick="openModal($index)">' : '';

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

    htmlBuffer.writeln('<html>');
    htmlBuffer.writeln('<head>');
    htmlBuffer.writeln('<title>Timeline Events</title>');
    htmlBuffer.writeln('<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">');
    htmlBuffer.write(style);
    htmlBuffer.write(script);
    htmlBuffer.writeln('</head>');
    htmlBuffer.writeln('<body>');
    htmlBuffer.writeln('<div class="header">');
    htmlBuffer.writeln('<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">');
    htmlBuffer.writeln('<h1>Timeline</h1>');
    htmlBuffer.writeln('</div>');

    htmlBuffer.writeln('<div class = "horizontal-spacer"><h2>General</h2></div>');

    htmlBuffer.writeln('<p><strong>Name:</strong> $nameWithHierarchy</p>');
    if(_events.isNotEmpty){
      htmlBuffer.writeln('<div class = "horizontal-spacer"><h2>Events</h2></div>');
    }

    htmlBuffer.write(events);

    htmlBuffer.writeln('<div id="myModal" class="modal">');
    htmlBuffer.writeln('<span class="close" onclick="closeModal()">&times;</span>');
    htmlBuffer.writeln('<img class="modal-content" id="img01">');
    htmlBuffer.writeln('<div id="caption">');
    htmlBuffer.writeln('<a class="nav nav-left" onclick="showPrev()">&#10094;</a>');
    htmlBuffer.writeln('<div id="captionText" class="text"></div>');
    htmlBuffer.writeln('<a class="nav nav-right" onclick="showNext()">&#10095;</a>');
    htmlBuffer.writeln('</div>');
    htmlBuffer.writeln('</div>');
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
