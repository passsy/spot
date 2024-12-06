// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

void main() async {
  await window.onLoad.first;
  runApp(const ClientApp());
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
