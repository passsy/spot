import 'dart:core';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

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

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(centerPosition.dx, centerPosition.dy - 20),
      Offset(centerPosition.dx, centerPosition.dy + 20),
      paint,
    );

    canvas.drawLine(
      Offset(centerPosition.dx - 20, centerPosition.dy),
      Offset(centerPosition.dx + 20, centerPosition.dy),
      paint,
    );

    final circlePaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(centerPosition, 10.0, circlePaint);

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}
