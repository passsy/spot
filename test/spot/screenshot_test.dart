// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot.dart';

import '../util/assert_error.dart';

void main() {
  testWidgets('Take screenshot of the entire app', (tester) async {
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: Container(height: 200, width: 200, color: red),
      ),
    );

    final shot = await takeScreenshot();
    expect(shot.file.existsSync(), isTrue);

    final redPixelCoverage = await percentageOfPixelsWithColor(shot.file, red);
    expect(redPixelCoverage, greaterThan(0.9));
  });

  testWidgets('Take screenshot from a selector', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );

    final container = await takeScreenshot(selector: spotSingle<Container>());
    expect(container.file.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file, red);
    expect(redPixelCoverage, 1.0);
  });

  testWidgets('Take screenshot from a snapshot', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );
    final containerSnapshot = spotSingle<Container>().snapshot();

    final container = await takeScreenshot(snapshot: containerSnapshot);
    expect(container.file.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file, red);
    expect(redPixelCoverage, 1.0);
  });

  testWidgets(
      'Take screenshot from a snapshot throws when snapshot is outdated',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );
    final containerSnapshot = spotSingle<Container>().snapshot();

    // Remove element that is captured in the snapshot
    await tester.pumpWidget(Container());
    expect(containerSnapshot.element.mounted, isFalse);

    await expectLater(
      takeScreenshot(snapshot: containerSnapshot),
      throwsErrorContaining<StateError>([
        'Can not take a screenshot of snapshot',
        'not mounted anymore',
        'Only Elements that are currently mounted can be screenshotted.'
      ]),
    );
  });

  testWidgets('Take screenshot from a element', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );
    final containerElement = spotSingle<Container>().snapshot().element;

    final container = await takeScreenshot(element: containerElement);
    expect(container.file.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file, red);
    expect(redPixelCoverage, 1.0);
  });

  testWidgets('takeScreenshot throws when element does not exist anymore',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );
    final containerElement = spotSingle<Container>().snapshot().element;

    // Remove containerElement
    await tester.pumpWidget(Container());
    expect(containerElement.mounted, isFalse);

    await expectLater(
      takeScreenshot(element: containerElement),
      throwsErrorContaining<StateError>([
        'Can not take a screenshot of Element',
        'not mounted anymore',
        'Only Elements that are currently mounted can be screenshotted.'
      ]),
    );
  });

  testWidgets('takeScreenshot() extensions', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: Container(height: 200, width: 200, color: red),
        ),
      ),
    );
    final screenshot1 = await spotSingle<Container>().takeScreenshot();
    expect(screenshot1.file.existsSync(), isTrue);

    final screenshot2 =
        await spotSingle<Container>().snapshot().takeScreenshot();
    expect(screenshot2.file.existsSync(), isTrue);

    final screenshot3 =
        await spotSingle<Container>().snapshot().element.takeScreenshot();
    expect(screenshot3.file.existsSync(), isTrue);
  });

  testWidgets('Take screenshot with custom name', (tester) async {
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: Container(height: 200, width: 200, color: red),
      ),
    );

    final shot = await takeScreenshot(name: 'custom_name');
    expect(shot.file.name, contains('custom_name'));
  });

  testWidgets('screenshot file name contains test file name', (tester) async {
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;
    const red = Color(0xffff0000);
    await tester.pumpWidget(
      Center(
        child: Container(height: 200, width: 200, color: red),
      ),
    );

    final shot = await takeScreenshot();
    final lineNumber = _currentLineNumber() - 1;
    expect(shot.file.name, contains('screenshot_test:$lineNumber'));
  });
}

/// Parses an png image file and reads the percentage of pixels of a given [color].
Future<double> percentageOfPixelsWithColor(File file, Color color) async {
  final binding = TestWidgetsFlutterBinding.instance;
  final image =
      (await binding.runAsync(() => img.decodePngFile(file.absolute.path)))!;

  // Count the number of red pixels in the image
  int redPixelCount = 0;
  final int totalPixelCount = image.width * image.height;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final color = Color.fromARGB(
        pixel.a.toInt(),
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );
      if (color == Color(0xffff0000)) {
        redPixelCount++;
      }
    }
  }
  // Calculate the red pixel coverage percentage
  final double redPixelCoverage = redPixelCount / totalPixelCount;
  return redPixelCoverage;
}

int _currentLineNumber() {
  final lines = StackTrace.current.toString().split('\n');
  final callerLine = lines[1];
  final parts = callerLine.split(':');
  // parts[parts.length - 1] is the column number
  return parts[parts.length - 2].toInt();
}