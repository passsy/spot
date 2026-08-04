import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

void main() {
  TimelineFrameGroup frame(
    int number,
    List<int> eventIndexes, {
    int? renderedFrameNumber,
  }) {
    return TimelineFrameGroup(
      frameNumber: number,
      renderedFrameNumber: renderedFrameNumber ?? number,
      eventIndexes: eventIndexes,
      screenshotUrl: null,
    );
  }

  test('timeline resizing preserves space for the inspector', () {
    expect(
      resizedTimelineHeight(
        pointerY: 400,
        containerTop: 100,
        containerHeight: 800,
      ),
      252,
    );
    expect(
      resizedTimelineHeight(
        pointerY: 1000,
        containerTop: 100,
        containerHeight: 800,
      ),
      566,
    );
    expect(
      resizedTimelineHeight(
        pointerY: 0,
        containerTop: 100,
        containerHeight: 800,
      ),
      150,
    );
  });

  test('pane resizing follows the pointer and respects bounds', () {
    expect(
      resizedPanePercent(
        pointer: 700,
        containerStart: 100,
        containerExtent: 1000,
        minimum: 20,
        maximum: 80,
      ),
      60,
    );
    expect(
      resizedPanePercent(
        pointer: 50,
        containerStart: 100,
        containerExtent: 1000,
        minimum: 20,
        maximum: 80,
      ),
      20,
    );
    expect(
      resizedPanePercent(
        pointer: 1200,
        containerStart: 100,
        containerExtent: 1000,
        minimum: 20,
        maximum: 80,
      ),
      80,
    );
  });

  test('tree resizing accounts for the toolbar above it', () {
    expect(
      resizedPanePercent(
        pointer: 444,
        containerStart: 100,
        containerExtent: 1000,
        leadingInset: 34,
        minimum: 25,
        maximum: 82,
      ),
      31,
    );
  });

  test('keyboard resizing uses the same bounds', () {
    expect(adjustedPaneSize(22, -4, minimum: 20, maximum: 80), 20);
    expect(adjustedPaneSize(78, 4, minimum: 20, maximum: 80), 80);
    expect(adjustedPaneSize(57, 4, minimum: 20, maximum: 80), 61);
  });

  test('horizontal navigation lands on the first event of the frame', () {
    final frames = [
      frame(1, [0, 1]),
      frame(2, [2, 3, 4]),
      frame(3, [5]),
    ];

    expect(adjacentFrameEventIndex(frames, null, 1), 0);
    expect(adjacentFrameEventIndex(frames, null, -1), 5);
    // From the second event of frame 1 into frame 2: its first event, not the
    // one that happens to sit in the same row.
    expect(adjacentFrameEventIndex(frames, 1, 1), 2);
    expect(adjacentFrameEventIndex(frames, 3, 1), 5);
    expect(adjacentFrameEventIndex(frames, 5, -1), 2);
    // Backwards out of the first frame stays on its first event.
    expect(adjacentFrameEventIndex(frames, 1, -1), 0);
    expect(adjacentFrameEventIndex(frames, 0, -1), 0);
  });

  group('gaps between recorded frames', () {
    TimelineEvent event({
      required int testClockMs,
      required int wallClockMs,
      required int renderedFrameNumber,
    }) {
      return TimelineEvent(
        eventType: 'Assertion',
        color: null,
        screenshotUrl: null,
        overlayUrls: const [],
        details: 'example',
        timestamp: DateTime(
          2026,
          8,
          4,
          12,
          0,
          0,
          testClockMs,
        ).toIso8601String(),
        wallTimestamp: DateTime(
          2026,
          8,
          4,
          12,
          0,
          0,
          wallClockMs,
        ).toIso8601String(),
        caller: 'example_test.dart:1',
        ideLink: null,
        ideName: null,
        sourcePath: null,
        callerLine: null,
        isFailure: false,
        widgetTree: '',
        structuredWidgetTree: const {},
        renderedFrameNumber: renderedFrameNumber,
      );
    }

    test('two frames the test rendered nothing between have no gap', () {
      final events = [
        event(testClockMs: 0, wallClockMs: 0, renderedFrameNumber: 7),
        event(testClockMs: 16, wallClockMs: 2, renderedFrameNumber: 8),
      ];

      expect(gapBetween(events, frame(1, [0]), frame(2, [1])), isNull);
    });

    test('the frames rendered in between are the gap', () {
      final events = [
        event(testClockMs: 0, wallClockMs: 0, renderedFrameNumber: 7),
        event(testClockMs: 500, wallClockMs: 120, renderedFrameNumber: 307),
      ];

      final gap = gapBetween(
        events,
        frame(1, [0], renderedFrameNumber: 7),
        frame(2, [1], renderedFrameNumber: 307),
      );

      // 7 and 307 were both recorded in, the 299 between them were not.
      expect(gap!.frames, 299);
      expect(gap.testClock, const Duration(milliseconds: 500));
      expect(gap.wallClock, const Duration(milliseconds: 120));
    });

    test('a gap is measured from the last event to the next one', () {
      final events = [
        event(testClockMs: 0, wallClockMs: 0, renderedFrameNumber: 1),
        // Same frame as the one before, and the last thing before the gap.
        event(testClockMs: 30, wallClockMs: 8, renderedFrameNumber: 1),
        event(testClockMs: 130, wallClockMs: 40, renderedFrameNumber: 60),
      ];

      final gap = gapBetween(
        events,
        frame(1, [0, 1], renderedFrameNumber: 1),
        frame(2, [2], renderedFrameNumber: 60),
      )!;

      expect(gap.testClock, const Duration(milliseconds: 100));
      expect(gap.wallClock, const Duration(milliseconds: 32));
    });

    test('gap columns sit between the frames, and nowhere else', () {
      final events = [
        event(testClockMs: 0, wallClockMs: 0, renderedFrameNumber: 1),
        event(testClockMs: 100, wallClockMs: 30, renderedFrameNumber: 90),
        event(testClockMs: 116, wallClockMs: 33, renderedFrameNumber: 91),
      ];
      final frames = [
        frame(1, [0], renderedFrameNumber: 1),
        frame(2, [1], renderedFrameNumber: 90),
        frame(3, [2], renderedFrameNumber: 91),
      ];

      final columns = timelineTrackColumns(events, frames);

      // frame, gap, frame, frame: no gap before the first, none between the
      // two adjacent ones.
      expect(columns.map((column) => column.gap == null), [
        true,
        false,
        true,
        true,
      ]);
      expect(columns[1].gap!.frames, 88);
    });
  });

  test('vertical navigation stays within the selected frame', () {
    final frames = [
      frame(1, [0, 1]),
      frame(2, [2, 3, 4]),
    ];

    expect(adjacentEventInFrameIndex(frames, null, 1), 0);
    expect(adjacentEventInFrameIndex(frames, null, -1), 1);
    expect(adjacentEventInFrameIndex(frames, 2, 1), 3);
    expect(adjacentEventInFrameIndex(frames, 3, 1), 4);
    expect(adjacentEventInFrameIndex(frames, 4, 1), 4);
    expect(adjacentEventInFrameIndex(frames, 2, -1), 2);
  });

  test('node collection can limit automatic expansion depth', () {
    final tree = <String, dynamic>{
      'id': '0',
      'children': [
        {
          'id': '1',
          'children': [
            {
              'id': '2',
              'children': [
                {'id': '3', 'children': <Object>[]},
              ],
            },
          ],
        },
      ],
    };

    expect(collectStructuredWidgetNodeIds(tree, maxDepth: 2), {'0', '1', '2'});
    expect(collectStructuredWidgetNodeIds(tree), {'0', '1', '2', '3'});
  });
}
