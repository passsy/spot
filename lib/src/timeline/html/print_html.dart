import 'dart:io';

import 'package:jaspr/server.dart' show Jaspr, renderComponent;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/timeline/html/components/timeline.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:stack_trace/stack_trace.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Writes the timeline as an HTML file
extension HtmlTimelinePrinter on Timeline {
  /// Prints the timeline as an HTML file.
  Future<void> printHTML() async {
    final spotTempDir = Directory.systemTemp.createTempSync();

    String name = test.test.name;
    if (name.isEmpty) {
      name = 'Unnamed test';
    }
    if (!spotTempDir.existsSync()) {
      spotTempDir.createSync();
    }

    final String nameForHtml = () {
      String name = test.test.name;

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

    final htmlFile = File('${spotTempDir.path}/$nameForHtml');
    try {
      Jaspr.initializeApp(useIsolates: false);
      final content = await renderComponent(TimelineView(timeLineEvents: events));
      htmlFile.writeAsStringSync(content);
      //ignore: avoid_print
      print('View time line here: file://${htmlFile.path}');
    } catch (e) {
      //ignore: avoid_print
      print('Error writing HTML file: $e');
    }
  }
}

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

String? projectName() {
  Directory? dir = Directory.current;
  String? projectDir;

  while (dir != null) {
    final ideaDir = Directory('${dir.path}/.idea');
    if (ideaDir.existsSync()) {
      // Update to the current directory path
      projectDir = dir.path;
      break;
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
