import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

@WidgetSelectorAndMatcherMacro()
class MacroTextTestWidget extends StatelessWidget {
  const MacroTextTestWidget({
    super.key,
    required this.age,
    required this.name,
    required this.username,
    required this.onPressed,
    required this.onLongPressed,
    required this.testEnum,
    required this.color,
    this.secondEnum,
  });

  final int age;
  final String name;
  final String username;
  final void Function() onPressed;
  final void Function(bool) onLongPressed;
  final TestEnum testEnum;
  final Color color;
  final TestEnum? secondEnum;

  @override
  Widget build(BuildContext context) {
    return Text(age.toString() + name + username);
  }
}

enum TestEnum {
  test1,
  test2,
  test3,
}
