import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/capture_console_output.dart';
import 'drag/drag_until_visible_test_widget.dart';
import 'printed_timeline.dart';
import 'timeline_test_widget.dart';

/// What the timeline records and prints while a test runs, per mode.
///
/// Every test sets the mode it needs, because the global mode it would start
/// with is whatever `globalTimelineMode` an earlier file set in its `main()`.
/// What is printed after a test ended, and how a failing test changes that,
/// depends on the test runner and is tested in `timeline_report_test.dart`.
void main() {
  group('changing the mode', () {
    testWidgets('announces the new mode', (tester) async {
      const announcements = {
        TimelineMode.live:
            '🔴 - Live! Shows all timeline events as they happen',
        TimelineMode.always: '🔴 - Always shows the timeline',
        TimelineMode.reportOnError:
            '🔴 - Shows the timeline when the test fails',
        // ignore: deprecated_member_use_from_same_package
        TimelineMode.record: '🔴 - Recording, but only showing on test failure',
        TimelineMode.off: '⏸︎ - Timeline recording is off',
      };
      for (final MapEntry(key: mode, value: announcement)
          in announcements.entries) {
        final other = mode == TimelineMode.off ? TimelineMode.live : null;
        await captureConsoleOutput(() async {
          timeline.mode = other ?? TimelineMode.off;
        });
        final output = await captureConsoleOutput(() async {
          timeline.mode = mode;
        });
        expect(output, '$announcement\n');
      }
    });

    testWidgets('to the current mode prints nothing', (tester) async {
      await captureConsoleOutput(() async {
        timeline.mode = TimelineMode.reportOnError;
      });
      final output = await captureConsoleOutput(() async {
        timeline.mode = TimelineMode.reportOnError;
      });
      expect(output, isEmpty);
    });

    testWidgets('globally is not possible within a test', (tester) async {
      expect(
        () => globalTimelineMode = TimelineMode.reportOnError,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains(
              'Cannot change global timeline mode within a test.\n'
              'Use "timeline.mode" instead.\n'
              'Example: timeline.mode = TimelineMode.reportOnError;',
            ),
          ),
        ),
      );
    });
  });

  group('live', () {
    testWidgets('prints every event as it happens', (tester) async {
      // The screenshots are written after the test, by a tearDown of the
      // timeline. Registered before the timeline exists, this one runs after.
      final screenshots = <File>[];
      addTearDown(() {
        for (final file in screenshots) {
          expect(file.readAsBytesSync(), isNotEmpty, reason: file.path);
        }
      });

      final output = await _capture(TimelineMode.live, () async {
        await tapCounter(tester);
      });

      final events = printedEvents(output);
      expect(events.map((e) => e.summary), tapCounterEvents);
      for (final event in events) {
        // The VM keeps the frame of this file that called in, dart2wasm only
        // the frame of the library with tapCounter.
        expect(
          event.caller,
          anyOf(
            contains('timeline_mode_test.dart:'),
            contains('timeline_test_widget.dart:'),
          ),
        );
        expect(event.timestamp, isNotNull);
        if (kIsWeb) {
          expect(
            event.screenshot,
            'Screenshot links are not supported in the timeline on platform '
            'web.',
          );
        } else {
          expect(event.screenshot, startsWith('file://'));
          screenshots.add(File(event.screenshot!.substring('file://'.length)));
        }
      }
    });

    testWidgets('prints the drags until the target is found', (tester) async {
      final output = await _capture(TimelineMode.live, () async {
        await _dragList(tester, maxIteration: 23);
      });

      expect(_dragEvents(output), [
        _scrollingToTheEnd,
        'Drag Event: Scrolling to fully reveal $_dragTarget.',
        _foundAfter23Drags,
      ]);
    });

    testWidgets('prints the drags that did not find the target',
        (tester) async {
      final output = await _capture(TimelineMode.live, () async {
        TestFailure? failure;
        try {
          await _dragList(tester, maxIteration: 10);
        } on TestFailure catch (e) {
          failure = e;
        }
        expect(failure, isNotNull, reason: 'The target is out of reach');
      });

      expect(_dragEvents(output), [
        _scrollingToTheEnd,
        _notVisibleAfter10Drags,
      ]);
    });

    testWidgets('stops recording when turned off', (tester) async {
      final output = await _capture(TimelineMode.live, () async {
        await tapCounter(tester);
        timeline.mode = TimelineMode.off;
        await act.tap(spotIcon(Icons.clear));
        spotText('Counter: 0').existsOnce();
      });

      expect(printedEvents(output).map((e) => e.summary), tapCounterEvents);
      expect(output, contains('⏸︎ - Timeline recording is off'));
      expect(timeline.events, hasLength(tapCounterEvents.length));
    });
  });

  for (final mode in [TimelineMode.reportOnError, TimelineMode.always]) {
    group(mode.name, () {
      testWidgets('records every event without printing it', (tester) async {
        final output = await _capture(mode, () async {
          await tapCounter(tester);
        });

        expect(output, isEmpty);
        expect(
          timeline.events.map((e) => '${e.eventType.label}: ${e.details}'),
          tapCounterEvents,
        );
      });
    });
  }

  group('off', () {
    testWidgets('records nothing', (tester) async {
      final output = await _capture(TimelineMode.off, () async {
        await tapCounter(tester);
        await _dragList(tester, maxIteration: 23);
      });

      expect(output, isEmpty);
      expect(timeline.events, isEmpty);
    });
  });
}

/// Switches the timeline to [mode] and returns what [body] printed after that.
Future<String> _capture(
  TimelineMode mode,
  Future<void> Function() body,
) async {
  await captureConsoleOutput(() async {
    timeline.mode = mode;
  });
  return await captureConsoleOutput(body);
}

final _dragTarget = spotText('Item at index: 27', whole: true);

final _scrollingToTheEnd = 'Drag Event: Scrolling to the end, beginning at '
    'Offset(dx,dy) in order to find $_dragTarget.';

final _foundAfter23Drags = 'Drag Event: Target $_dragTarget found after 23 '
    'drags. Total dragged offset: Offset(dx,dy)';

final _notVisibleAfter10Drags = 'Drag Error Event: $_dragTarget is not '
    'visible after dragging 10 times and a total dragged offset of '
    'Offset(dx,dy).';

Future<void> _dragList(WidgetTester tester, {required int maxIteration}) async {
  await tester.pumpWidget(
    const DragUntilVisibleSingleDirectionTestWidget(axis: Axis.vertical),
  );
  await act.dragUntilVisible(
    dragStart: spotText('Item at index: 3', whole: true),
    dragTarget: _dragTarget,
    moveStep: const Offset(0, -100),
    maxIteration: maxIteration,
  );
}

/// The drag events in [output], without the offsets that depend on the layout.
List<String> _dragEvents(String output) {
  final offset = RegExp(r'Offset\([^)]*\)');
  return printedEvents(output)
      .where((e) => e.type.startsWith('Drag'))
      .map((e) => e.summary.replaceAll(offset, 'Offset(dx,dy)'))
      .toList();
}
