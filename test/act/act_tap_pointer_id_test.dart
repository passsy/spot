import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

// Regression for https://github.com/passsy/spot/issues/164
void main() {
  testWidgets('poison gesture arena 0 with an unresolved eager winner', (
    tester,
  ) async {
    final recognizer = _EagerRecognizer();

    recognizer.addPointer(
      const PointerDownEvent(
        // ignore: avoid_redundant_argument_values
        pointer: 0,
        position: Offset(10, 10),
      ),
    );

    // Intentionally omit PointerUpEvent/PointerCancelEvent.
    // Disposing the recognizer removes its pointer route, but its accepted
    // gesture-arena entry remains, and the test-binding reset does not clear
    // the GestureArenaManager.
    recognizer.dispose();
  });

  testWidgets('act.tap works despite a stale gesture arena for pointer 0', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ElevatedButton(
          onPressed: () => taps++,
          child: const Text('tap'),
        ),
      ),
    );

    await act.tap(spot<ElevatedButton>());
    expect(taps, 1);

    await act.tapAt(tester.getCenter(find.byType(ElevatedButton)));
    expect(taps, 2);
  });
}

final class _EagerRecognizer extends OneSequenceGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    stopTrackingIfPointerNoLongerDown(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'pointer-zero poison';
}
