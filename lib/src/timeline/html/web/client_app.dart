// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:jaspr/browser.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

void main() async {
  await web.EventStreamProviders.loadEvent.forTarget(web.window).first;

  final selector = web.document.querySelector('meta[hot-restart="true"]');
  if (selector != null) {
    _registerHotRestart();
  }

  // hydrate static HTML with the client side js to make it interactive
  runApp(const ClientApp());
}

void _registerHotRestart() {
  if (web.window.location.protocol == 'file:') {
    return;
  }
  Timer.periodic(const Duration(milliseconds: 200), (timer) {
    reloadOnChange('/script.js');
    reloadOnChange(web.window.location.href);
  });
}

final Map<String, String?> previousContentMap = {};

Future<void> reloadOnChange(String url) async {
  final response = await web.window
      .fetch(
        url.toJS,
        web.RequestInit(cache: 'no-cache'),
      )
      .toDart;
  final currentContent = await response.text().toDart;
  final previousContent = previousContentMap[url];
  if (previousContent != null && previousContent != currentContent.toDart) {
    web.window.location.reload();
  }
  previousContentMap[url] = currentContent.toDart; // Cache the current content
}

/// The main entry point for the timeline web app.
class ClientApp extends StatefulComponent {
  const ClientApp({super.key});

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp>
    with SyncStateMixin<ClientApp, Map<String, dynamic>> {
  /// The name of the test.
  late final String testName;

  /// The name of the test with the hierarchy.
  late final String testNameWithHierarchy;

  /// The events that occurred during the test.
  late final List<TimelineEvent> timelineEvents;

  @override
  void updateState(Map<String, dynamic> value) {
    // This uses Jasprs sync mechanism to retrieve the synced server state from the rendered HTML.
    // See ServerApp.getState() where the server injects the data
    timelineEvents = (value['timelineEvents'] as List)
        .cast<Map<String, dynamic>>()
        .map(TimelineEvent.fromMap)
        .toList();
    testName = value['testName'] as String;
    testNameWithHierarchy = value['testNameWithHierarchy'] as String;
  }

  @override
  Map<String, dynamic> getState() {
    throw UnimplementedError("Not implemented for client app");
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield TimelineApp(
      testName: testName,
      testNameWithHierarchy: testNameWithHierarchy,
      timelineEvents: timelineEvents,
    );
  }
}
