// ignore_for_file: public_member_api_docs, avoid_dynamic_calls

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart';

import 'package:dartx/dartx.dart';
import 'package:jaspr/dom.dart';
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
    final lastScreenshot = component.events.lastOrNullWhere(
      (e) => e.screenshotUrl != null,
    );
    final prevWithScreenshot =
        component.events
            .take(_index!)
            .reversed
            .firstOrNullWhere((e) => e.screenshotUrl != null) ??
        lastScreenshot;
    if (prevWithScreenshot == null) return;
    final nextIndex = component.events.indexOf(prevWithScreenshot);

    setState(() {
      _index = nextIndex;
    });
  }

  void showNext() {
    if (_index == null) return;
    final firstWithScreenshot = component.events.firstOrNullWhere(
      (e) => e.screenshotUrl != null,
    );
    final nextWithScreenshot =
        component.events
            .skip(_index! + 1)
            .firstOrNullWhere((e) => e.screenshotUrl != null) ??
        firstWithScreenshot;
    if (nextWithScreenshot == null) return;
    final nextIndex = component.events.indexOf(nextWithScreenshot);
    setState(() {
      _index = nextIndex;
    });
  }

  TimelineEvent? get event => _index != null ? component.events[_index!] : null;

  @override
  Component build(BuildContext context) {
    return div(
      classes: "modal ${_index != null ? 'show' : ''}",
      events: events(onClick: close),
      [
        div(classes: "modal-content", [
          img(
            alt: "Screenshot of the Event",
            src: event?.screenshotUrl ?? "",
            events: {
              'click': (dynamic e) {
                e.stopPropagation();
              },
            },
          ),
          span(classes: "close", events: events(onClick: close), const [
            RawText("&times;"),
          ]),
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
            const [RawText("&#10094;")],
          ),
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
            const [RawText("&#10095;")],
          ),
        ]),
        div(classes: "sidebar", [
          div(styles: Styles(height: 10.px), const []),
          h3([Component.text(event?.eventType ?? '')]),
          p([Component.text(event?.timestamp ?? '')]),
          p([Component.text(event?.wallTimestamp ?? '')]),
          p(
            events: {
              'click': (dynamic e) {
                e.stopPropagation();
              },
            },
            [
              a(href: event?.ideLink ?? '', [
                Component.text(event?.caller ?? ''),
              ]),
            ],
          ),
          p([Component.text(event?.details ?? '')]),
        ]),
      ],
    );
  }

  static List<StyleRule> get styles => [
    css('.modal', [
      css('&')
          .styles(
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          )
          .styles(
            display: Display.none,
            position: const Position.fixed(left: Unit.zero, top: Unit.zero),
            width: 100.percent,
            height: 100.percent,
            overflow: Overflow.auto,
          )
          .styles(backgroundColor: modalBackgroundColor)
          .styles(zIndex: const ZIndex(1)),
      css('&.show').styles(display: Display.flex),
      css('img')
          .styles(maxWidth: 100.percent, maxHeight: 100.percent)
          .styles(raw: {'object-fit': 'contain'}) //
          .styles(margin: const Margin.all(Unit.auto)),
      css('span').styles(backgroundColor: Colors.transparent),
      css('.modal-content')
          .styles(
            margin: const Margin.all(Unit.auto),
            display: Display.flex,
            maxWidth: 100.percent,
            height: 100.vh,
            overflow: Overflow.hidden,
            border: Border.none,
            position: const Position.relative(),
          )
          .styles(flexDirection: FlexDirection.column)
          .styles(flex: const Flex(grow: 1)) //
          .styles(backgroundColor: Colors.transparent),
      css('.close', [
        css('&')
            .styles(
              position: Position.absolute(top: 15.px, right: 35.px),
            )
            .styles(
              color: closeColor,
              fontSize: closeFontSize,
              fontWeight: FontWeight.bold,
              textShadow: TextShadow(
                color: const Color('#00000080'),
                offsetX: 0.px,
                offsetY: 2.px,
                blur: 8.px,
              ),
            ),
        css('&:hover, &:focus') //
            .styles(cursor: Cursor.pointer)
            .styles(
              color: closeHoverColor,
              textDecoration: TextDecoration.none,
            ),
      ]),
      css('.nav', [
        css('&')
            .styles(
              position: Position.absolute(top: 50.percent),
              cursor: Cursor.pointer,
              transform: Transform.translate(y: (-50).percent),
              padding: Padding.symmetric(vertical: 10.px, horizontal: 10.px),
              margin: Margin.only(right: 5.px),
            )
            .styles(
              color: navColor,
              fontWeight: FontWeight.bold,
              textDecoration: TextDecoration.none,
              fontSize: navFontSize,
              textShadow: TextShadow(
                color: const Color('#00000080'),
                offsetX: 0.px,
                offsetY: 2.px,
                blur: 8.px,
              ),
            )
            .styles(backgroundColor: navBackgroundColor)
            .styles(userSelect: UserSelect.none),
        css('&:hover').styles(color: navHoverColor),
        css('&.nav-left').styles(position: Position.absolute(left: 30.px)),
        css('&.nav-right').styles(position: Position.absolute(right: 30.px)),
      ]),
      css('.sidebar', [
        css('&')
            .styles(
              width: 400.px,
              height: 100.percent,
              overflow: Overflow.hidden,
              padding: Padding.symmetric(horizontal: 16.px),
              shadow: BoxShadow(
                color: const Color('#00000080'),
                offsetX: 0.px,
                offsetY: 0.px,
                blur: 3.px,
              ),
            )
            .styles(color: captionColor, textAlign: TextAlign.start)
            .styles(backgroundColor: Colors.white),
        css('& a').styles(textDecoration: TextDecoration.none),
        css('& div').styles(backgroundColor: Colors.transparent),
      ]),
    ]),
  ];
}
