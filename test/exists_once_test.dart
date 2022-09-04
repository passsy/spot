import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existsOnce() finds widgets that only exist once in tree',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    spot.byType(MaterialApp).existsOnce();
    spot.byType(Center).existsOnce();
    spot.byType(Padding).existsOnce();
    spot.byType(Wrap).existsOnce();
    spot.byType(SizedBox).existsOnce();
    spot.byType(GestureDetector).existsOnce();
  });

  testWidgets('existsOnce() fails when widgets do not exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      () => spot.byType(Scaffold).existsOnce(),
      throwsA(isA<TestFailure>()),
    );
    expect(() => spot.byType(Row).existsOnce(), throwsA(isA<TestFailure>()));
    expect(() => spot.byType(Column).existsOnce(), throwsA(isA<TestFailure>()));
  });

  testWidgets('existsOnce() fails when multiple widgets exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                SizedBox(
                  child: GestureDetector(
                    child: const Text('Hello', maxLines: 2),
                  ),
                ),
                const Text('World', maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      () => spot.byType(Text).existsOnce(),
      throwsA(
        isA<TestFailure>()
            .having((e) => e.message, 'message', contains('Found 2 elements'))
            .having((e) => e.message, 'candidate1', contains('Text("World"'))
            .having((e) => e.message, 'candidate2', contains('Text("Hello"')),
      ),
    );
  });
}
