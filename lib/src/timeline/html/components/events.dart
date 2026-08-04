// ignore_for_file: public_member_api_docs

import 'package:jaspr/dom.dart';
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
  Component build(BuildContext context) {
    return Component.fragment([
      for (final event in timeLineEvents)
        div(
          classes: "event",
          styles: Styles(
            border: Border.all(
              color: event.color != null
                  ? Color.value(event.color!)
                  : Colors.gray,
              width: event.color != null ? 2.px : 1.px,
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
                  a(href: jetBrainsLink, const [
                    button(
                      classes: "secondary-button secondary-button--animated",
                      [
                        span(classes: "secondary-button__text", [
                          Component.text("IDEA"),
                        ]),
                        span(classes: "secondary-button__icon", [
                          Component.text("→"),
                        ]),
                      ],
                    ),
                  ]),
              ]),
            ]),
          ],
        ),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.event', [
      css('&')
          .styles(margin: eventMargin, padding: eventPadding)
          .styles(alignItems: AlignItems.start),
      css('& .event-details', [
        css('&') //
            .styles(margin: eventDetailsMargin, minWidth: Unit.zero)
            .styles(
              flexDirection: FlexDirection.column,
              justifyContent: JustifyContent.spaceBetween,
            ),
        css('& p') //
            .styles(margin: Margin.zero, padding: eventDetailsPadding)
            .styles(flex: const Flex(grow: 1)),
      ]),
      css('& .code-location')
          .styles(minWidth: Unit.zero)
          .styles(
            alignItems: AlignItems.center,
            flexDirection: FlexDirection.row,
            flexWrap: FlexWrap.wrap,
          )
          .styles(raw: {'gap': '20px'}),
      css('& .thumbnail')
          .styles(
            height: thumbnailHeight,
            border: thumbnailBorder,
            cursor: Cursor.pointer,
          )
          .styles(raw: {'object-fit': 'contain'}),
    ]),
    css('.secondary-button', [
      css('&')
          .styles(
            padding: Padding.symmetric(vertical: 6.px, horizontal: 24.px),
            border: Border.none,
            radius: BorderRadius.circular(8.px),
            cursor: Cursor.pointer,
            transition: const Transition(
              'all',
              duration: Duration(milliseconds: 300),
              curve: Curve.ease,
            ),
            width: 100.px,
          )
          .styles(fontSize: 12.px, fontWeight: FontWeight.w600),
      css('&.secondary-button--animated', [
        css('&')
            .styles(
              overflow: Overflow.hidden,
              position: const Position.relative(),
            )
            .styles(backgroundColor: spotOrange),
        css('& span')
            .styles(color: Colors.white)
            .styles(backgroundColor: Colors.transparent),
        css('& .secondary-button__text').styles(
          display: Display.inlineBlock,
          transition: const Transition(
            'transform',
            duration: Duration(milliseconds: 300),
            curve: Curve.ease,
          ),
        ),
        css('& .secondary-button__icon').styles(
          position: Position.absolute(right: (-20).px),
          transition: const Transition(
            'right',
            duration: Duration(milliseconds: 300),
            curve: Curve.ease,
          ),
        ),
        css(
          '&:hover .secondary-button__text',
        ).styles(transform: Transform.translate(x: (-10).px)),
        css(
          '&:hover .secondary-button__icon',
        ).styles(position: Position.absolute(right: 20.px)),
      ]),
    ]),
    ...ExpandableBoxState.styles,
  ];
}
