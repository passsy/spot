import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';

Iterable<RegExpMatch> _screenshotMessageMatcher(String outPut) =>
    RegExp('Screenshot: file:').allMatches(outPut);
final _addButtonSelector = spotIcon(Icons.add);
final _subtractButtonSelector = spotIcon(Icons.remove);
final _clearButtonSelector = spotIcon(Icons.clear);
void main() {
  testWidgets('Live timeline', (tester) async {
    final output = await _captureConsoleOutput(() async {
      startLiveTimeline();
      await tester.pumpWidget(const _TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });

    expect(output, contains('🔴 - Recording timeline with live output'));
    expect(output, contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'));
    expect(
      output,
      contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(_screenshotMessageMatcher(output).length, 2);
  });
  testWidgets('OnError timeline', (tester) async {
    final output = await _captureConsoleOutput(() async {
      startOnErrorTimeline();

      await tester.pumpWidget(const _TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });

    expect(output, contains('🔴 - Recording timeline for error output'));
    expect(
      output,
      isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
    );
    expect(_screenshotMessageMatcher(output).length, 0);
  });
  testWidgets('Start with Timeline Mode off', (tester) async {
    final output = await _captureConsoleOutput(() async {
      stopTimeline();
      await tester.pumpWidget(const _TimelineTestWidget());
      _addButtonSelector.existsOnce();
      spotText('Counter: 3').existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
    });

    expect(output, contains('⏸︎ - Timeline stopped'));
    expect(
      output,
      isNot(contains('Tap ${_addButtonSelector.toStringBreadcrumb()}')),
    );
    expect(
      output,
      isNot(contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}')),
    );
    expect(_screenshotMessageMatcher(output).length, 0);
  });
  testWidgets('Turn timeline mode off during test', (tester) async {
    final output = await _captureConsoleOutput(() async {
      startLiveTimeline();
      await tester.pumpWidget(
        const _TimelineTestWidget(),
      );
      spotText('Counter: 3').existsOnce();
      _addButtonSelector.existsOnce();
      await act.tap(_addButtonSelector);
      spotText('Counter: 4').existsOnce();
      await act.tap(_subtractButtonSelector);
      spotText('Counter: 3').existsOnce();
      stopTimeline();
      await act.tap(_clearButtonSelector);
      spotText('Counter: 0').existsOnce();
    });
    expect(output, contains('🔴 - Recording timeline with live output'));
    expect(output, contains('Tap ${_addButtonSelector.toStringBreadcrumb()}'));
    expect(
      output,
      contains('Tap ${_subtractButtonSelector.toStringBreadcrumb()}'),
    );
    expect(output, contains('⏸︎ - Timeline stopped'));
    // No further events were added to the timeline, including screenshots
    expect(
      output,
      isNot(contains('Tap ${_clearButtonSelector.toStringBreadcrumb()}')),
    );
    expect(_screenshotMessageMatcher(output).length, 2);
  });
}

class _TimelineTestWidget extends StatefulWidget {
  const _TimelineTestWidget();

  @override
  State<_TimelineTestWidget> createState() => _TimelineTestWidgetState();
}

class _TimelineTestWidgetState extends State<_TimelineTestWidget> {
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

Future<String> _captureConsoleOutput(
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
