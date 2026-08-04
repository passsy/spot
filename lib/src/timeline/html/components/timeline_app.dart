// ignore_for_file: public_member_api_docs

/// This library is compiled for both vm and web platforms.
/// Therefore, this and all imported libraries need to be platform agnostic or stubbed.
library;

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart' show window;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/components/events.dart';
import 'package:spot/src/timeline/html/components/modal.dart';
import 'package:spot/src/timeline/html/components/snackbar.dart';
import 'package:spot/src/timeline/html/web/theme.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

/// The main entry point for the timeline web app.
class TimelineApp extends StatefulComponent {
  const TimelineApp({
    required this.testName,
    required this.testNameWithHierarchy,
    required this.timelineEvents,
  });

  /// The name of the test.
  final String testName;

  /// The name of the test with the hierarchy.
  final String testNameWithHierarchy;

  /// The events that occurred during the test.
  final List<TimelineEvent> timelineEvents;

  @override
  State<TimelineApp> createState() => TimelineAppState();
}

class TimelineAppState extends State<TimelineApp> {
  // ignore: prefer_const_constructors
  final GlobalStateKey<SnackBarState> _snackBar = GlobalStateKey();

  // ignore: prefer_const_constructors
  final GlobalStateKey<ModalState> _modal = GlobalStateKey();

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const div(classes: "header", [
        img(
          src:
              "https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png",
          height: 100,
        ),
        h1([Component.text("Timeline")]),
      ]),
      const div(classes: "horizontal-spacer", [
        h2([Component.text("Info")]),
      ]),
      p([
        const strong([Component.text("Test:")]),
        Component.text(" ${component.testNameWithHierarchy}"),
      ]),
      button(
        classes: "button-spot",
        onClick: () async {
          final command = 'flutter test --plain-name="${component.testName}"';
          try {
            await window.navigator.clipboard?.writeText(command);
            _snackBar.currentState!.show("Test command copied to clipboard");
          } catch (_) {
            _snackBar.currentState!.show("Failed to copy test command");
          }
        },
        const [Component.text("Copy test command")],
      ),
      SnackBar(key: _snackBar),
      if (component.timelineEvents.isNotEmpty) ...[
        const div(classes: "horizontal-spacer", [
          h2([Component.text("Events")]),
        ]),
        section(classes: "events", [
          Events(
            timeLineEvents: component.timelineEvents,
            onClick: (event) {
              _modal.currentState!.open(event);
            },
          ),
        ]),
      ],
      const div([
        Component.text("Tell us how to improve the timeline at "),
        a(href: "https://github.com/passsy/spot/issues", [
          Component.text("github.com/passsy/spot"),
        ]),
      ]),
      Modal(events: component.timelineEvents, key: _modal),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.button-spot', [
      css('&')
          .styles(
            border: Border.none,
            radius: BorderRadius.circular(4.px),
            padding: Padding.symmetric(vertical: 8.px, horizontal: 16.px),
            cursor: Cursor.pointer,
            transition: const Transition(
              'background-color',
              duration: Duration(milliseconds: 300),
              curve: Curve.ease,
            ),
          )
          .styles(color: buttonColor, fontSize: 16.px)
          .styles(backgroundColor: buttonBackgroundColor),
      css('&:hover').styles(backgroundColor: buttonHoverBackgroundColor),
    ]),
    css('.horizontal-spacer', [
      css('&').styles(
        border: Border.only(
          bottom: BorderSide.solid(
            width: 1.px,
            color: horizontalSpacerBorderColor,
          ),
        ),
        padding: horizontalSpacerPadding,
      ),
      css('h2').styles(margin: Margin.zero, padding: Padding.zero),
    ]),
    ...Events.styles,
    ...SnackBarState.styles,
    ...ModalState.styles,
    ...textStyles,
  ];
}

List<StyleRule> get textStyles => [
  css('p') //
      .styles(
        raw: {
          'word-break': 'break-word',
          'overflow-wrap': 'break-word',
          'text-align': 'start',
        },
      ), //
];
