// ignore_for_file: prefer_const_constructors

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';

void main() {
  group('raster reuse within a frame', () {
    testWidgets('two screenshots of one frame show the same thing', (
      tester,
    ) async {
      await _pumpColor(tester, Color(0xffff0000));

      final first = timeline.takeScreenshotSync(name: 'first');
      final second = timeline.takeScreenshotSync(name: 'second');

      expect(await _pixelAt(first, 50, 50), Color(0xffff0000));
      expect(await _pixelAt(second, 50, 50), Color(0xffff0000));
    });

    testWidgets('a screenshot after a frame shows the new content', (
      tester,
    ) async {
      await _pumpColor(tester, Color(0xffff0000));
      final red = timeline.takeScreenshotSync(name: 'red');

      await _pumpColor(tester, Color(0xff00ff00));
      final green = timeline.takeScreenshotSync(name: 'green');

      expect(await _pixelAt(red, 50, 50), Color(0xffff0000));
      expect(await _pixelAt(green, 50, 50), Color(0xff00ff00));
    });

    testWidgets('each repaint boundary is rastered on its own', (
      tester,
    ) async {
      // Rasters are cached per repaint boundary, not per frame. Two
      // widget-scoped screenshots of one frame must not hand each other the
      // raster of the wrong layer.
      tester.view.physicalSize = const Size(100, 100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: const [
              RepaintBoundary(
                key: Key('top'),
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: ColoredBox(color: Color(0xffff0000)),
                ),
              ),
              RepaintBoundary(
                key: Key('bottom'),
                child: SizedBox(
                  width: 100,
                  height: 50,
                  child: ColoredBox(color: Color(0xff00ff00)),
                ),
              ),
            ],
          ),
        ),
      );

      final top = timeline.takeScreenshotSync(
        name: 'top',
        element: tester.element(find.byKey(Key('top'))),
      );
      final bottom = timeline.takeScreenshotSync(
        name: 'bottom',
        element: tester.element(find.byKey(Key('bottom'))),
      );

      expect(await _pixelAt(top, 50, 25), Color(0xffff0000));
      expect(await _pixelAt(bottom, 50, 25), Color(0xff00ff00));
    });
  });

  group('annotation reuse within a test', () {
    testWidgets('an annotator that compares equal is rendered once', (
      tester,
    ) async {
      await _pumpColor(tester, Color(0xffff0000));
      final screenshot = await takeScreenshot(print: false);

      final renders = <String>[];
      await renderAnnotationLayers(screenshot, [
        _CountingAnnotator('a', renders),
      ]);
      await renderAnnotationLayers(screenshot, [
        _CountingAnnotator('a', renders),
      ]);

      expect(renders, ['a']);
      expect(screenshot.annotations, hasLength(2));
      expect(
        identical(screenshot.annotations[0], screenshot.annotations[1]),
        isTrue,
      );
    });

    testWidgets('annotators that differ are both rendered', (tester) async {
      await _pumpColor(tester, Color(0xffff0000));
      final screenshot = await takeScreenshot(print: false);

      final renders = <String>[];
      await renderAnnotationLayers(screenshot, [
        _CountingAnnotator('a', renders),
      ]);
      await renderAnnotationLayers(screenshot, [
        _CountingAnnotator('b', renders),
      ]);

      expect(renders, ['a', 'b']);
    });

    testWidgets('a previous test leaves nothing behind', (tester) async {
      // Same annotator id as the two tests above. Their annotations hold
      // images those tests have since disposed.
      await _pumpColor(tester, Color(0xffff0000));
      final screenshot = await takeScreenshot(print: false);

      final renders = <String>[];
      await renderAnnotationLayers(screenshot, [
        _CountingAnnotator('a', renders),
      ]);

      expect(renders, ['a']);
    });
  });

  testWidgets('the built-in annotators compare by their inputs', (
    tester,
  ) async {
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a']),
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a']),
    );
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a']),
      isNot(
        HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 2, 2)], labels: ['a']),
      ),
    );
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a']),
      isNot(
        HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['b']),
      ),
    );
    expect(
      CrosshairAnnotator(centerPosition: Offset(1, 2)),
      CrosshairAnnotator(centerPosition: Offset(1, 2)),
    );
    expect(
      CrosshairAnnotator(centerPosition: Offset(1, 2)),
      isNot(CrosshairAnnotator(centerPosition: Offset(3, 4))),
    );
    expect(
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)),
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)),
    );
    expect(
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)),
      isNot(ArrowAnnotator(start: Offset.zero, end: Offset(2, 2))),
    );
  });
}

Future<void> _pumpColor(WidgetTester tester, Color color) async {
  tester.view.physicalSize = const Size(100, 100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ColoredBox(color: color));
}

/// Draws nothing, and records that it was asked to.
///
/// [renders] is deliberately not part of the equality, so two annotators with
/// the same [id] compare equal while still reporting to the same test.
class _CountingAnnotator implements ScreenshotAnnotator {
  _CountingAnnotator(this.id, this.renders);

  final String id;
  final List<String> renders;

  @override
  String get name => 'Counting Annotator $id';

  @override
  Future<ui.Image> annotate(ui.Image image) {
    renders.add(id);
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Paint()..color = const Color(0x00000000),
    );
    return recorder.endRecording().toImage(image.width, image.height);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CountingAnnotator &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

Future<Color> _pixelAt(Screenshot screenshot, int x, int y) async {
  final binding = TestWidgetsFlutterBinding.instance;
  final image = (await binding.runAsync(
    () async => img.decodePng(await screenshot.readPngBytes()),
  ))!;
  final pixel = image.getPixel(x, y);
  return Color.fromARGB(
    pixel.a.toInt(),
    pixel.r.toInt(),
    pixel.g.toInt(),
    pixel.b.toInt(),
  );
}
