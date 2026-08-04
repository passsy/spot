import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

void main() {
  test('timeline frame data survives gzip round-trip', () {
    final encoded = compressTimelineFrameData(
      widgetTree: 'RenderView\n  Text("Large tree")',
      structuredWidgetTree: {
        'captureWidth': 800,
        'captureHeight': 600,
        'root': {
          'id': '0',
          'name': 'RenderView',
          'children': [
            {'id': '1', 'name': 'Text', 'children': <Object>[]},
          ],
        },
      },
    );

    final decoded = decompressTimelineFrameData(encoded);

    expect(decoded.widgetTree, contains('Large tree'));
    expect(decoded.structuredWidgetTree['captureWidth'], 800);
    expect((decoded.structuredWidgetTree['root'] as Map)['name'], 'RenderView');
  });

  TimelineEvent event({
    required int index,
    String? screenshotUrl,
    int? frameNumber,
    int? renderedFrameNumber,
  }) {
    return TimelineEvent(
      eventType: 'Assertion $index',
      color: null,
      screenshotUrl: screenshotUrl,
      overlayUrls: const ['./screenshots/example-overlay.png'],
      details: 'Example event $index',
      timestamp: DateTime(2026, 8, 4, 0, 0, 0, index).toIso8601String(),
      wallTimestamp: DateTime(
        2026,
        8,
        4,
        9,
        30,
        0,
        index * 7,
      ).toIso8601String(),
      caller: 'example_test.dart:$index',
      ideLink: null,
      ideName: null,
      sourcePath: 'test/example_test.dart',
      callerLine: 2,
      isFailure: false,
      widgetTree: 'RenderView\n  Text("Example $index")',
      structuredWidgetTree: {
        'captureWidth': 800,
        'captureHeight': 600,
        'root': {
          'id': '0',
          'name': 'Text',
          'description': 'Text("Example $index")',
          'elementType': 'StatelessElement',
          'renderObjectType': 'RenderParagraph',
          'offstage': false,
          'bounds': {'x': 10, 'y': 20, 'width': 100, 'height': 30},
          'widgetProperties': const [
            {'name': 'data', 'value': 'Example'},
          ],
          'renderProperties': const [],
          'children': const [],
        },
      },
      frameNumber: frameNumber,
      renderedFrameNumber: renderedFrameNumber,
    );
  }

  test(
    'timelines preserve relative screenshot URLs',
    () async {
      final html = await renderTimelineWithJaspr(
        [event(index: 1, screenshotUrl: './screenshots/example.png')],
        sourceFiles: const {
          'test/example_test.dart': TimelineSourceFile(
            path: 'test/example_test.dart',
            lines: ['testWidgets(', '  expect(value, isTrue);', ');'],
            truncated: false,
          ),
        },
      );

      expect(html, isNot(contains('<base href="/"/>')));
      expect(html, contains('<script>'));
      expect(html, isNot(contains('src="/script.js"')));
      expect(html, contains('src="./screenshots/example.png"'));
      expect(html, contains('./screenshots/example-overlay.png'));
      expect(html, contains('Widget tree'));
      expect(html, contains('Event details'));
      expect(
        html,
        contains('"sourcePath":"test/example_test.dart","callerLine":2'),
      );
      expect(html, contains('expect(value, isTrue);'));
      expect(html, contains('.source-line.is-caller'));
      expect(html, contains('Tree text'));
      expect(html, contains('Raw data'));
      expect(html, contains('.interactive-inspector'));
      expect(html, contains('.inspector-sidebar'));
      expect(html, contains('.widget-outline'));
      expect(html, contains('Resize timeline and inspector'));
      expect(html, contains('.resize-handle'));
      expect(html, isNot(contains('class="lane-label"')));
      expect(html, contains(r'"widgetTree":"RenderView\n'));
      expect(html, contains('"structuredWidgetTree":{'));
      expect(html, contains('"bounds":{"x":10'));

      // One stylesheet, holding every component's rules. Jaspr can register
      // StyleRules through `Document(styles:)` as well, which would emit a
      // second <style>, and having both is how rules end up in whichever of
      // the two the last person to touch them happened to open.
      expect(RegExp('<style>').allMatches(html), hasLength(1));
      expect(html, contains('.snackbar'));
      expect(html, contains('@keyframes fadein'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'timelines render 200 selectable events',
    () async {
      final html = await renderTimelineWithJaspr([
        for (var index = 1; index <= 200; index++)
          event(
            index: index,
            screenshotUrl: index.isEven
                ? './screenshots/example-$index.png'
                : null,
          ),
      ]);

      expect(html, contains('200 events'));
      expect(html, contains('200 frames'));
      expect(html, contains('100 captured'));
      expect(html, contains('Frame 1'));
      expect(html, contains('Frame 100'));
      expect(html, contains('--frame-count: 200'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'multiple assertions on one frame share one filmstrip capture',
    () async {
      final html = await renderTimelineWithJaspr([
        event(
          index: 1,
          frameNumber: 1,
          screenshotUrl: './screenshots/frame-1.png',
        ),
        event(
          index: 2,
          frameNumber: 1,
          screenshotUrl: './screenshots/frame-1.png',
        ),
      ]);

      expect(html, contains('2 events'));
      expect(html, contains('1 frame'));
      expect(html, contains('1 captured'));
      expect(html, contains('2 assertions'));
      expect(html, contains('--frame-count: 1'));
      expect(html, contains('class="frame-events"'));
      expect(RegExp('class="ruler-cell"').allMatches(html), hasLength(1));
      expect(html, contains('object-position: left center'));
      // One filmstrip capture for the frame, however many assertions share it.
      // Scoped to the filmstrip because the report also shows the selected
      // event's capture in the capture pane and as a thumbnail next to it.
      expect(
        RegExp(
          r'alt="Capture for frame 1" src="\./screenshots/frame-1\.png"',
        ).allMatches(html),
        hasLength(1),
      );
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'hot-restart timelines load the shared script from the server root',
    () async {
      final html = await renderTimelineWithJaspr(
        [],
        inlineScripts: false,
        hotRestart: true,
      );

      expect(html, contains('<script src="/script.js" defer></script>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );

  test(
    'external standalone timelines use a relative client script',
    () async {
      final html = await renderTimelineWithJaspr([], inlineScripts: false);

      expect(html, contains('<script src="script.js" defer></script>'));
    },
    skip: kIsWeb ? 'Jaspr server rendering requires the Dart VM' : false,
  );
}
