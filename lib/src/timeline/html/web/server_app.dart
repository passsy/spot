// ignore_for_file: public_member_api_docs

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';
import 'package:spot/src/timeline/html/web/theme.dart';
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
  State<ServerApp> createState() => ServerAppState();
}

class ServerAppState extends State<ServerApp>
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
  void updateState(Map<String, dynamic> value) {
    // See ClientApp.updateState() for the client side implementation.
    throw UnimplementedError("Not implemented for server app");
  }

  @override
  Component build(BuildContext context) {
    // Keep in sync with ClientApp.build(). Both should render the same components or hydration changes the DOM.
    return TimelineApp(
      testName: component.testName,
      testNameWithHierarchy: component.testNameWithHierarchy,
      timelineEvents: component.timelineEvents,
    );
  }

  static List<StyleRule> get styles => [
    css('*')
        .styles(fontFamily: fontFamily)
        .styles(raw: {'-webkit-font-smoothing': 'antialiased'}),
    css('body')
        .styles(
          margin: Margin.all(10.px),
          padding: Padding.only(bottom: 50.px),
        )
        .styles(backgroundColor: spotBackground),
    css('h1, h2, h3, p, pre').styles(color: fontColor),
    css('h1')
        .styles(fontWeight: FontWeight.w400, fontSize: h1FontSize)
        .styles(padding: h1Padding),
    css('.header').styles(alignItems: AlignItems.center),
    ...TimelineAppState.styles,
  ];
}
