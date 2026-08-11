// ignore_for_file: prefer_const_constructors

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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

      // What the reuse is: both screenshots hold a handle on the one image the
      // cache rasterized. Rasterizing twice would produce equal pixels too, so
      // only the shared handle tells the two apart. Asserted before the pixels
      // below, because reading those materializes the image and drops it.
      expect(await _sharesRasterWith(first, second), isTrue);

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
    testWidgets('an annotator with the same props is rendered once', (
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

    testWidgets('the timeline shares one annotation between screenshots', (
      tester,
    ) async {
      // What every assertion in spot actually does: takeScreenshotSync queues
      // the rendering and the timeline drains that queue after the test, while
      // rendering its report. The direct renderAnnotationLayers calls above
      // never touch that path.
      final renders = <String>[];
      final screenshots = <Screenshot>[];
      // Registered before the timeline exists, so it runs after the timeline's
      // own teardown, which is the thing that drains the queue.
      addTearDown(() {
        expect(renders, ['deferred']);
        expect(
          identical(
            screenshots[0].annotations.single,
            screenshots[1].annotations.single,
          ),
          isTrue,
        );
      });

      timeline.mode = TimelineMode.always;
      await _pumpColor(tester, Color(0xffff0000));

      for (final name in ['first', 'second']) {
        screenshots.add(
          timeline.takeScreenshotSync(
            name: name,
            annotators: [_CountingAnnotator('deferred', renders)],
          ),
        );
      }
      expect(renders, isEmpty, reason: 'rendering is deferred, not immediate');
      // On web the timeline guards every processPendingScreenshots() call
      // behind !kIsWeb, so the queue this test is about is never drained.
    }, skip: kIsWeb);

    testWidgets('an annotation is not reused across pixel ratios', (
      tester,
    ) async {
      // The physical size stays put while the ratio doubles, so the image
      // keeps its pixel dimensions and only the logical view shrinks.
      // ArrowAnnotator scales its coordinates by the device pixel ratio, so
      // the same annotator draws the arrow somewhere else.
      tester.view.physicalSize = const Size(200, 200);
      addTearDown(tester.view.reset);

      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(ColoredBox(color: Color(0xffffffff)));
      final thin = await takeScreenshot(
        print: false,
        annotators: [
          ArrowAnnotator(start: Offset(10, 10), end: Offset(40, 40))
        ],
      );

      tester.view.devicePixelRatio = 2.0;
      await tester.pumpWidget(ColoredBox(color: Color(0xffffffff)));
      final wide = await takeScreenshot(
        print: false,
        annotators: [
          ArrowAnnotator(start: Offset(10, 10), end: Offset(40, 40))
        ],
      );

      expect(await _pngOf(thin.annotations.single),
          isNot(await _pngOf(wide.annotations.single)));
    });

    testWidgets('an annotation is not reused across view sizes', (
      tester,
    ) async {
      // CrosshairAnnotator places its crosshair by where the position falls in
      // the view, not in the image. A widget-scoped capture of a fixed-size
      // boundary keeps its pixel dimensions while the view around it grows, so
      // neither the image size nor the pixel ratio moves and only the view
      // tells the two overlays apart.
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Future<Screenshot> captureBox() async {
        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              key: const Key('box'),
              child: const SizedBox(
                width: 100,
                height: 100,
                child: ColoredBox(color: Color(0xffffffff)),
              ),
            ),
          ),
        );
        return takeScreenshot(
          print: false,
          element: tester.element(find.byKey(const Key('box'))),
          annotators: [CrosshairAnnotator(centerPosition: Offset(50, 50))],
        );
      }

      tester.view.physicalSize = const Size(400, 400);
      final inSmallView = await captureBox();

      tester.view.physicalSize = const Size(800, 800);
      final inLargeView = await captureBox();

      expect(inSmallView.width, inLargeView.width);
      expect(
        await _pngOf(inSmallView.annotations.single),
        isNot(await _pngOf(inLargeView.annotations.single)),
      );
    });

    testWidgets('props holding a list are compared by its items', (
      tester,
    ) async {
      // Separately built lists, equal item by item. This is what a record key
      // could not express, because a record compares its fields with == and
      // two distinct lists never are.
      await _pumpColor(tester, Color(0xffff0000));
      final screenshot = await takeScreenshot(print: false);

      final renders = <String>[];
      await renderAnnotationLayers(screenshot, [
        _ListAnnotator([1, 2], renders)
      ]);
      await renderAnnotationLayers(screenshot, [
        _ListAnnotator([1, 2], renders)
      ]);
      await renderAnnotationLayers(screenshot, [
        _ListAnnotator([1, 3], renders)
      ]);

      expect(renders, ['1,2', '1,3']);
    });

    testWidgets('an annotator that draws something new is never reused', (
      tester,
    ) async {
      // The instance is the same one both times, so it is equal to itself
      // whether or not it implements equality. Only opting in may grant reuse,
      // or a stateful annotator silently attaches its first draw to every
      // later screenshot.
      await _pumpColor(tester, Color(0xffff0000));
      final renders = <String>[];
      final counter = _SequenceAnnotator(renders);

      await takeScreenshot(print: false, annotators: [counter]);
      await takeScreenshot(print: false, annotators: [counter]);

      expect(renders, ['1', '2']);
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

  testWidgets('the built-in annotators report their inputs as props', (
    tester,
  ) async {
    // Props are compared by their items, so the rects and labels of two
    // separately built highlights match without either implementing equality.
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a'])
          .props,
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a'])
          .props,
    );
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a'])
          .props,
      isNot(
        HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 2, 2)], labels: ['a'])
            .props,
      ),
    );
    expect(
      HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['a'])
          .props,
      isNot(
        HighlightAnnotator.rects([Rect.fromLTWH(0, 0, 1, 1)], labels: ['b'])
            .props,
      ),
    );
    expect(
      CrosshairAnnotator(centerPosition: Offset(1, 2)).props,
      CrosshairAnnotator(centerPosition: Offset(1, 2)).props,
    );
    expect(
      CrosshairAnnotator(centerPosition: Offset(1, 2)).props,
      isNot(CrosshairAnnotator(centerPosition: Offset(3, 4)).props),
    );
    expect(
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)).props,
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)).props,
    );
    expect(
      ArrowAnnotator(start: Offset.zero, end: Offset(1, 1)).props,
      isNot(ArrowAnnotator(start: Offset.zero, end: Offset(2, 2)).props),
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
  List<Object?> get props => [id];
}

