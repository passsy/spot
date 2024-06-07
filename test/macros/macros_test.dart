import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('macro text test', (tester) async {
    int i = 0;
    void onPressed() => i++;

    void printOnPress() => debugPrint('printed');

    void printOnLongPress(bool value) => debugPrint("$value");

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child: MacroTextTestWidget(
              age: 12,
              color: Colors.red,
              name: 'name',
              username: 'username',
              onPressed: printOnPress,
              onLongPressed: printOnLongPress,
              onNullableLongPressed: printOnLongPress,
              testEnum: TestEnum.test1,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );

    final WidgetSelector<MacroTextTestWidget> selector =
        spot<MacroTextTestWidget>();

    selector.whereAge(12).existsOnce().hasAge(12);
    selector.whereColor(Colors.red).existsOnce().hasColor(Colors.red);
    selector.whereName('name').existsOnce().hasName('name');
    selector
        .whereTestEnum(TestEnum.test1)
        .existsOnce()
        .hasTestEnum(TestEnum.test1);
    selector.whereSecondEnum(null).existsOnce().hasSecondEnum(null);
    selector
        .whereOnPressed(printOnPress)
        .existsOnce()
        .hasOnPressed(printOnPress);
    selector
        .whereOnLongPressed(printOnLongPress)
        .existsOnce()
        .hasOnLongPressed(printOnLongPress);
    selector
        .whereOnNullableLongPressed(printOnLongPress)
        .existsOnce()
        .hasOnNullableLongPressed(printOnLongPress);
    selector
        .whereAlignment(Alignment.topCenter)
        .existsOnce()
        .hasAlignment(Alignment.topCenter);
  });
}

@WidgetSelectorAndMatcherMacro()
class MacroTextTestWidget extends StatelessWidget {
  const MacroTextTestWidget({
    super.key,
    required this.age,
    required this.name,
    required this.username,
    required this.onPressed,
    required this.onLongPressed,
    required this.onNullableLongPressed,
    required this.testEnum,
    required this.color,
    required this.alignment,
    this.secondEnum,
  });

  final int age;
  final String name;
  final String username;
  final void Function() onPressed;
  final void Function(bool) onLongPressed;
  final void Function(bool) onNullableLongPressed;
  final TestEnum testEnum;
  final Color color;
  final AlignmentGeometry alignment;
  final TestEnum? secondEnum;

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

enum TestEnum {
  test1,
  test2,
  test3,
}
