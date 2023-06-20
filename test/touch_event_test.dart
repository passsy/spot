import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('test touch event', (tester) async {
    int i = 0;
    void onPressed() => i++;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: onPressed,
              child: null,
            ),
          ),
        ),
      ),
    );

    final elevatedButton = spotSingle<MaterialApp>().spotSingle<Scaffold>().spotSingle<ElevatedButton>().snapshot();
    final element = elevatedButton.discoveredElements;
    final box = element?.renderObject as RenderBox?;
    final position = box!.localToGlobal(box.size.center(Offset.zero));

    expect(i, 0);
    TouchEvent.tap(position);
    expect(i, 1);
    TouchEvent.tap(position);
    expect(i, 2);
  });
}
