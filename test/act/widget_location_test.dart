import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/widget_location.dart';

void main() {
  testWidgets('reports the location where the widget was created',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Text('hello'),
      ),
    );

    final location = spot<Text>().snapshotElement().debugWidgetLocation;

    expect(location, isNotNull);
    expect(location!.file.path, contains('widget_location_test.dart'));
    expect(location.isUserCode, isTrue);
  });

  testWidgets('follows the widget when a rebuild moves the constructor call',
      (tester) async {
    // Both branches build a Text into the same slot, so the Element is reused
    // while its widget comes from a different line. A location cached per
    // Element would keep reporting the first branch.
    await tester.pumpWidget(
      const MaterialApp(
        home: _SwitchingText(useFirst: true),
      ),
    );
    final firstElement = spot<Text>().snapshotElement();
    final first = firstElement.debugWidgetLocation;

    await tester.pumpWidget(
      const MaterialApp(
        home: _SwitchingText(useFirst: false),
      ),
    );
    final secondElement = spot<Text>().snapshotElement();
    final second = secondElement.debugWidgetLocation;

    expect(
      secondElement,
      same(firstElement),
      reason: 'the Element must be reused for this test to prove anything',
    );
    expect(first!.file.path, contains('widget_location_test.dart'));
    expect(second!.file.path, contains('widget_location_test.dart'));
    expect(second.file.path, isNot(first.file.path));
  });
}

class _SwitchingText extends StatelessWidget {
  const _SwitchingText({required this.useFirst});

  final bool useFirst;

  @override
  Widget build(BuildContext context) {
    if (useFirst) {
      return const Text('hello');
    }
    return const Text('world');
  }
}
