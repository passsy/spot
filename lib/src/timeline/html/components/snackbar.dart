// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/web/theme.dart';

/// A snackbar to show messages to the user.
class SnackBar extends StatefulComponent {
  const SnackBar({super.key});

  @override
  State<SnackBar> createState() => SnackBarState();
}

class SnackBarState extends State<SnackBar> {
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
  Component build(BuildContext context) {
    return div(
      id: "snackbar",
      classes: "snackbar ${_message != null ? 'show' : ''}",
      [Component.text(_message ?? '')],
    );
  }

  static List<StyleRule> get styles => [
    css('.snackbar', [
      css('&').styles(
        display: Display.none,
        minWidth: 250.px,
        margin: Margin.only(left: (-125).px),
        radius: BorderRadius.circular(2.px),
        padding: Padding.all(16.px),
        position: Position.fixed(left: 50.percent, bottom: 30.px),
        backgroundColor: snackbarBackgroundColor,
        color: snackbarColor,
        textAlign: TextAlign.center,
        zIndex: const ZIndex(1),
      ),
      css('&.show').styles(
        display: Display.block,
        raw: {
          'animation': 'fadein 0.5s, fadeout 0.5s 2.5s',
          '-webkit-animation': 'fadein 0.5s, fadeout 0.5s 2.5s',
        },
      ),
    ]),
  ];
}
