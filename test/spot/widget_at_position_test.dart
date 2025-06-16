import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('spotAtPosition finds widgets on hit-test path', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: ColoredBox(
              key: ValueKey('target'),
              color: Colors.green,
            ),
          ),
        ),
      ),
    );

    spot<ColoredBox>()
        .spotAtPosition(const Offset(400, 300))
        .withKey(const ValueKey('target'))
        .existsOnce();
    spot<SizedBox>().spotAtPosition(const Offset(400, 300)).existsOnce();
  });

  testWidgets('spotAtPosition finds all widgets on hit-test path',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: ColoredBox(
              key: ValueKey('target'),
              color: Colors.green,
            ),
          ),
        ),
      ),
    );

    final widgetsAtPosition = spot().spotAtPosition(const Offset(400, 300));
    widgetsAtPosition.existsAtLeastNTimes(2);
    widgetsAtPosition
        .whereWidget(
          (widget) => widget.key == const ValueKey('target'),
          description: 'target widget',
        )
        .existsOnce();
  });

  testWidgets('spotAtPosition filters typed selectors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ColoredBox(
                key: ValueKey('blue'),
                color: Colors.blue,
              ),
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: ColoredBox(
                key: ValueKey('green'),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );

    final selector = spot<ColoredBox>()
        .withKey(const ValueKey('green'))
        .spotAtPosition(const Offset(150, 300));
    selector.existsOnce();
    final box = selector.snapshotWidget();
    expect(box.color, Colors.green);
  });

  testWidgets('spotAtPosition returns no widgets outside the view',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ColoredBox(color: Colors.green),
      ),
    );

    spot<ColoredBox>().spotAtPosition(const Offset(-1, -1)).doesNotExist();
  });
}
