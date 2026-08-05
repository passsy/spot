import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/frame_clock.dart';

void main() {
  testWidgets('counting before the test counts every frame', (tester) async {
    // Both frames render before this test touches FrameClock. The
    // flutter_test_config.dart next to this file introduced spot before the
    // test began, so they are in the count anyway, behind the tree-reset
    // frame flutter_test renders before the body.
    await tester.pumpWidget(const MaterialApp(home: Text('a')));
    await tester.pumpWidget(const MaterialApp(home: Text('b')));

    expect(FrameClock.frameNumberInTest, 3);
  });
}
