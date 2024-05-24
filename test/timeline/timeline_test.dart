import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';

Iterable<RegExpMatch> _screenshotMessageMatcher(String outPut) =>
    RegExp('Screenshot: file:').allMatches(outPut);

void main() {
  testWidgets('Live timeline', (tester) async {
    final addButtonSelector = spotIcon(Icons.add);
    final subtractButtonSelector = spotIcon(Icons.remove);

    final output = await captureConsoleOutput(() async {
      startLiveTimeline();
      int counter = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    counter++;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    counter--;
                  },
                ),
              ],
            ),
          ),
        ),
      );
      addButtonSelector.existsOnce();
      await act.tap(addButtonSelector);
      expect(counter, 1);
      await act.tap(subtractButtonSelector);
      expect(counter, 0);
    });

    expect(output, contains('🔴 - Recording timeline with live output'));
    expect(output, contains('Tap ${addButtonSelector.toStringBreadcrumb()}'));
    expect(
      output,
      contains('Tap ${subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(_screenshotMessageMatcher(output).length, 2);
  });
}

Future<String> captureConsoleOutput(
    Future<void> Function() testFunction) async {
  final StringBuffer buffer = StringBuffer();
  final ZoneSpecification spec = ZoneSpecification(
    print: (self, parent, zone, line) {
      buffer.writeln(line);
    },
  );

  await Zone.current.fork(specification: spec).run(() async {
    await testFunction();
  });

  return buffer.toString();
}