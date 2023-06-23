import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('test touch event', (tester) async {
    int i = 0;
    void onPressed() => i++;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child: null,
          ),
        ),
      ),
    );

    final button = spotSingle<MaterialApp>().spotSingle<ElevatedButton>();

    const act = Act();

    expect(i, 0);
    act.tap(button);
    expect(i, 1);
    act.tap(button);
    expect(i, 2);
  });
}
