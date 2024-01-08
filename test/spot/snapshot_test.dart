// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';

void main() {
  testWidgets('MultiWidgetSnapshot keeps reference to old Widget',
      (tester) async {
    await tester.pumpWidget(Center(child: SizedBox(height: 200)));
    final WidgetSnapshot<SizedBox> oldTree = snapshot(spot<SizedBox>());
    await tester.pumpWidget(Center(child: SizedBox(height: 100)));
    final WidgetSnapshot<SizedBox> newTree = snapshot(spot<SizedBox>());
    expect(oldTree.discoveredWidgets.first.height, 200);
    expect(newTree.discoveredWidgets.first.height, 100);
  });

  testWidgets('WidgetSnapshot keeps reference to old Widget', (tester) async {
    await tester.pumpWidget(Center(child: SizedBox(height: 200)));
    final WidgetSnapshot<SizedBox> oldTree = snapshot(spot<SizedBox>());
    await tester.pumpWidget(Center(child: SizedBox(height: 100)));
    final WidgetSnapshot<SizedBox> newTree = snapshot(spot<SizedBox>());
    expect(oldTree.discoveredWidget!.height, 200);
    expect(newTree.discoveredWidget!.height, 100);
  });
}
