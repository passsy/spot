// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
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
    print('kIsWeb: $kIsWeb');
    if (kIsWeb) {
      expect(shot.file, isNull);
      return;
    }
    expect(shot.file!.existsSync(), isTrue);
    final redPixelCoverage = await percentageOfPixelsWithColor(shot.file!, red);
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

    final container = await takeScreenshot(selector: spot<Container>());
    if (kIsWeb) {
      expect(container.file, isNull);
      return;
    }
    expect(container.file!.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file!, red);
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
    final containerSnapshot = spot<Container>().snapshot();

    final container = await takeScreenshot(snapshot: containerSnapshot);

    if (kIsWeb) {
      expect(container.file, isNull);
      return;
    }
    expect(container.file!.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file!, red);
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
    final containerSnapshot = spot<Container>().snapshot();

    // Remove element that is captured in the snapshot
    await tester.pumpWidget(Container());
    expect(containerSnapshot.discoveredElement!.mounted, isFalse);

    await expectLater(
      takeScreenshot(snapshot: containerSnapshot),
      throwsErrorContaining<StateError>([
        'Cannot take a screenshot of snapshot',
        'not mounted anymore',
        'Only Elements that are currently mounted can be screenshotted.',
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
    final containerElement = spot<Container>().snapshot().discoveredElement;

    final container = await takeScreenshot(element: containerElement);
    if (kIsWeb) {
      expect(container.file, isNull);
      return;
    }
    expect(container.file!.existsSync(), isTrue);

    final redPixelCoverage =
        await percentageOfPixelsWithColor(container.file!, red);
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
    final containerElement = spot<Container>().snapshot().discoveredElement;

    // Remove containerElement
    await tester.pumpWidget(Container());
    expect(containerElement!.mounted, isFalse);

    await expectLater(
      takeScreenshot(element: containerElement),
      throwsErrorContaining<StateError>([
        'Cannot take a screenshot of Element',
        'not mounted anymore',
        'Only Elements that are currently mounted can be screenshotted.',
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
    final screenshot1 = await spot<Container>().takeScreenshot();
    final screenshot2 = await spot<Container>().snapshot().takeScreenshot();
    final screenshot3 =
        await spot<Container>().snapshot().discoveredElement!.takeScreenshot();
    if (kIsWeb) {
      expect(screenshot1.file, isNull);
      expect(screenshot2.file, isNull);
      expect(screenshot3.file, isNull);
      return;
    }

    expect(screenshot1.file!.existsSync(), isTrue);
    expect(screenshot2.file!.existsSync(), isTrue);
    expect(screenshot3.file!.existsSync(), isTrue);
  });

  testWidgets('Take screenshot with custom name', (tester) async {
    final shot = await takeScreenshot(name: 'custom_name');
    if (kIsWeb) {
      expect(shot.file, isNull);
      return;
    }
    expect(shot.file!.name, contains('custom_name'));
  });

  testWidgets('screenshot file name contains test file name', (tester) async {
    final shot = await takeScreenshot();
    final lineNumber = _currentLineNumber() - 1;
    if (kIsWeb) {
      expect(shot.file, isNull);
      return;
    }
    expect(shot.file!.name, contains('screenshot_test_$lineNumber'));
  });

  testWidgets('name gets escaped to prevent slashes', (tester) async {
    final shot = await takeScreenshot(name: 'path/to/name');
    if (kIsWeb) {
      expect(shot.file, isNull);
      return;
    }
    expect(shot.file!.name, isNot(contains('path/to/name')));
    expect(shot.file!.name, contains('path%2Fto%2Fname'));
  });

  testWidgets('initiator frame is attached', (tester) async {
    final shot = await takeScreenshot();
    final lineNumber = _currentLineNumber() - 1;
    expect(shot.initiator!.line, lineNumber);
    expect(shot.initiator!.uri.toString(), endsWith('screenshot_test.dart'));
    expect(shot.initiator!.member, 'main.<fn>');
  });

  testWidgets('prints name to console', (tester) async {
    final log = <String>[];
    int line = 0;
    await runZoned(
      () async {
        await takeScreenshot();
        line = _currentLineNumber() - 1;
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, message) {
          log.add(message);
        },
      ),
    );
    final text = log.join('\n');
    expect(text, contains('Screenshot file://'));
    expect(text, contains('screenshot_test'));
    expect(text, contains('.png'));
    expect(text, contains('taken at main'));
    expect(text, contains('screenshot_test.dart:$line'));
  });

  testWidgets('warning when screenshot is bigger than target', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ColoredBox(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('button'),
            ),
          ),
        ),
      ),
    );

    final log = <String>[];
    await runZoned(
      () async {
        await takeScreenshot(selector: spotText('button'));
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, message) {
          log.add(message);
        },
      ),
    );

    final text = log.join('\n');
    expect(
      text,
      contains(
        RegExp(
          r'Warning: The screenshot captured of RichText is larger \(1000, 1000\) '
          r'than RichText \(.*, .*\) itself.',
        ),
      ),
    );
    expect(
      text,
      contains(
        'Wrap the RichText in a RepaintBoundary to be able to capture only that layer.',
      ),
    );
  });

  testWidgets('Take screenshot of dirty tree', (tester) async {
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        // Banner listens to PaintingBinding.instance.systemFonts and requests repaint (markNeedsPaint)
        child: Banner(
          message: 'Hello',
          location: BannerLocation.topEnd,
          child: Container(color: Colors.white),
        ),
      ),
    );

    // FontLoader.load triggers PaintBinding.instance.systemFonts listeners
    await loadAppFonts();
    final renderObject =
        spot<Banner>().spot<CustomPaint>().snapshotRenderObject();
    expect(renderObject.debugNeedsPaint, isTrue);

    // When elements are dirty, taking a screenshot should still work
    await takeScreenshot();
  });

  group('Annotate Screenshot test', () {
    testWidgets('Take screenshot with tap marker of the entire app',
        (tester) async {
      tester.view.physicalSize = const Size(210, 210);
      tester.view.devicePixelRatio = 1.0;
      const red = Color(0xffff0000);
      await tester.pumpWidget(
        Center(
          child: Container(height: 200, width: 200, color: red),
        ),
      );

      final shot = await takeScreenshot(
        annotators: [CrosshairAnnotator(centerPosition: Offset(105, 105))],
      );
      if (kIsWeb) {
        expect(shot.file, isNull);
        return;
      }
      expect(shot.file!.existsSync(), isTrue);

      final pinkPixelCoverage =
          await percentageOfPixelsWithColor(shot.file!, Color(0xFFFF00FF));
      expect(pinkPixelCoverage, greaterThan(0.0));
    });

    testWidgets('Take screenshot with tap marker from a selector',
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

      final container = await takeScreenshot(
        selector: spot<Container>(),
        annotators: [CrosshairAnnotator(centerPosition: Offset(100, 100))],
      );
      if (kIsWeb) {
        expect(container.file, isNull);
        return;
      }
      expect(container.file!.existsSync(), isTrue);

      final pinkPixelCoverage =
          await percentageOfPixelsWithColor(container.file!, Color(0xFFFF00FF));
      expect(pinkPixelCoverage, greaterThan(0.0));
    });

    testWidgets('Take screenshot with tap marker from a snapshot',
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
      final containerSnapshot = spot<Container>().snapshot();

      final container = await takeScreenshot(
        snapshot: containerSnapshot,
        annotators: [CrosshairAnnotator(centerPosition: Offset(100, 100))],
      );
      if (kIsWeb) {
        expect(container.file, isNull);
        return;
      }
      expect(container.file!.existsSync(), isTrue);

      final pinkPixelCoverage =
          await percentageOfPixelsWithColor(container.file!, Color(0xFFFF00FF));
      expect(pinkPixelCoverage, greaterThan(0.0));
    });

    testWidgets(
      'Take screenshot with tap marker from a snapshot throws when snapshot is outdated',
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
        final containerSnapshot = spot<Container>().snapshot();

        // Remove element that is captured in the snapshot
        await tester.pumpWidget(Container());
        expect(containerSnapshot.discoveredElement!.mounted, isFalse);

        await expectLater(
          takeScreenshot(
            snapshot: containerSnapshot,
            annotators: [CrosshairAnnotator(centerPosition: Offset(100, 100))],
          ),
          throwsErrorContaining<StateError>([
            'Cannot take a screenshot of snapshot',
            'not mounted anymore',
            'Only Elements that are currently mounted can be screenshotted.',
          ]),
        );
      },
    );

    testWidgets('Take screenshot with tap marker from an element',
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
      final containerElement = spot<Container>().snapshot().discoveredElement;

      final container = await takeScreenshot(
        element: containerElement,
        annotators: [CrosshairAnnotator(centerPosition: Offset(100, 100))],
      );
      if (kIsWeb) {
        expect(container.file, isNull);
        return;
      }
      expect(container.file!.existsSync(), isTrue);

      final pinkPixelCoverage =
          await percentageOfPixelsWithColor(container.file!, Color(0xFFFF00FF));
      expect(pinkPixelCoverage, greaterThan(0.0));
    });

    testWidgets(
        'takeScreenshotWithCrosshair throws when element does not exist anymore',
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
      final containerElement = spot<Container>().snapshot().discoveredElement;

      // Remove containerElement
      await tester.pumpWidget(Container());
      expect(containerElement!.mounted, isFalse);

      await expectLater(
        takeScreenshot(
          element: containerElement,
          annotators: [CrosshairAnnotator(centerPosition: Offset(100, 100))],
        ),
        throwsErrorContaining<StateError>([
          'Cannot take a screenshot of Element',
          'not mounted anymore',
          'Only Elements that are currently mounted can be screenshotted.',
        ]),
      );
    });
  });
}

/// Parses an png image file and reads the percentage of pixels of a given [color].
Future<double> percentageOfPixelsWithColor(File file, Color color) async {
  final binding = TestWidgetsFlutterBinding.instance;
  final image =
      (await binding.runAsync(() => img.decodePngFile(file.absolute.path)))!;

  // Count the number of red pixels in the image
  int matchingPixels = 0;
  final int totalPixelCount = image.width * image.height;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final c = Color.fromARGB(
        pixel.a.toInt(),
        pixel.r.toInt(),
        pixel.g.toInt(),
        pixel.b.toInt(),
      );
      if (c == color) {
        matchingPixels++;
      }
    }
  }
  // Calculate the red pixel coverage percentage
  final double coverage = matchingPixels / totalPixelCount;
  return coverage;
}

/// The line number of this function call
int _currentLineNumber() {
  final lines = StackTrace.current.toString().split('\n');
  final callerLine = lines[1];
  final parts = callerLine.split(':');
  // parts[parts.length - 1] is the column number
  return parts[parts.length - 2].toInt();
}
