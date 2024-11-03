import 'dart:core';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// An annotator that can draw on a screenshot image.
abstract class ScreenshotAnnotator {
  /// Annotate the [image] with additional graphics.
  Future<ui.Image> annotate(ui.Image image);

  /// The name of the annotator.
  String get name;
}

/// Annotator that draws a crosshair at a given position.
class CrosshairAnnotator implements ScreenshotAnnotator {
  /// The center position of the crosshair.
  final Offset centerPosition;

  @override
  String get name => 'Crosshair Annotator';

  /// Creates a [CrosshairAnnotator] with a [centerPosition].
  const CrosshairAnnotator({required this.centerPosition});

  Offset _translateOffset(ui.Image image) {
    // ignore: deprecated_member_use
    final view = WidgetsBinding.instance.renderView.size;
    final imageHeight = image.height;
    final imageWidth = image.width;
    // Calculate the relative position in the view
    final double relativeX = centerPosition.dx / view.width;
    final double relativeY = centerPosition.dy / view.height;

    // Calculate the new offset in the image dimensions
    final double newDx = relativeX * imageWidth;
    final double newDy = relativeY * imageHeight;

    return Offset(newDx, newDy);
  }

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final position = _translateOffset(image);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(position.dx, position.dy - 20),
      Offset(position.dx, position.dy + 20),
      paint,
    );

    canvas.drawLine(
      Offset(position.dx - 20, position.dy),
      Offset(position.dx + 20, position.dy),
      paint,
    );

    final circlePaint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, 10.0, circlePaint);

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}

class HighlightAnnotator implements ScreenshotAnnotator {
  HighlightAnnotator.rects(this.rects);

  factory HighlightAnnotator.elements(List<Element> elements) {
    final binding = TestWidgetsFlutterBinding.instance;
    final view = binding.platformDispatcher.implicitView;
    final devicePixelRatio = view?.devicePixelRatio ?? 1.0;

    final List<Rect> rects = [];
    for (final element in elements) {
      final renderObject = element.renderObject;
      if (renderObject is! RenderBox?) continue;
      if (renderObject == null) continue;
      final box = renderObject.size;
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final bottomRight =
          renderObject.localToGlobal(box.bottomRight(Offset.zero));
      rects.add(
        Rect.fromPoints(
          topLeft * devicePixelRatio,
          bottomRight * devicePixelRatio,
        ),
      );
    }
    return HighlightAnnotator.rects(rects);
  }

  factory HighlightAnnotator.element(Element element) {
    return HighlightAnnotator.elements([element]);
  }

  final List<Rect> rects;

  @override
  String get name => 'Highlight Elements Annotator';

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}
