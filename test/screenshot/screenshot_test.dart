// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use_from_same_package, avoid_dynamic_calls

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
    expect(shot.width, 210);
    expect(shot.height, 210);
    expect(shot.name, isNot(endsWith('.png')));

    final redPixelCoverage = await percentageOfPixelsWithColor(shot, red);
    expect(redPixelCoverage, greaterThan(0.9));

    if (kIsWeb) {
      expect(shot.file, isNull);
    } else {
      final filePath = await shot.createTempPngFile();
      expect(filePath, endsWith('.png'));
      expect(File(filePath).existsSync(), isTrue);
    }
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
    final redPixelCoverage = await percentageOfPixelsWithColor(container, red);
    expect(redPixelCoverage, 1.0);

    if (kIsWeb) {
      expect(container.file, isNull);
    } else {
      expect(container.file.existsSync(), isTrue);
    }
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
    } else {
      expect(container.file!.existsSync(), isTrue);
    }

    final redPixelCoverage = await percentageOfPixelsWithColor(container, red);
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

  testWidgets('Take screenshot from an element', (tester) async {
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
    } else {
      expect(container.file!.existsSync(), isTrue);
    }
    final redPixelCoverage = await percentageOfPixelsWithColor(container, red);
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
    } else {
      expect(screenshot1.file!.existsSync(), isTrue);
      expect(screenshot2.file!.existsSync(), isTrue);
      expect(screenshot3.file!.existsSync(), isTrue);
    }
  });

  testWidgets('Take screenshot with custom name', (tester) async {
    final shot = await takeScreenshot(name: 'custom_name');
    if (kIsWeb) {
      expect(shot.file, isNull);
    } else {
      expect((shot.file as File).name, contains('custom_name'));
    }
  });

  testWidgets('screenshot file name contains test file name', (tester) async {
    final shot = await takeScreenshot();
    final lineNumber = _currentLineNumber() - 1;
    if (kIsWeb) {
      expect(shot.file, isNull);
      expect(shot.name, contains('screenshot_test'));
    } else {
      expect(
        (shot.file as File).name,
        contains('screenshot_test_$lineNumber'),
      );
    }
  });

  testWidgets('name gets escaped to prevent slashes', (tester) async {
    final shot = await takeScreenshot(name: 'path/to/name');
    if (kIsWeb) {
      expect(shot.file, isNull);
    } else {
      expect((shot.file as File).name, isNot(contains('path/to/name')));
      expect((shot.file as File).name, contains('path%2Fto%2Fname'));
    }
  });

  testWidgets('initiator frame is attached', (tester) async {
    final shot = await takeScreenshot();
    final lineNumber = _currentLineNumber() - 1;
    if (kIsWeb) {
      expect(shot.initiator, isNotNull);
    } else {
      expect(shot.initiator!.line, lineNumber);
      expect(
        shot.initiator!.uri.toString(),
        endsWith('screenshot_test.dart'),
      );
      expect(shot.initiator!.member, 'main.<fn>');
    }
  });

  testWidgets('prints name to console', (tester) async {
    final log = <String>[];
    int line = 0;
    await runZoned(
      () async {
        if (!kIsWeb) {
          await takeScreenshot();
          line = _currentLineNumber() - 1;
        } else {
          await takeScreenshot();
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, message) {
          log.add(message);
        },
      ),
    );
    final text = log.join('\n');

    if (kIsWeb) {
      expect(text, isNot(contains('Screenshot file://')));
      expect(text, isNot(contains('screenshot_test')));
      expect(text, isNot(contains('.png')));
      expect(text, isNot(contains('taken at main')));
      expect(text, isNot(contains('screenshot_test.dart:$line')));
    } else {
      expect(text, contains('Screenshot file://'));
      expect(text, contains('screenshot_test'));
      expect(text, contains('.png'));
      expect(text, contains('taken at main'));
      expect(text, contains('screenshot_test.dart:$line'));
    }
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
        'Warning: The screenshot captured of RichText is larger (1000, 1000)',
      ),
    );
    expect(text, contains(RegExp(r'than RichText \(.*, .*\) itself.')));
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
    expect(renderObject.debugNeedsPaint, kIsWeb ? isFalse : isTrue);

    // When elements are dirty, taking a screenshot should still work
    final shot = await takeScreenshot();
    if (kIsWeb) {
      expect(shot.file, isNull);
    } else {
      expect(shot.file!.existsSync(), isTrue);
    }
  });

  group('Annotate Screenshot test', () {
    testWidgets('Take screenshot with tap marker of the entire app',
        (tester) async {
      tester.view.physicalSize = const Size(210, 210);
      tester.view.devicePixelRatio = 1.0;
      const red = Color(0xffff0000);
      const pink = Color(0xFFFF00FF);
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
      } else {
        expect(shot.file!.existsSync(), isTrue);
      }

      final shotCoverage = await analyzeImageCoverage(shot);
      expect(shotCoverage.coverage(pink), 0.0);
      expect(shotCoverage.coverage(red), greaterThan(0.5));
      final annotationCoverage =
          await analyzeImageCoverage(shot.annotations.first.image);
      expect(annotationCoverage.coverage(pink), greaterThan(0.0));
      expect(annotationCoverage.coverage(red), lessThan(0.1));

      final flattened = await shot.flattenedImage();
      final flattenedCoverage = await analyzeImageCoverage(flattened);
      expect(flattenedCoverage.coverage(pink), greaterThan(0.001));
      expect(flattenedCoverage.coverage(red), greaterThan(0.5));
      expect(flattenedCoverage.coverage(Colors.white), lessThan(0.01));
    });

    testWidgets('Take screenshot with tap marker from a selector',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      const red = Color(0xffff0000);
      const pink = Color(0xFFFF00FF);
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
      } else {
        expect(container.file!.existsSync(), isTrue);
      }

      final flattened = await container.flattenedImage();
      final coverage = await analyzeImageCoverage(flattened);
      expect(coverage.coverage(pink), greaterThan(0.0));
      expect(coverage.coverage(red), greaterThan(0.5));
      expect(coverage.coverage(Colors.white), lessThan(0.01));
    });

    testWidgets('Take screenshot with tap marker from a snapshot',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      const red = Color(0xffff0000);
      const pink = Color(0xFFFF00FF);
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
      } else {
        expect(container.file!.existsSync(), isTrue);
      }

      final flattened = await container.flattenedImage();
      final coverage = await analyzeImageCoverage(flattened);
      expect(coverage.coverage(pink), greaterThan(0.0));
      expect(coverage.coverage(red), greaterThan(0.5));
      expect(coverage.coverage(Colors.white), lessThan(0.01));
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
    });

    testWidgets('Take screenshot with tap marker from an element',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      const red = Color(0xffff0000);
      const pink = Color(0xFFFF00FF);
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
      } else {
        expect(container.file.existsSync(), isTrue);
      }

      final flattened = await container.flattenedImage();
      final coverage = await analyzeImageCoverage(flattened);
      expect(coverage.coverage(pink), greaterThan(0.0));
      expect(coverage.coverage(red), greaterThan(0.5));
      expect(coverage.coverage(Colors.white), lessThan(0.01));
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

