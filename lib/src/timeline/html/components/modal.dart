// ignore_for_file: public_member_api_docs, avoid_dynamic_calls

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart';

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/theme.dart';

import 'package:spot/src/timeline/html/web/timeline_event.dart';

/// A modal to show a single event in detail.
class Modal extends StatefulComponent {
  const Modal({required this.events, super.key});

  final List<TimelineEvent> events;

  @override
  State<Modal> createState() => ModalState();
}

class ModalState extends State<Modal> {
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
    yield div(
      classes: "modal ${_index != null ? 'show' : ''}",
      events: events(onClick: close),
      [
        span(
          classes: "close",
          events: events(onClick: close),
          [raw("&times;")],
        ),
        div(classes: "modal-content", [
          img(
            alt: "Screenshot of the Event",
            src: event?.screenshotUrl ?? "",
          ),
          div(classes: "caption", [
            a(
              classes: "nav nav-left",
              events: {
                'click': (dynamic e) {
                  e.preventDefault();
                  e.stopPropagation();
                  showPrev();
                },
              },
              href: "",
              [raw("&#10094;")],
            ),
            div([text(event?.eventType ?? '')]),
            a(
              classes: "nav nav-right",
              events: {
                'click': (dynamic e) {
                  e.preventDefault();
                  e.stopPropagation();
                  showNext();
                },
              },
              href: "",
              [raw("&#10095;")],
            ),
          ]),
        ]),
      ],
    );
  }

  static List<StyleRule> get styles => [
        css('.modal', [
          css('&')
              .flexbox(
                justifyContent: JustifyContent.center,
                alignItems: AlignItems.center,
              )
              .box(
                display: Display.none,
                position: const Position.fixed(left: Unit.zero, top: Unit.zero),
                width: 100.percent,
                height: 100.percent,
                overflow: Overflow.auto,
              )
              .background(color: modalBackgroundColor)
              .raw({'z-index': '1'}),
          css('&.show').box(display: Display.block),
          css('img').box(maxWidth: 100.percent, height: Unit.auto),
          css('span').background(color: Colors.transparent),
          css('.modal-content')
              .box(
                margin: const EdgeInsets.all(Unit.auto),
                display: Display.flex,
                maxWidth: 80.percent,
                height: Unit.auto,
                border: const Border.all(BorderSide.none()),
                position: const Position.relative(),
              )
              .flexbox(direction: FlexDirection.column)
              .background(color: Colors.transparent),
          css('.close', [
            css('&') //
                .box(position: Position.absolute(top: 15.px, right: 35.px))
                .text(
                  color: closeColor,
                  fontSize: closeFontSize,
                  fontWeight: FontWeight.bold,
                ),
            css('&:hover, &:focus') //
                .box(cursor: Cursor.pointer)
                .text(color: closeHoverColor, decoration: TextDecoration.none),
          ]),
          css('.nav', [
            css('&')
                .box(
                  position: Position.absolute(top: 50.percent),
                  cursor: Cursor.pointer,
                  transform: Transform.translate(y: (-50).percent),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.px, horizontal: 10.px),
                  margin: EdgeInsets.only(right: 5.px),
                )
                .text(
                  color: navColor,
                  fontWeight: FontWeight.bold,
                  fontSize: navFontSize,
                )
                .background(color: navBackgroundColor)
                .raw({'user-select': 'none'}),
            css('&:hover').text(color: navHoverColor),
            css('&.nav-left').box(position: Position.absolute(left: (-50).px)),
            css('&.nav-right')
                .box(position: Position.absolute(right: (-50).px)),
          ]),
          css('.caption', [
            css('&')
                .box(padding: captionPadding, height: 150.px)
                .text(color: captionColor, align: TextAlign.center)
                .background(color: Colors.transparent),
            css('& div').background(color: Colors.transparent),
          ]),
        ]),
      ];
}
