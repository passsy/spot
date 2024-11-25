/// This library is compiled for both vm and web platforms.
/// Therefore, this and all imported libraries need to be platform agnostic or stubbed.
library timeline_page;

import 'dart:async';
import 'dart:js_interop' if (dart.library.io) 'web_stubs.dart';

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:web/web.dart' if (dart.library.io) 'web_stubs.dart';

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
  State<TimelineApp> createState() => _TimelineAppState();
}

class _TimelineAppState extends State<TimelineApp> {
  // ignore: prefer_const_constructors
  final GlobalKey<_SnackBarState> _snackBar = GlobalKey();
  // ignore: prefer_const_constructors
  final GlobalKey<_ModalState> _modal = GlobalKey();

  @override
  Iterable<Component> build(BuildContext context) {
    return [
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
        text(" ${component.testNameWithHierarchy}"),
      ]),
      button(classes: "button-spot", onClick: () async {
        final command = 'flutter test --plain-name="${component.testName}"';
        try {
          await window.navigator.clipboard.writeText(command).toDart;
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
          h2([text("Events")])
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
        a(href: "https://github.com/passsy/spot/issues", [text("github.com/passsy/spot")]),
      ]),
      Modal(events: component.timelineEvents, key: _modal),
    ];
  }
}

/// A snackbar to show messages to the user.
class SnackBar extends StatefulComponent {
  const SnackBar({super.key});

  @override
  State<SnackBar> createState() => _SnackBarState();
}

class _SnackBarState extends State<SnackBar> {
  String? _message;
  Timer? _timer;

  void show(String message) {
    setState(() {
      _message = message;
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        setState(() => _message = null);
      });
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(id: "snackbar", classes: "snackbar ${_message != null ? 'show' : ''}", [
      text(_message ?? ''),
    ]);
  }
}

class Events extends StatelessComponent {
  Events({required this.timeLineEvents, required this.onClick, super.key});

  final List<TimelineEvent> timeLineEvents;
  final void Function(TimelineEvent) onClick;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (final event in timeLineEvents) {
      yield div(
        classes: "event",
        styles: Styles.box(
            border: Border.all(event.color != null
                ? BorderSide(
                    color: Color.value(event.color!),
                    width: 2.px,
                  )
                : BorderSide(color: Colors.gray, width: 2.px))),
        [
          if (event.screenshotUrl case final screenshotUrl?)
            img(
              src: screenshotUrl,
              classes: "thumbnail",
              alt: "Screenshot",
              events: events(onClick: () => onClick(event)),
            ),
          div(classes: "event-details", [
            ExpandableBox(title: "Event Type", content: event.eventType),
            ExpandableBox(title: "Details", content: event.details),
            ExpandableBox(title: "Timestamp", content: event.timestamp),
            div(classes: "code-location", [
              ExpandableBox(title: "Caller", content: event.caller),
              if (event.jetBrainsLink case final jetBrainsLink?)
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

/// A box that can be expanded to show more content.
class ExpandableBox extends StatefulComponent {
  ExpandableBox({required this.title, required this.content, super.key});

  final String title;
  final String content;

  @override
  State<ExpandableBox> createState() => _ExpandableBoxState();
}

class _ExpandableBoxState extends State<ExpandableBox> {
  int? expandedTo;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final splitted = component.content.split('\n');

    if (splitted.length > 1) {
      yield div(classes: "content", styles: Styles.box(maxHeight: expandedTo?.px ?? 25.px), [
        p([
          strong([text('${component.title}:')]),
          text(' ${splitted.first} '),
          pre([text(splitted.skip(1).join('\n'))]),
        ]),
      ]);
      yield div(
        classes: 'show-more',
        events: {
          'click': (e) {
            if (expandedTo != null) {
              setState(() => expandedTo = null);
            } else {
              final contentHeight = ((e.target as HTMLElement?)?.previousSibling as HTMLElement?)?.scrollHeight;
              setState(() => expandedTo = contentHeight);
            }
          }
        },
        [raw(expandedTo != null ? 'Show less &#9650;' : 'Show more &#9660;')],
      );
    } else {
      yield p([
        strong([text("${component.title}:")]),
        text(" ${component.content} "),
      ]);
    }
  }
}

/// A modal to show a single event in detail.
class Modal extends StatefulComponent {
  const Modal({required this.events, super.key});

  final List<TimelineEvent> events;

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  int? _index;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      /// Adds keyboard navigation to the modal.
      window.onKeyDown.listen((event) {
        if (event.key == 'Escape') {
          close();
          event.preventDefault();
          event.stopPropagation();
        } else if (event.key == 'ArrowLeft') {
          showPrev();
          event.preventDefault();
          event.stopPropagation();
        } else if (event.key == 'ArrowRight') {
          showNext();
          event.preventDefault();
          event.stopPropagation();
        }
      });
    }
  }

  void open(TimelineEvent event) {
    setState(() {
      _index = component.events.indexOf(event);
    });
  }

  void close() {
    setState(() {
      _index = null;
    });
  }

  void showPrev() {
    if (_index == null) return;
    setState(() {
      _index = (_index! - 1) % component.events.length;
    });
  }

  void showNext() {
    if (_index == null) return;
    setState(() {
      _index = (_index! + 1) % component.events.length;
    });
  }

  TimelineEvent? get event => _index != null ? component.events[_index!] : null;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: "modal ${_index != null ? 'show' : ''}", events: events(onClick: close), [
      span(classes: "close", events: events(onClick: close), [raw("&times;")]),
      div(classes: "modal-content", [
        img(alt: "Screenshot of the Event", src: event?.screenshotUrl ?? ""),
        div(id: "caption", [
          a(
            classes: "nav nav-left",
            events: {
              'click': (dynamic e) {
                e.preventDefault();
                e.stopPropagation();
                showPrev();
              }
            },
            href: "",
            [raw("&#10094;")],
          ),
          div(id: "captionText", [text(event?.eventType ?? '')]),
          a(
            classes: "nav nav-right",
            events: {
              'click': (dynamic e) {
                e.preventDefault();
                e.stopPropagation();
                showNext();
              }
            },
            href: "",
            [raw("&#10095;")],
          ),
        ]),
      ]),
    ]);
  }
}
