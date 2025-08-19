// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets(
      'This test is also quite long so that any logic shortening long file and test names will be reached',
      (tester) async {
    timeline.mode = TimelineMode.always;
    await tester.pumpWidget(MaterialApp(home: Scaffold()));
    spot<MaterialApp>().existsOnce();
    // expect timeline to render correctly, especially on windows
  });
}
