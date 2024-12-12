// ignore_for_file: public_member_api_docs

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/components/expandable_box.dart';
import 'package:spot/src/timeline/html/web/theme.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

class Events extends StatelessComponent {
  const Events({
    required this.timeLineEvents,
    required this.onClick,
    super.key,
  });

  final List<TimelineEvent> timeLineEvents;
  final void Function(TimelineEvent) onClick;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (final event in timeLineEvents) {
      yield div(
        classes: "event",
        styles: Styles.box(
          border: Border.all(
            event.color != null
                ? BorderSide(
                    color: Color.value(event.color!),
                    width: 2.px,
                  )
                : BorderSide(color: Colors.gray, width: 1.px),
          ),
        ),
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
                  button(
                    classes: "secondary-button secondary-button--animated",
                    [
                      span(classes: "secondary-button__text", [text("IDEA")]),
                      span(classes: "secondary-button__icon", [text("→")]),
                    ],
                  ),
                ]),
            ]),
          ]),
        ],
      );
    }
  }

  static List<StyleRule> get styles => [
        css('.event', [
          css('&')
              .box(margin: eventMargin, padding: eventPadding)
              .flexbox(alignItems: AlignItems.start),
          css('& .event-details', [
            css('&') //
                .box(margin: eventDetailsMargin, minWidth: Unit.zero)
                .flexbox(
                  direction: FlexDirection.column,
                  justifyContent: JustifyContent.spaceBetween,
                ),
            css('& p') //
                .box(margin: EdgeInsets.zero, padding: eventDetailsPadding)
                .flexItem(flex: const Flex(grow: 1)),
          ]),
          css('& .code-location')
              .box(minWidth: Unit.zero)
              .flexbox(
                alignItems: AlignItems.center,
                direction: FlexDirection.row,
                wrap: FlexWrap.wrap,
              )
              .raw({'gap': '20px'}),
          css('& .thumbnail')
              .box(
            height: thumbnailHeight,
            border: thumbnailBorder,
            cursor: Cursor.pointer,
          )
              .raw({'object-fit': 'contain'}),
        ]),
        css('.secondary-button', [
          css('&')
              .box(
                padding:
                    EdgeInsets.symmetric(vertical: 6.px, horizontal: 24.px),
                border: const Border.all(BorderSide.none()),
                radius: BorderRadius.circular(8.px),
                cursor: Cursor.pointer,
                transition:
                    const Transition('all', duration: 300, curve: Curve.ease),
                width: 100.px,
              )
              .text(
                fontSize: 12.px,
                fontWeight: FontWeight.w600,
              ),
          css('&.secondary-button--animated', [
            css('&')
                .box(
                  overflow: Overflow.hidden,
                  position: const Position.relative(),
                )
                .background(color: spotOrange),
            css('& span').text(color: Colors.white).background(
                  color: Colors.transparent,
                ),
            css('& .secondary-button__text').box(
              display: Display.inlineBlock,
              transition: const Transition(
                'transform',
                duration: 300,
                curve: Curve.ease,
              ),
            ),
            css('& .secondary-button__icon').box(
              position: Position.absolute(right: (-20).px),
              transition:
                  const Transition('right', duration: 300, curve: Curve.ease),
            ),
            css('&:hover .secondary-button__text')
                .box(transform: Transform.translate(x: (-10).px)),
            css('&:hover .secondary-button__icon')
                .box(position: Position.absolute(right: 20.px)),
          ]),
        ]),
        ...ExpandableBoxState.styles,
      ];
}
