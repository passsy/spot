import 'package:counter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spot/spot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tap fab', (tester) async {
    timeline.mode = TimelineMode.always;
    await tester.pumpWidget(const CounterApp());
    spotText('0').existsOnce();
    final fab = spot<FloatingActionButton>()..existsOnce();
    await act.tap(fab);
    spotText('1').existsOnce();
  });
}
