// ignore_for_file: avoid_print
import 'package:jaspr/server.dart' hide ServerApp;
import 'package:spot/src/timeline/html/sources/script.js.g.dart';
import 'package:spot/src/timeline/html/web/server_app.dart';
import 'package:spot/src/timeline/html/web/theme.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart' as x;

// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Server-side renders the HTML timeline with Jaspr
///
/// [inlineScripts] inlines all JS, allowing the HTML to be self-contained and
/// executed by opening the file without any content policy violations.
///
/// [hotRestart] causes the site to constantly poll itself for changes, auto-reloading
Future<String> renderTimelineWithJaspr(
  List<x.TimelineEvent> events, {
  bool inlineScripts = true,
  bool hotRestart = false,
}) async {
  // Turn off isolate rendering.
  Jaspr.initializeApp(useIsolates: false);
  final nameWithHierarchy = testNameWithHierarchy();
  final html = await renderComponent(
    Document(
      title: "Timeline Events",
      head: [
        link(
          href:
              "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap",
          rel: "stylesheet",
        ),
        if (!inlineScripts)
          const DomComponent(tag: 'script', attributes: {'src': 'script.js'})
        else
          DomComponent(tag: 'script', child: raw(timelineJS)),
        DomComponent(tag: 'style', child: raw(animationsCSS)),
        if (hotRestart)
          const DomComponent(tag: 'meta', attributes: {'hot-restart': 'true'}),
        if (hotRestart)
          DomComponent(tag: 'script', child: raw(_upgradeToLocalhostJS)),
      ],
      styles: ServerAppState.styles,
      body: ServerApp(
        testName: Invoker.current?.liveTest.test.name ?? 'Missing filename',
        testNameWithHierarchy: nameWithHierarchy,
        timelineEvents: events,
      ),
    ),
    standalone: true,
  );

  return '<!DOCTYPE html>\n$html';
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

/// When the HTML file itself is opened, it will automatically load the localhost:3000 version
const String _upgradeToLocalhostJS = r'''
if (window.location.protocol === 'file:') {
  const path = window.location.href.replace('file://', '');
  const parts = path.split('/').slice(-2);
  const url = `http://localhost:5907/${parts.join('/')}`;
  window.location.href = url;
}
''';
