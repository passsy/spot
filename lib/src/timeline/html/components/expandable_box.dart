// ignore_for_file: public_member_api_docs

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart';

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/theme.dart';

/// A box that can be expanded to show more content.
class ExpandableBox extends StatefulComponent {
  const ExpandableBox({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

  @override
  State<ExpandableBox> createState() => ExpandableBoxState();
}

class ExpandableBoxState extends State<ExpandableBox> {
  int? expandedTo;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final split = component.content.split('\n');

    if (split.length > 1) {
      yield div(
          classes: "content",
          styles: Styles.box(maxHeight: expandedTo?.px ?? 25.px),
          [
            p([
              strong([text('${component.title}:')]),
              text(' ${split.first} '),
              pre([text(split.skip(1).join('\n'))]),
            ]),
          ]);
      yield div(
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
        [raw(expandedTo != null ? 'Show less &#9650;' : 'Show more &#9660;')],
      );
    } else {
      yield p([
        strong([text("${component.title}:")]),
        text(" ${component.content} "),
      ]);
    }
  }

  static List<StyleRule> get styles => [
        css('.content').box(
          overflow: Overflow.hidden,
          transition:
              const Transition('max-height', duration: 300, curve: Curve.ease),
        ),
        css('.content pre').box(
          overflow: const Overflow.only(x: Overflow.auto),
          padding: EdgeInsets.only(bottom: 20.px),
          border: Border.all(BorderSide(width: 1.px, color: spotGrey)),
        ),
        css('.show-more') //
            .box(cursor: Cursor.pointer, display: Display.block)
            .text(color: spotOrange)
            .raw({
          'background-color':
              'linear-gradient(to bottom, rgba(255, 255, 255, 0.4) 0%, rgba(255, 255, 255, 1) 100% )',
        }),
      ];
}
