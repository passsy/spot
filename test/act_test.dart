import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  // Runs the tests as executed with `flutter test`
  AutomatedTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is! LiveTestWidgetsFlutterBinding);
  group('AutomatedTestWidgetsFlutterBinding', actTests);
}

/// All tests for [act]
void actTests() {
  testWidgets('act.tap()', (tester) async {
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

    expect(i, 0);
    act.tap(button);
    expect(i, 1);
    act.tap(button);
    expect(i, 2);
  });

  testWidgets('act.tap() throws if widget not on screen', (tester) async {
    int i = 0;
    void onPressed() => i++;

    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          children: [
            for (int i = 0; i < 10; i++) const SizedBox(height: 200),
            ElevatedButton(
              onPressed: onPressed,
              child: null,
            ),
          ],
        ),
      ),
    );

    final button = spotSingle<ElevatedButton>();

    expect(() => act.tap(button), throwsException);

    await tester.scrollUntilVisible(find.byType(ElevatedButton), 100);

    expect(i, 0);
    act.tap(button);
    expect(i, 1);
    act.tap(button);
    expect(i, 2);
  });
}
