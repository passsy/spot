import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

/// The main entry point for the timeline web app.
class ServerApp extends StatefulComponent {
  const ServerApp({
    required this.testName,
    required this.testNameWithHierarchy,
    required this.timelineEvents,
    super.key,
  });

  /// The name of the test.
  final String testName;

  /// The name of the test with the hierarchy.
  final String testNameWithHierarchy;

  /// The events that occurred during the test.
  final List<TimelineEvent> timelineEvents;

  @override
  State<ServerApp> createState() => _ServerAppState();
}

class _ServerAppState extends State<ServerApp>
    with SyncStateMixin<ServerApp, Map<String, dynamic>> {
  @override
  Map<String, dynamic> getState() {
    // This uses Jasprs sync mechanism to embed the server state into the rendered HTML.
    return {
      'testName': component.testName,
      'testNameWithHierarchy': component.testNameWithHierarchy,
      'timelineEvents': component.timelineEvents.map((e) => e.toMap()).toList(),
    };
  }

  @override
  void updateState(Map<String, dynamic> value) {}

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield TimelineApp(
      testName: component.testName,
      testNameWithHierarchy: component.testNameWithHierarchy,
      timelineEvents: component.timelineEvents,
    );
  }
}
