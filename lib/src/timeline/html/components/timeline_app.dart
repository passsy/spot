// ignore_for_file: public_member_api_docs

/// This library is compiled for both vm and web platforms.
/// Therefore, this and all imported libraries need to be platform agnostic or stubbed.
library;

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart' show window;

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
  final GlobalKey<SnackBarState> _snackBar = GlobalKey();

  // ignore: prefer_const_constructors
  final GlobalKey<ModalState> _modal = GlobalKey();

  @override
  Iterable<Component> build(BuildContext context) {
    return [
      div(classes: "header", [
        img(
          src:
              "https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png",
          height: 100,
        ),
        h1([text("Timeline")]),
      ]),
      div(classes: "horizontal-spacer", [
        h2([text("Info")]),
      ]),
      p([
        strong([text("Test:")]),
        text(" ${component.testNameWithHierarchy}"),
      ]),
      button(classes: "button-spot", onClick: () async {
        final command = 'flutter test --plain-name="${component.testName}"';
        try {
          await window.navigator.clipboard?.writeText(command);
          _snackBar.currentState!.show("Test command copied to clipboard");
        } catch (_) {
          _snackBar.currentState!.show("Failed to copy test command");
        }
      }, [
        text("Copy test command"),
      ]),
      SnackBar(key: _snackBar),
      if (component.timelineEvents.isNotEmpty) ...[
        div(classes: "horizontal-spacer", [
          h2([text("Events")]),
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
      div([
        text("Tell us how to improve the timeline at "),
        a(
          href: "https://github.com/passsy/spot/issues",
          [text("github.com/passsy/spot")],
        ),
      ]),
      Modal(events: component.timelineEvents, key: _modal),
    ];
  }

  static List<StyleRule> get styles => [
        css('.button-spot', [
          css('&')
              .box(
                border: const Border.all(BorderSide.none()),
                radius: BorderRadius.circular(4.px),
                padding:
                    EdgeInsets.symmetric(vertical: 8.px, horizontal: 16.px),
                cursor: Cursor.pointer,
                transition: const Transition(
                  'background-color',
                  duration: 300,
                  curve: Curve.ease,
                ),
              )
              .text(color: buttonColor, fontSize: 16.px)
              .background(color: buttonBackgroundColor),
          css('&:hover').background(color: buttonHoverBackgroundColor),
        ]),
        css('.horizontal-spacer', [
          css('&').box(
            border: Border.only(
              bottom: BorderSide.solid(
                width: 1.px,
                color: horizontalSpacerBorderColor,
              ),
            ),
            padding: horizontalSpacerPadding,
          ),
          css('h2').box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
        ]),
        ...Events.styles,
        ...SnackBarState.styles,
        ...ModalState.styles,
        ...textStyles,
      ];
}

List<StyleRule> get textStyles => [
      css('p') //
          .raw({'word-break': 'break-word'}) //
          .raw({'overflow-wrap': 'break-word'}) //
          .raw({'text-align': 'start'}), //
    ];
