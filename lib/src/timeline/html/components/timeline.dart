import 'package:flutter/material.dart' as flt;
import 'package:jaspr/server.dart';
import 'package:spot/src/timeline/html/print_html.dart';
import 'package:spot/src/timeline/html/script.js.dart';
import 'package:spot/src/timeline/html/styles.css.dart';
import 'package:spot/src/timeline/timeline.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

class TimelineView extends StatelessComponent {
  TimelineView({required this.timeLineEvents, super.key});

  final List<TimelineEvent> timeLineEvents;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final nameWithHierarchy = testNameWithHierarchy();

    final String eventsForScript = timeLineEvents.where((event) => event.screenshot != null).map((event) {
      return '{'
          'src: "file://${event.screenshot!.file.path}", '
          'title: "${event.eventType.label}", '
          'color: "${event.eventType.color?.value.toRadixString(16) ?? '000000'}" '
          '}';
    }).join(',\n  ');

    yield Document(
      title: "Timeline Events",
      head: [
        link(href: "https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap", rel: "stylesheet"),
        script(src: "", [
          raw(timelineJS
              .replaceAll('{{events}}', eventsForScript)
              .replaceAll('{testName}', Invoker.current!.liveTest.test.name))
        ]),
        DomComponent(tag: 'style', child: raw(timelineCSS)),
      ],
      body: Fragment(children: [
        div(classes: "header", [
          img(
            src: "https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png",
            height: 100,
          ),
          h1([text("Timeline")]),
        ]),
        div(classes: "horizontal-spacer", [
          h2([text("Info")]),
        ]),
        p([
          strong([text("Test:")]),
          text(" $nameWithHierarchy"),
        ]),
        button(classes: "button-spot", attributes: {
          "onclick": "copyTestCommandToClipboard()"
        }, [
          text("Copy test command"),
        ]),
        div(id: "snackbar", []),
        if (timeLineEvents.isNotEmpty)
          div(classes: "horizontal-spacer", [
            h2([text("Events")])
          ]),
        section(classes: "events", [
          Events(timeLineEvents: timeLineEvents),
        ]),
        div([
          text("Tell us how to improve the timeline at "),
          a(href: "https://github.com/passsy/spot/issues", [text("github.com/passsy/spot")]),
        ]),
        Modal(),
      ]),
    );
  }
}

class Events extends StatelessComponent {
  Events({required this.timeLineEvents, super.key});

  final List<TimelineEvent> timeLineEvents;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (final event in timeLineEvents) {
      yield div(
        classes: "event",
        styles: Styles.box(
            border: Border.all(BorderSide(
          color: Color.value(event.color.value & 0xFFFFFF),
          width: event.color == flt.Colors.grey ? 1.px : 2.px,
        ))),
        [
          if (event.screenshot != null)
            img(
              src: "file://${event.screenshot!.file.path}",
              classes: "thumbnail",
              alt: "Screenshot",
              attributes: {"onclick": "openModal(${timeLineEvents.indexOf(event)})"},
            ),
          div(classes: "event-details", [
            ExpandableBox(title: "Event Type", content: event.eventType.label),
            ExpandableBox(title: "Details", content: event.details),
            ExpandableBox(title: "Timestamp", content: event.timestamp.toIso8601String()),
            div(classes: "code-location", [
              ExpandableBox(title: "Caller", content: eventCaller(event.initiator) ?? 'N/A'),
              if (jetBrainsURL(event) case final jetBrainsLink?)
                a(href: jetBrainsLink, [
                  button(classes: "secondary-button secondary-button--animated", [
                    span(classes: "secondary-button__text", [text("IDEA")]),
                    span(classes: "secondary-button__icon", [text("→")]),
                  ]),
                ]),
            ])
          ]),
        ],
      );
    }
  }
}

class ExpandableBox extends StatelessComponent {
  ExpandableBox({required this.title, required this.content, super.key});

  final String title;
  final String content;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final splitted = content.split('\n');

    if (splitted.length > 1) {
      yield div(classes: "content", [
        p([
          strong([text('$title:')]),
          text(' ${splitted.first} '),
          pre([text(splitted.skip(1).join('\n'))]),
        ]),
      ]);
    } else {
      yield p([
        strong([text("${title}:")]),
        text(" ${content} "),
      ]);
    }
  }
}

class Modal extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(id: "myModal", classes: "modal", [
      span(classes: "close", attributes: {"onclick": "closeModal()"}, [raw("&times;")]),
      div(classes: "modal-content", [
        img(id: "img01", alt: "Screenshot of the Event", src: ""),
        div(id: "caption", [
          a(classes: "nav nav-left", attributes: {"onclick": "showPrev()"}, href: "", [raw("&#10094;")]),
          div(id: "captionText", []),
          a(classes: "nav nav-right", attributes: {"onclick": "showNext()"}, href: "", [raw("&#10095;")]),
        ]),
      ]),
    ]);
  }
}
