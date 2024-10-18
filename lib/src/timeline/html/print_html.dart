// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/timeline/html/script.js.dart';
import 'package:spot/src/timeline/html/styles.css.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:stack_trace/stack_trace.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Prints the timeline as an HTML file.
void printHTML(List<TimelineEvent> timeLineEvents) {
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
  final content = _timelineAsHTML(timeLineEvents: timeLineEvents);
  htmlFile.writeAsStringSync(content);
  //ignore: avoid_print
  print('View time line here: file://${htmlFile.path}');
}

/// Returns the events in the timeline as an HTML string.
String _timelineAsHTML({required List<TimelineEvent> timeLineEvents}) {
  final htmlBuffer = StringBuffer();
  final nameWithHierarchy = _testNameWithHierarchy();

  htmlBuffer.writeln('<html>');
  htmlBuffer.writeln('<head>');
  htmlBuffer.writeln('<title>Timeline Events</title>');
  htmlBuffer.writeln(
    '<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">',
  );

  final String eventsForScript =
      timeLineEvents.where((event) => event.screenshot != null).map((event) {
    return '{src: "file://${event.screenshot!.file.path}", title: "${event.eventType.label}"}';
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

  if (timeLineEvents.isNotEmpty) {
    htmlBuffer
        .writeln('<div class = "horizontal-spacer"><h2>Events</h2></div>');
  }

  String? projectName() {
    Directory? dir = Directory.current;
    String? projectDir;

    while (dir != null) {
      final ideaDir = Directory(path.join(dir.path, '.idea'));
      if (ideaDir.existsSync()) {
        // Update to the current directory path
        projectDir = dir.path;
      }

      // Move up to the parent directory
      final parentDir = dir.parent;
      if (dir.path == parentDir.path) {
        // Reached the root directory
        break;
      }
      dir = parentDir;
    }

    if (projectDir == null) return null;
    final name = projectDir.split('/').lastOrNull;
    return name;
  }

  String? eventCaller(Frame? initiator, {String? line}) {
    if (initiator == null) return null;

    final memberPart = initiator.member != null ? '${initiator.member} ' : '';
    final uriPart = initiator.uri;
    final linePart = line ?? initiator.line?.toString() ?? '0';
    final columnPart = initiator.column?.toString() ?? '0';

    return '$memberPart$uriPart:$linePart:$columnPart';
  }

  String? jetBrainsURL(TimelineEvent event) {
    final initiator = event.initiator;
    if (initiator == null) return null;

    final isIntelliJ = Platform.environment.values.any(
      (value) => value.toLowerCase().contains('intellij'),
    );
    if (!isIntelliJ) return null;

    final lineNumber = (initiator.line ?? 0) - 1;
    final clampedLine = lineNumber >= 0 ? lineNumber.toString() : '0';

    final caller = eventCaller(initiator, line: clampedLine);
    final name = projectName();
    if (caller == null || name == null) return null;

    final path = caller.trim().split(name).last.trim();
    if (path.isEmpty) return null;

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return 'jetbrains://idea/navigate/reference?project=$name&path=$normalizedPath';
  }

  final eventBuffer = StringBuffer();

  void writeScreenshot(TimelineEvent event) {
    final index = timeLineEvents.indexOf(event);
    final screenshot = event.screenshot != null
        ? '<img src="file://${event.screenshot!.file.path}" class="thumbnail" alt="Screenshot" onclick="openModal($index)">'
        : '';
    eventBuffer.writeln(screenshot);
  }

  void writeEventType(TimelineEvent event) {
    eventBuffer
        .writeln('<p><strong>Event Type:</strong> ${event.eventType}</p>');
  }

  void writeName(TimelineEvent event) {
    eventBuffer.writeln('<p><strong>Name:</strong> ${event.name}</p>');
  }

  void writeTimestamp(TimelineEvent event) {
    eventBuffer.writeln(
        '<p><strong>Timestamp:</strong> ${event.timestamp.toIso8601String()}</p>');
  }

  void writeCaller(TimelineEvent event) {
    final caller = eventCaller(event.initiator) ?? 'N/A';
    eventBuffer.writeln('<p><strong>Caller:</strong> $caller</p>');
  }

  void writeJetBrainsLink(TimelineEvent event) {
    final jetBrainsLink = jetBrainsURL(event);
    if (jetBrainsLink == null) return;

    eventBuffer.writeln(
      '<a href="$jetBrainsLink"><button class="bn29">OPEN IN IDEA</button></a>',
    );
  }

  final events = () {
    for (final event in timeLineEvents) {
      final index = timeLineEvents.indexOf(event);
      eventBuffer.writeln("<h2>#${index + 1}</h2>");
      eventBuffer.writeln('<div class="event">');
      writeScreenshot(event);
      eventBuffer.writeln('<div class="event-details">');
      writeEventType(event);
      writeName(event);
      writeTimestamp(event);
      writeCaller(event);
      writeJetBrainsLink(event);
      eventBuffer.writeln('</div>');
      eventBuffer.writeln('</div>');
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
