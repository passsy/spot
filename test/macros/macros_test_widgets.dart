import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

@WidgetSelectorAndMatcherMacro()
class MacroTextTestWidget extends StatelessWidget {
  const MacroTextTestWidget({
    super.key,
    required this.age,
    required this.name,
    required this.username,
  });

  final int age;
  final String name;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Text(age.toString() + name + username);
  }
}
