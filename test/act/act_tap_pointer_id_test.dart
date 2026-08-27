import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

// Regression for https://github.com/passsy/spot/issues/164
//
// Pointer id 0 is the default of raw PointerDownEvent, which act.tap used to
// dispatch. Ids 1-10 are what other allocators produce: flutter_test's
// WidgetController counter (1, 2, 3, ...) and the small ids multi-touch tests
// hardcode. Spot allocates from an offset range (1 << 20 and up), so a stale
// gesture arena on any of these ids must never capture a spot tap.
var _arenasPoisoned = false;

void main() {
  testWidgets('poison gesture arenas 0-10 with unresolved eager winners', (
    tester,
  ) async {
    for (var pointer = 0; pointer <= 10; pointer++) {
      final recognizer = _EagerRecognizer();

      recognizer.addPointer(
        PointerDownEvent(
          pointer: pointer,
          position: const Offset(10, 10),
        ),
      );

      // Intentionally omit PointerUpEvent/PointerCancelEvent.
      // Disposing the recognizer removes its pointer route, but its accepted
      // gesture-arena entry remains, and the test-binding reset does not clear
      // the GestureArenaManager.
      recognizer.dispose();
    }
    _arenasPoisoned = true;
  });

  testWidgets('act.tap works despite stale gesture arenas on ids 0-10', (
    tester,
  ) async {
    expect(
      _arenasPoisoned,
      isTrue,
      reason: 'The poison test must run first, '
          'otherwise this test passes without testing anything',
    );

    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ElevatedButton(
          onPressed: () => taps++,
          child: const Text('tap'),
        ),
      ),
    );

    // Precondition with an explicit id outside the poisoned range, proving
    // the button itself is tappable. tester.tap would auto-allocate id 1,
    // which is poisoned.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ElevatedButton)),
      pointer: 424242,
    );
    await gesture.up();
    await tester.pump();
    expect(taps, 1, reason: 'precondition: the button must be tappable');

    await act.tap(spot<ElevatedButton>());
    expect(taps, 2);

    await act.tapAt(tester.getCenter(find.byType(ElevatedButton)));
    expect(taps, 3);
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
  String get debugDescription => 'stale-pointer-id poison';
}
