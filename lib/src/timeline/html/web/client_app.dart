// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:jaspr/client.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

void main() async {
  await web.window.onLoad.first;

  final selector = web.document.querySelector('meta[hot-restart="true"]');
  if (selector != null) {
    _registerHotRestart();
  }

  // hydrate static HTML with the client side js to make it interactive
  runApp(const TimelineClientApp());
}

void _registerHotRestart() {
  if (web.window.location.protocol == 'file:') {
    return;
  }
  // One pass at a time, a second apart. The document runs to a few hundred
  // kilobytes and re-downloading it is the whole check, so a pass that starts
  // while the previous one is still in flight only piles requests up. A second
  // is well inside how long a test rerun takes to write a new report.
  var checking = false;
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (checking) {
      return;
    }
    checking = true;
    try {
      final changed =
          await _hasChanged('/script.js') ||
          await _hasChanged(web.window.location.href);
      if (changed) {
        timer.cancel();
        web.window.location.reload();
      }
    } finally {
      checking = false;
    }
  });
}

final Map<String, String?> _previousContent = {};

/// Whether [url] serves something other than it did on the previous pass.
///
/// The first pass only records what is there, so opening the report does not
/// immediately reload it.
Future<bool> _hasChanged(String url) async {
  final response = await web.window
      .fetch(url.toJS, web.RequestInit(cache: 'no-store'))
      .toDart;
  final current = (await response.text().toDart).toDart;
  final previous = _previousContent[url];
  _previousContent[url] = current;
  return previous != null && previous != current;
}

/// The main entry point for the timeline web app.
class TimelineClientApp extends StatefulComponent {
  const TimelineClientApp({super.key});

  @override
  State<TimelineClientApp> createState() => _TimelineClientAppState();
}

class _TimelineClientAppState extends State<TimelineClientApp>
    with SyncStateMixin<TimelineClientApp, Map<String, dynamic>> {
  // Defaults rather than `late`, because [updateState] only runs when the
  // sync marker is found in the rendered HTML. A report served without it
  // would throw out of [build] instead of showing the empty timeline, and a
  // page that renders nothing is a worse report than a page that says so.

  /// The name of the test.
  String testName = '';

  /// The name of the test with the hierarchy.
  String testNameWithHierarchy = '';

  /// The events that occurred during the test.
  List<TimelineEvent> timelineEvents = const [];

  /// Every source file the events point into, keyed by path.
  Map<String, TimelineSourceFile> sourceFiles = const {};

  /// Frames the test rendered in total, recorded in or not.
  int renderedFrameCount = 0;

  @override
  void updateState(Map<String, dynamic> value) {
    // This uses Jasprs sync mechanism to retrieve the synced server state from the rendered HTML.
    // See TimelineServerApp.getState() where the server injects the data
    timelineEvents = (value['timelineEvents'] as List)
        .cast<Map<String, dynamic>>()
        .map(TimelineEvent.fromMap)
        .toList();
    sourceFiles = (value['sourceFiles'] as Map? ?? const {}).map(
      (path, file) => MapEntry(
        path as String,
        TimelineSourceFile.fromMap((file as Map).cast<String, dynamic>()),
      ),
    );
    testName = value['testName'] as String;
    testNameWithHierarchy = value['testNameWithHierarchy'] as String;
    renderedFrameCount = value['renderedFrameCount'] as int? ?? 0;
  }

  @override
  Map<String, dynamic> getState() {
    throw UnimplementedError("Not implemented for client app");
  }

  @override
  Component build(BuildContext context) {
    return TimelineApp(
      testName: testName,
      testNameWithHierarchy: testNameWithHierarchy,
      timelineEvents: timelineEvents,
      sourceFiles: sourceFiles,
      renderedFrameCount: renderedFrameCount,
    );
  }
}
