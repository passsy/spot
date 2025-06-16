import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('spotWidgetsAtPosition finds stacked widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.blue, key: ValueKey(1)),
            ColoredBox(color: Colors.red, key: ValueKey(2)),
            ColoredBox(color: Colors.green, key: ValueKey(3)),
          ],
        ),
      ),
    );

    spot()
        .spotWidgetsAtPosition(const Offset(100, 100))
        .spot<ColoredBox>()
        .existsExactlyNTimes(3);
  });

  testWidgets('spotWidgetsAtPosition can select top most widget',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.blue, key: ValueKey(1)),
            ColoredBox(color: Colors.red, key: ValueKey(2)),
            ColoredBox(color: Colors.green, key: ValueKey(3)),
          ],
        ),
      ),
    );

    final selector = spot()
        .spotWidgetsAtPosition(const Offset(100, 100))
        .spot<ColoredBox>()
        .first();
    selector.existsOnce();
    final box = selector.snapshotWidget();
    expect(box.color, Colors.green);
  });
}
