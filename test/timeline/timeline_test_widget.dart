import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// Taps the counter up and down, recording [tapCounterEvents].
///
/// A closure and not a function, because dart2wasm reports where a frame is
/// only for closures, and the timeline names the caller of each event.
// ignore: prefer_function_declarations_over_variables
final Future<void> Function(WidgetTester tester) tapCounter = (tester) async {
  await tester.pumpWidget(const TimelineTestWidget());
  spotIcon(Icons.add).existsOnce();
  spotText('Counter: 3').existsOnce();
  await act.tap(spotIcon(Icons.add));
  spotText('Counter: 4').existsOnce();
  await act.tap(spotIcon(Icons.remove));
  spotText('Counter: 3').existsOnce();
};

/// The events [tapCounter] records, `act.tap` asserts its target first.
final tapCounterEvents = [
  'Assertion: ${spotIcon(Icons.add).toStringBreadcrumb()} exists once.',
  'Assertion: ${spotText('Counter: 3')} exists once.',
  'Assertion: ${spotIcon(Icons.add).toStringBreadcrumb()} exists once.',
  'Tap Event: Tap ${spotIcon(Icons.add).toStringBreadcrumb()}',
  'Assertion: ${spotText('Counter: 4')} exists once.',
  'Assertion: ${spotIcon(Icons.remove).toStringBreadcrumb()} exists once.',
  'Tap Event: Tap ${spotIcon(Icons.remove).toStringBreadcrumb()}',
  'Assertion: ${spotText('Counter: 3')} exists once.',
];

class TimelineTestWidget extends StatefulWidget {
  const TimelineTestWidget({super.key});

  @override
  State<TimelineTestWidget> createState() => _TimelineTestWidgetState();
}

class _TimelineTestWidgetState extends State<TimelineTestWidget> {
  int _counter = 3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _counter--;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _counter = 0;
                });
              },
            ),
          ],
        ),
        body: Center(child: Text('Counter: $_counter')),
      ),
    );
  }
}
