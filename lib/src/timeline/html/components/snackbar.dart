// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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
  void dispose() {
    // Without this the timer outlives the component and calls setState on it.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(
      id: "snackbar",
      classes: "snackbar ${_message != null ? 'show' : ''}",
      [Component.text(_message ?? '')],
    );
  }
}
