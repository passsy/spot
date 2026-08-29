// ignore_for_file: public_member_api_docs

import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/theme.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

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
              // Casts between interop types are unchecked, so ask what the
              // target really is instead of trusting the cast to fail.
              final target = e.target;
              if (target == null || !target.isA<web.Element>()) {
                return;
              }
              final content = (target as web.Element).previousElementSibling;
              setState(() => expandedTo = content?.scrollHeight);
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
