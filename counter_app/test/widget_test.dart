// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_app/main.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    timeline.mode = TimelineMode.always;
    print(TestWidgetsFlutterBinding.instance);
    print(WidgetsBinding.instance);
    await tester.pumpWidget(const CounterApp());
    spotText('0').existsOnce();
    await act.tap(spotIcon(Icons.add));
    spotText('1').existsOnce();
  });
}
