import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// Written against `package:spot/spot.dart` alone, which is the point of this
/// file: `takeScreenshot` accepts annotators, so a package consumer has to be
/// able to write one without reaching into `package:spot/src/`.
class _BorderAnnotator implements ScreenshotAnnotator {
  @override
  String get name => 'Border Annotator';

  /// The border is the same wherever it is drawn, so one of these is as good
  /// as another and spot may draw it once.
  @override
  List<Object?> get props => [];

  @override
  Future<ui.Image> annotate(ui.Image image) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xff00ff00),
    );
    return recorder.endRecording().toImage(image.width, image.height);
  }
}

void main() {
  testWidgets('a custom annotator only needs the public API', (tester) async {
    await tester.pumpWidget(const ColoredBox(color: Color(0xffff0000)));

    final screenshot = await takeScreenshot(
      print: false,
      annotators: [_BorderAnnotator()],
    );

    expect(screenshot.annotations, hasLength(1));
    expect(screenshot.annotations.single.name, 'Border Annotator');
  });
}
