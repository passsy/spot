import 'dart:core';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

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
      ..color = const Color(0xFF00FFFF)
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
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, 10.0, circlePaint);

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}
