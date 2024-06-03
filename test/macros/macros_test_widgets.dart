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
  });

  final int age;
  final String name;
  final String username;
final void Function() onPressed;


  @override
  Widget build(BuildContext context) {
    return Text(age.toString() + name + username);
  }
}


void main (){
  spot<MacroTextTestWidget>();
}
