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

    final button = spotSingle<MaterialApp>().spotSingle<Scaffold>().spotSingle<ElevatedButton>();

    expect(i, 0);
    TouchEvent.tap(button);
    expect(i, 1);
    TouchEvent.tap(button);
    expect(i, 2);
  });
}
