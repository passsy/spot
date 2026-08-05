import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/frame_clock.dart';
import 'package:spot/src/spot/tree_snapshot.dart';

void main() {
  testWidgets('counts every rendered frame', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('a')));
    final start = FrameClock.frameNumberInProcess;

    await tester.pumpWidget(const MaterialApp(home: Text('b')));
    expect(FrameClock.frameNumberInProcess, start + 1);

    await tester.pumpWidget(const MaterialApp(home: Text('c')));
    await tester.pumpWidget(const MaterialApp(home: Text('d')));
    expect(FrameClock.frameNumberInProcess, start + 3);
  });

  testWidgets('a tree snapshot is stale after the next frame', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('a')));

    final snapshot = createWidgetTreeSnapshot();
    expect(snapshot.isFromThisFrame, isTrue);

    await tester.pumpWidget(const MaterialApp(home: Text('b')));
    expect(snapshot.isFromThisFrame, isFalse);
  });

  testWidgets('a tree snapshot stays valid within its frame', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('a')));

    final snapshot = createWidgetTreeSnapshot();
    expect(identical(currentWidgetTreeSnapshot(), snapshot), isFalse);
    expect(
      identical(currentWidgetTreeSnapshot(), currentWidgetTreeSnapshot()),
      isTrue,
    );
  });
}
