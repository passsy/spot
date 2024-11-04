import 'dart:core';
import 'dart:math' as math;
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

    const double size = 100.0;

    final lineShadowPaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawLine(
      Offset(position.dx, position.dy - size / 2),
      Offset(position.dx, position.dy + size / 2),
      lineShadowPaint,
    );

    canvas.drawLine(
      Offset(position.dx - size / 2, position.dy),
      Offset(position.dx + size / 2, position.dy),
      lineShadowPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(position.dx, position.dy - size / 2),
      Offset(position.dx, position.dy + size / 2),
      linePaint,
    );

    canvas.drawLine(
      Offset(position.dx - size / 2, position.dy),
      Offset(position.dx + size / 2, position.dy),
      linePaint,
    );

    final shadowCirclePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(position, size / 4, shadowCirclePaint);
    final circlePaint = Paint()
      ..color = const Color(0xFFFF00FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, size / 4, circlePaint);

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}

/// Highlights elements on a screenshot.
class HighlightAnnotator implements ScreenshotAnnotator {
  /// Highlight plain rectangles on the screenshot with optional labels.
  HighlightAnnotator.rects(
    this.rects, {
    this.color = const Color(0xFFFF00FF),
    this.labels,
  }) : assert(labels == null || rects.length == labels.length);

  /// Highlight elements on the screenshot
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

  /// Highlight a single element on the screenshot
  factory HighlightAnnotator.element(Element element) {
    return HighlightAnnotator.elements([element]);
  }

  /// The rectangles to highlight. They are captured at the point of creation,
  /// because the elements change or even disappear in the next frame
  final List<Rect> rects;

  /// Optional labels for the highlighted rectangles. Will be displayed below and above the rectangle.
  final List<String>? labels;

  /// The color to use for highlighting.
  final Color color;

  @override
  String get name => 'Highlight Elements Annotator';

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final binding = TestWidgetsFlutterBinding.instance;
    if (binding is! LiveTestWidgetsFlutterBinding) {
      final fontLoader = FontLoader('Test-Roboto');
      final fontBytes =
          await rootBundle.load('packages/spot/lib/assets/Roboto-Regular.ttf');
      fontLoader.addFont(Future.sync(() => fontBytes));
      await fontLoader.load();
    }
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

/// Draws an arrow on a screenshot.
class ArrowAnnotator extends ScreenshotAnnotator {
  /// The end of the arrow
  final Offset start;

  /// The tip of the arrow
  final Offset end;

  /// The color of the arrow
  final Color color;

  /// Creates an [ArrowAnnotator] with a [start] and [end] point.
  ArrowAnnotator({
    required this.start,
    required this.end,
    this.color = const Color(0xFFFF00FF),
  });

  @override
  String get name => 'Arrow Annotator';

  @override
  Future<ui.Image> annotate(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(image, Offset.zero, Paint());
    final binding = TestWidgetsFlutterBinding.instance;
    final view = binding.platformDispatcher.implicitView;
    final devicePixelRatio = view?.devicePixelRatio ?? 1.0;

    // Shadow Paint
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Main Arrow Paint
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final adjustedStart =
        Offset(start.dx * devicePixelRatio, start.dy * devicePixelRatio);
    final adjustedEnd =
        Offset(end.dx * devicePixelRatio, end.dy * devicePixelRatio);

    // Draw shadow arrow path
    final shadowPath = Path();
    const shadowOffset = const Offset(0, 0); // Offset for the shadow
    shadowPath.moveTo(
        adjustedStart.dx + shadowOffset.dx, adjustedStart.dy + shadowOffset.dy);
    shadowPath.lineTo(
        adjustedEnd.dx + shadowOffset.dx, adjustedEnd.dy + shadowOffset.dy);

    // Calculate shadow arrowhead points
    const arrowLength = 40.0;
    const arrowAngle = 45.0 * math.pi / 180.0;
    final dx = adjustedEnd.dx - adjustedStart.dx;
    final dy = adjustedEnd.dy - adjustedStart.dy;
    final angle = math.atan2(dy, dx);

    // Shadow arrowhead
    final shadowArrowPoint1 = Offset(
      adjustedEnd.dx +
          shadowOffset.dx -
          arrowLength * math.cos(angle - arrowAngle),
      adjustedEnd.dy +
          shadowOffset.dy -
          arrowLength * math.sin(angle - arrowAngle),
    );
    final shadowArrowPoint2 = Offset(
      adjustedEnd.dx +
          shadowOffset.dx -
          arrowLength * math.cos(angle + arrowAngle),
      adjustedEnd.dy +
          shadowOffset.dy -
          arrowLength * math.sin(angle + arrowAngle),
    );

    shadowPath.moveTo(
        adjustedEnd.dx + shadowOffset.dx, adjustedEnd.dy + shadowOffset.dy);
    shadowPath.lineTo(shadowArrowPoint1.dx, shadowArrowPoint1.dy);
    shadowPath.moveTo(
        adjustedEnd.dx + shadowOffset.dx, adjustedEnd.dy + shadowOffset.dy);
    shadowPath.lineTo(shadowArrowPoint2.dx, shadowArrowPoint2.dy);

    // Draw shadow on canvas
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main arrow path
    final path = Path();
    path.moveTo(adjustedStart.dx, adjustedStart.dy);
    path.lineTo(adjustedEnd.dx, adjustedEnd.dy);

    // Main arrowhead
    final arrowPoint1 = Offset(
      adjustedEnd.dx - arrowLength * math.cos(angle - arrowAngle),
      adjustedEnd.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    final arrowPoint2 = Offset(
      adjustedEnd.dx - arrowLength * math.cos(angle + arrowAngle),
      adjustedEnd.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    path.moveTo(adjustedEnd.dx, adjustedEnd.dy);
    path.lineTo(arrowPoint1.dx, arrowPoint1.dy);
    path.moveTo(adjustedEnd.dx, adjustedEnd.dy);
    path.lineTo(arrowPoint2.dx, arrowPoint2.dy);

    // Draw main arrow on canvas
    canvas.drawPath(path, paint);

    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }
}
