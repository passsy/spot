// ignore_for_file: public_member_api_docs

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/theme.dart';

/// A box that can be expanded to show more content.
class ExpandableBox extends StatefulComponent {
  const ExpandableBox({required this.title, required this.content, super.key});

  final String title;
  final String content;

  @override
  State<ExpandableBox> createState() => ExpandableBoxState();
}

class ExpandableBoxState extends State<ExpandableBox> {
  int? expandedTo;

  @override
  Component build(BuildContext context) {
    final split = component.content.split('\n');

    return Component.fragment([
      if (split.length > 1) ...[
        div(
          classes: "content",
          styles: Styles(maxHeight: expandedTo?.px ?? 25.px),
          [
            p([
              strong([Component.text('${component.title}:')]),
              Component.text(' ${split.first} '),
              pre([Component.text(split.skip(1).join('\n'))]),
            ]),
          ],
        ),
        div(
          classes: 'show-more',
          events: {
            'click': (e) {
              if (expandedTo != null) {
                setState(() => expandedTo = null);
              } else {
                final contentHeight = (e.target as HtmlElement?)
                    ?.previousElementSibling
                    ?.scrollHeight;
                setState(() => expandedTo = contentHeight);
              }
            },
          },
          [
            RawText(
              expandedTo != null ? 'Show less &#9650;' : 'Show more &#9660;',
            ),
          ],
        ),
      ] else
        p([
          strong([Component.text("${component.title}:")]),
          Component.text(" ${component.content} "),
        ]),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.content').styles(
      overflow: Overflow.hidden,
      transition: const Transition(
        'max-height',
        duration: Duration(milliseconds: 300),
        curve: Curve.ease,
      ),
    ),
    css('.content pre').styles(
      overflow: const Overflow.only(x: Overflow.auto),
      padding: Padding.only(bottom: 20.px),
      border: Border.all(width: 1.px, color: spotGrey),
    ),
    css('.show-more') //
        .styles(cursor: Cursor.pointer, display: Display.block)
        .styles(color: spotOrange)
        .styles(
          raw: {
            'background-color':
                'linear-gradient(to bottom, rgba(255, 255, 255, 0.4) 0%, rgba(255, 255, 255, 1) 100% )',
          },
        ),
  ];
}