/// Parses an png image file and reads the percentage of pixels of a given
/// [color].
Future<double> percentageOfPixelsWithColor(
  ImageDataRef screenshot,
  Color color,
) async {
  final binding = TestWidgetsFlutterBinding.instance;

  final image = (await binding.runAsync(
    () async => img.decodePng(await screenshot.readPngBytes()),
  ))!;

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
/// Does not work for web
int _currentLineNumber() {
  final lines = StackTrace.current.toString().split('\n');
  final callerLine = lines[1];
  if (kIsWeb) {
    // screenshot_test.dart.js 1332:48                                                      _currentLineNumber
    // screenshot_test.dart.js 879:55                                                       <fn>
    final regex = RegExp(r'(\d+):(\d+)');
    final match = regex.firstMatch(callerLine);
    if (match == null) {
      throw StateError('Could not parse line number from $callerLine');
    }
    final line = match.group(2);
    return int.parse(line!);
  } else {
    // screenshot_test.dart:1332:48
    // screenshot_test.dart:879:55
    final parts = callerLine.split(':');
    // parts[parts.length - 1] is the column number
    return parts[parts.length - 2].toInt();
  }
}

/// Parses a png image file and allows pixel coverage assertions for multiple
/// colors.
class ImageCoverageResult {
  final img.Image image;
  final Map<Color, double> _cache = {};

  ImageCoverageResult(this.image);

  /// Returns the percentage of pixels matching [color].
  double coverage(Color color) {
    return _cache.putIfAbsent(color, () {
      int matching = 0;
      final total = image.width * image.height;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final c = Color.fromARGB(
            pixel.a.toInt(),
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
          );
          if (c == color) matching++;
        }
      }
      return matching / total;
    });
  }
}

Future<ImageCoverageResult> analyzeImageCoverage(
  ImageDataRef screenshot,
) async {
  final binding = TestWidgetsFlutterBinding.instance;
  final image = (await binding.runAsync(
    () async => img.decodePng(await screenshot.readPngBytes()),
  ))!;
  return ImageCoverageResult(image);
}
