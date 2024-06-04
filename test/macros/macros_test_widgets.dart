import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/widgets/test_class.dart';
import 'package:spot/src/widgets/test_class_two.dart';


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
  });

  final int age;
  final String name;
  final String username;
final void Function() onPressed;
final void Function(bool) onLongPressed;
final TestEnum testEnum;
final Color color;



  @override
  Widget build(BuildContext context) {
    return Text(age.toString() + name + username);
  }
}


void main (){
  spot<MacroTextTestWidget>().whereAge(age: 12);
  final myTest = TestClass(age: 12, name: 'name', username: 'username', testClassTwo: TestClassTwo(12, 'name'));
  myTest.toJson();
}


enum TestEnum {
  test1,
  test2,
  test3,
}
