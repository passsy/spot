import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/flutter/frame_clock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Configuring the timeline at the top of main() is spot in use before any
  // test ran. Assigning the default changes nothing but the counting.
  globalTimelineMode = TimelineMode.reportOnError;

  testWidgets('globalTimelineMode in main() starts counting', (tester) async {
    // Counted from this test's first frame, which is the tree-reset frame
    // flutter_test renders before the body.
    expect(FrameClock.frameNumberInTest, 1);

    await tester.pumpWidget(const MaterialApp(home: Text('a')));
    expect(FrameClock.frameNumberInTest, 2);
  });
}
