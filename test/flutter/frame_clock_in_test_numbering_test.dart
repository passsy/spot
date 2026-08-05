import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/frame_clock.dart';

// Two identical tests, because the contract differs between the test that
// introduces spot to the process and every test after it. Whichever instance
// runs first is the introduction — the branches classify themselves, so test
// ordering, randomized or not, cannot break this file.
void main() {
  for (final run in ['one', 'two']) {
    testWidgets('counts from where spot was introduced ($run)', (tester) async {
      // One frame renders before this test touches FrameClock.
      await tester.pumpWidget(const MaterialApp(home: Text('a')));

      final atFirstTouch = FrameClock.frameNumberInTest;
      if (atFirstTouch == 0) {
        // This instance introduced spot: counting starts at the touch above,
        // so the frame already pumped is not in the number.
        await tester.pumpWidget(const MaterialApp(home: Text('b')));
        expect(FrameClock.frameNumberInTest, 1);

        // Rendered frames count, not pumps: with no frame scheduled, this
        // pump draws nothing and the number stands still.
        await tester.pump();
        expect(FrameClock.frameNumberInTest, 1);
      } else {
        // The other instance introduced spot, so this test is counted from
        // its first frame without touching spot early. That frame is not the
        // body's: flutter_test resets the tree with a frame of its own before
        // the body runs, and a frame that rendered counts.
        expect(atFirstTouch, 2);

        await tester.pumpWidget(const MaterialApp(home: Text('b')));
        expect(FrameClock.frameNumberInTest, 3);
      }
    });
  }
}
