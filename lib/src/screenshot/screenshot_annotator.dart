import 'dart:core';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
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
  HighlightAnnotator.rects(
    this.rects, {
    this.color = const Color(0xFFFF00FF),
    this.labels,
  }) : assert(labels == null || rects.length == labels.length);

  factory HighlightAnnotator.elements(List<Element> elements) {
    final binding = TestWidgetsFlutterBinding.instance;
    final view = binding.platformDispatcher.implicitView;
    final devicePixelRatio = view?.devicePixelRatio ?? 1.0;

    final List<Rect> rects = [];
    final List<String> labels = [];
    for (int index = 0; index < elements.length; index++) {
      final element = elements[index];
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
      labels.add('${element.toStringShort()} #$index');
    }
    return HighlightAnnotator.rects(rects, labels: labels);
  }

  factory HighlightAnnotator.element(Element element) {
    return HighlightAnnotator.elements([element]);
  }

  final List<Rect> rects;

  final List<String>? labels;

  final Color color;

  @override
  String get name => 'Highlight Elements Annotator';

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final fontLoader = FontLoader('Test-Roboto');
    final fontBytes =
        await rootBundle.load('packages/spot/lib/assets/Roboto-Regular.ttf');
    fontLoader.addFont(Future.sync(() => fontBytes));
    await fontLoader.load();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (int index = 0; index < rects.length; index++) {
      final rect = rects[index];
      canvas.drawRect(rect, paint);
      if (labels != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: labels![index],
            style: TextStyle(
              color: color,
              fontSize: 20.0,
              fontFamily: 'Test-Roboto',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        // above
        textPainter.paint(
          canvas,
          rect.topLeft - Offset(0, textPainter.height + 8),
        );
        // below
        textPainter.paint(
          canvas,
          rect.bottomLeft + const Offset(0, 8),
        );
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}
