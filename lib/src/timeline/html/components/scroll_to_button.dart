// ignore_for_file: public_member_api_docs, avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart'
    show document, window;
import 'package:jaspr/jaspr.dart';

class ScrollToButton extends StatefulComponent {
  const ScrollToButton({super.key});

  @override
  State<ScrollToButton> createState() => ScrollToButtonState();
}

class ScrollToButtonState extends State<ScrollToButton> {
  bool atBottom = false;

  @override
  void initState() {
    super.initState();
    // ignore: unnecessary_null_comparison
    if (window != null) {
      window.addEventListener('scroll', _onScroll);
      _checkScrollPosition();
    }
  }

  @override
  void dispose() {
    window.removeEventListener('scroll', _onScroll);
    super.dispose();
  }

  void _onScroll(Event e) {
    _checkScrollPosition();
  }

  void _checkScrollPosition() {
    final scrollHeight = document.body?.scrollHeight ?? 0;
    final viewHeight = window.innerHeight ?? 0;
    final scrolled = window.scrollY;
    final isBottom = (viewHeight + scrolled + 1) >= scrollHeight;

    if (isBottom != atBottom) {
      setState(() {
        atBottom = isBottom;
      });
    }
  }

  void _scrollToBottom() {
    window.scrollTo(0, document.body?.scrollHeight ?? 0);
  }

  void _scrollToTop() {
    window.scrollTo(0, 0);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'scroll-button', events: {
      'click': (e) {
        if (atBottom) {
          _scrollToTop();
        } else {
          _scrollToBottom();
        }
      },
    }, [
      text(atBottom ? '▲' : '▼'),
    ]);
  }

  static List<StyleRule> get styles => [
        css('.scroll-button')
            .box(
              display: Display.flex,
              position: Position.fixed(bottom: 20.px, right: 20.px),
              width: 50.px,
              height: 50.px,
              radius: const BorderRadius.circular(Unit.percent(50)),
              cursor: Cursor.pointer,
            )
            .flexbox(
              alignItems: AlignItems.center,
              justifyContent: JustifyContent.center,
            )
            .background(color: const Color.hex('#ff8c00'))
            .text(
              fontSize: 24.px,
            ),
      ];
}
