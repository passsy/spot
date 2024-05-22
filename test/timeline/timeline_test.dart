import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';

void main() {
  testWidgets('Automatically take screenshots for timeline', (tester) async {
    startLiveTimeline();
    stopTimeline();
    startOnErrorTimeline();
    int counter = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  counter++;
                },
              ),
            ],
          ),
        ),
      ),
    );
    print('Before tap');
    await act.tap(spotIcon(Icons.home));
    print('After tap');

    print('Before tap2');
    await act.tap(spot<AppBar>());
    print('After tap2');

    expect(counter, 2);
  });
}
