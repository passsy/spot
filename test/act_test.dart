import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import 'util/assert_error.dart';

void main() {
  // Runs the tests as executed with `flutter test`
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding);
  group('AutomatedTestWidgetsFlutterBinding', actTests);
}

/// All tests for [act]
void actTests() {
  testWidgets('tap', (tester) async {
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

    final button = spotSingle<ElevatedButton>()..existsOnce();

    expect(i, 0);
    act.tap(button);
    expect(i, 1);
    act.tap(button);
    expect(i, 2);
  });

  testWidgets('tap throws if widget not in widget tree', (tester) async {
    await tester.pumpWidget(const MaterialApp());
    final button = spotSingle<ElevatedButton>()..doesNotExist();

    expect(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Could not find 'ElevatedButton' in widget tree",
      ]),
    );
  });

  testWidgets('tap throws if widget not in viewport', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Positioned(
              top: -1000,
              child: ElevatedButton(
                onPressed: () {},
                child: null,
              ),
            ),
          ],
        ),
      ),
    );

    final button = spotSingle<ElevatedButton>()..existsOnce();

    expect(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget 'ElevatedButton' is not visible and can't be tapped",
      ]),
    );
  });

  testWidgets('tap throws if widget is obstructed by another widget',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: null,
              ),
            ),
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );

    final button = spotSingle<ElevatedButton>()..existsOnce();
    expect(
      () => act.tap(button),
      throwsSpotErrorContaining([
        "Widget 'ElevatedButton' is not visible and can't be tapped",
      ]),
    );
  });
}