/// Keys on a list, which is the prop a record could not have carried.
class _ListAnnotator implements ScreenshotAnnotator {
  _ListAnnotator(this.marks, this.renders);

  final List<int> marks;
  final List<String> renders;

  @override
  String get name => 'List Annotator ${marks.join(',')}';

  @override
  List<Object?> get props => [marks];

  @override
  Future<ui.Image> annotate(ui.Image image) {
    renders.add(marks.join(','));
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Paint()..color = const Color(0x00000000),
    );
    return recorder.endRecording().toImage(image.width, image.height);
  }
}

/// Draws a different number every time, so it has no props to be found by.
///
/// The kind of annotator the reuse must keep its hands off.
class _SequenceAnnotator implements ScreenshotAnnotator {
  _SequenceAnnotator(this.renders);

  final List<String> renders;
  int _drawn = 0;

  @override
  String get name => 'Sequence Annotator';

  @override
  List<Object?>? get props => null;

  @override
  Future<ui.Image> annotate(ui.Image image) {
    _drawn++;
    renders.add('$_drawn');
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      Rect.fromLTWH(0, 0, _drawn.toDouble(), _drawn.toDouble()),
      Paint()..color = const Color(0x11000000),
    );
    return recorder.endRecording().toImage(image.width, image.height);
  }
}

Future<Uint8List> _pngOf(ScreenshotAnnotation annotation) async {
  final binding = TestWidgetsFlutterBinding.instance;
  return (await binding.runAsync(annotation.image.readPngBytes))!;
}

/// Whether both screenshots were made from a single rasterization.
///
/// A screenshot holds a handle on the image it was made from, and the raster
/// cache hands out clones of the one it keeps, so two screenshots of the same
/// raster hold clones of each other. Rasterizing per screenshot instead would
/// give each an unrelated image, which is what pixel equality cannot see.
///
/// Only answers before either screenshot is materialized, because that
/// disposes the handle and later reads decode fresh images from the bytes.
Future<bool> _sharesRasterWith(Screenshot a, Screenshot b) async {
  expect(
    a.isMaterialized || b.isMaterialized,
    isFalse,
    reason: 'the handles this compares are already gone',
  );
  return (await a.readImage()).isCloneOf(await b.readImage());
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
