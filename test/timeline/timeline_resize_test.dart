import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';

void main() {
  TimelineFrameGroup frame(int number, List<int> eventIndexes) {
    return TimelineFrameGroup(
      frameNumber: number,
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
