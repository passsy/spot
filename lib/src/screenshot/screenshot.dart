import 'dart:core';
// import 'dart:core' as core;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartx/dartx_io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot.dart' as self
    show takeScreenshot;
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:stack_trace/stack_trace.dart';

export 'package:stack_trace/stack_trace.dart' show Frame;

/// A screenshot taken from a widget
///
/// May also be just a single widget, not the entire screen
class Screenshot {
  /// Creates a [Screenshot] that points to a file on disk.
  Screenshot({
    required this.file,
    required this.pixels,
    this.initiator,
    required this.width,
    required this.height,
    required this.pixelRatio,
  });

  /// The file where the screenshot was saved to
  final File file;

  /// Call stack of the code that initiated the screenshot
  final Frame? initiator;

  /// The image data of the screenshot in RGBA format
  final Uint8List pixels;

  /// The width of the screenshot logical pixels
  ///
  /// width * pixelRatio = physical pixels
  final int width;

  /// The height of the screenshot in logical pixels
  ///
  /// height * pixelRatio = physical pixels
  final int height;

  /// The pixel ratio of the screenshot
  final double pixelRatio;

  /// The width of the screenshot in physical pixels
  int get physicalPixelWidth => (width * pixelRatio).round();

  /// The height of the screenshot in physical pixels
  int get physicalPixelHeight => (height * pixelRatio).round();

  /// The image data
  Future<ui.Image> get image async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    codec.dispose();
    final frame = await codec.getNextFrame();
    final image = frame.image;
    image.dispose();
    return image;
  }
}

/// Takes a screenshot of the entire screen or a single widget.
///
/// Provide a [selector], [snapshot] or [element] to take a screenshot of.
/// When the screenshot is taken from a larger than just your widget, wrap your
/// widget with a [RepaintBoundary] to indicate where the screenshot should be
/// taken.
///
/// Use [name] to make it easier to identify the screenshot in the file system.
/// By default, a random name is generated prefixed with the test file name and
/// line number.
Future<Screenshot> takeScreenshot({
  Element? element,
  WidgetSnapshot? snapshot,
  WidgetSelector? selector,
  String? name,
}) async {
  return _createScreenshot(
    element: element,
    snapshot: snapshot,
    selector: selector,
    name: name,
  );
}

/// Takes a screenshot of the entire screen or a single widget and annotates it
/// with a tap marker in form of a crosshair at the specified [centerPosition].
///
/// Provide an [element], [snapshot], or [selector] to specify what to capture.
/// - [element]: The specific element to capture.
/// - [snapshot]: A snapshot of the widget to capture.
/// - [selector]: A selector to determine the widget to capture.
/// - [name]: The name of the screenshot file.
/// - [centerPosition]: The position where the tap marker should be placed.
///
/// Returns a [Screenshot] object containing the file and initiator frame.
Future<Screenshot> takeScreenshotWithCrosshair({
  Element? element,
  WidgetSnapshot? snapshot,
  WidgetSelector? selector,
  String? name,
  required Offset centerPosition,
}) async {
  return _createScreenshot(
    element: element,
    snapshot: snapshot,
    selector: selector,
    name: name,
    annotator: CrosshairAnnotator(centerPosition: centerPosition),
    printToConsole: false,
  );
}

Future<Screenshot> _createScreenshot({
  Element? element,
  WidgetSnapshot? snapshot,
  WidgetSelector? selector,
  String? name,
  ScreenshotAnnotator? annotator,
  bool printToConsole = true,
}) async {
  final binding = TestWidgetsFlutterBinding.instance;
  final Frame? frame = _caller();

  // Element that is currently active in the widget tree, to take a screenshot of
  final Element liveElement = () {
    if (selector != null) {
      // taking a fresh snapshot guarantees an element that is currently in the
      // tree and can be screenshotted
      final snapshot = selector.snapshot().existsOnce();
      return snapshot.element;
    }

    if (snapshot != null) {
      final elements = snapshot.discovered;
      if (elements.length > 1) {
        throw StateError(
          'Screenshots can only be taken of a single element. '
          'The snapshot of ${snapshot.selector} contains ${elements.length} elements. '
          'Use a more specific selector to narrow down the scope of the screenshot.',
        );
      }
      final element = elements.first.element;
      if (!element.mounted) {
        final reason = annotator == null ? '' : ' with ${annotator.name}';
        throw StateError(
          'Cannot take a screenshot of snapshot$reason, because it is not mounted anymore. '
          'Only Elements that are currently mounted can be screenshotted.',
        );
      }
      if (snapshot.discoveredWidget != element.widget) {
        final reason = annotator == null ? '' : ' with ${annotator.name}';
        throw StateError(
          'Cannot take a screenshot of snapshot$reason, because the Element has been updated since the snapshot was taken. '
          'This happens when the widget tree is rebuilt.',
        );
      }
      return element;
    }

    if (element != null) {
      if (!element.mounted) {
        final reason = annotator == null ? '' : ' with ${annotator.name}';
        throw StateError(
          'Cannot take a screenshot of Element$reason, because it is not mounted anymore. '
          'Only Elements that are currently mounted can be screenshotted.',
        );
      }
      return element;
    }

    // fallback to screenshotting the entire app
    // Deprecated, but as of today there is no multi-window support for widget tests
    // ignore: deprecated_member_use
    return binding.renderViewElement!;
  }();

  final view = binding.platformDispatcher.implicitView;
  final devicePixelRatio = view?.devicePixelRatio ?? 1.0;

  ui.Image? image = await binding.runAsync(() async {
    return await _captureImage(liveElement, devicePixelRatio);
  });
  if (image == null) {
    throw 'Could not take screenshot';
  }
  if (annotator != null) {
    image = await binding.runAsync(() => annotator.annotate(image!));
  }
  final byteData = await binding.runAsync(() async {
    return await image!.toByteData(format: ui.ImageByteFormat.png);
  });
  if (byteData == null) {
    throw 'Could not take screenshot';
  }
  final Uint8List imageBytes = byteData.buffer.asUint8List();
  image!.dispose();

  final spotTempDir = Directory.systemTemp.directory('spot');
  if (!spotTempDir.existsSync()) {
    spotTempDir.createSync();
  }

  String callerFileName() {
    final file = frame?.uri.pathSegments.last.replaceFirst('.dart', '');
    final line = frame?.line;
    if (file != null && line != null) {
      return '$file:$line';
    }
    if (file != null) {
      return file;
    }
    return 'unknown';
  }

  final String screenshotFileName = () {
    final String n;
    if (name != null) {
      // escape /
      n = Uri.encodeQueryComponent(name);
    } else {
      n = callerFileName();
    }
    // always append a unique id to avoid name collisions
    final uniqueId = nanoid(length: 5);
    return '$n-$uniqueId.png';
  }();

  final file = spotTempDir.file(screenshotFileName);
  file.writeAsBytesSync(imageBytes);

  if (printToConsole) {
    // ignore: avoid_print
    print(
      'Screenshot file://${file.path}\n'
      '  taken at ${frame?.member} ${frame?.uri}:${frame?.line}:${frame?.column}',
    );
  }
  return Screenshot(
    file: file,
    pixels: imageBytes,
    initiator: frame,
    width: image.width ~/ devicePixelRatio,
    height: image.height ~/ devicePixelRatio,
    pixelRatio: devicePixelRatio,
  );
}

/// Provides the ability to create screenshots of a [WidgetSelector]
extension SelectorScreenshotExtension<W extends Widget> on WidgetSelector<W> {
  /// Takes as screenshot of the widget that can be found by this selector.
  Future<Screenshot> takeScreenshot({String? name}) {
    return self.takeScreenshot(selector: this, name: name);
  }
}

/// Provides the ability to create screenshots of a [WidgetSnapshot]
extension SnapshotScreenshotExtension<W extends Widget> on WidgetSnapshot<W> {
  /// Takes as screenshot of the widget that was captured in this snapshot.
  ///
  /// The snapshot must have been taken at the same frame
  Future<Screenshot> takeScreenshot({String? name}) {
    return self.takeScreenshot(snapshot: this, name: name);
  }
}

/// Provides the ability to create screenshots of an [Element]
extension ElementScreenshotExtension on Element {
  /// Takes as screenshot of this element
  ///
  /// The element must be mounted
  Future<Screenshot> takeScreenshot({String? name}) {
    return self.takeScreenshot(element: this, name: name);
  }
}

/// Render the closest [RepaintBoundary] of the [element] into an image.
///
/// See also:
///
///  * [OffsetLayer.toImage] which is the actual method being called.
Future<ui.Image> _captureImage(Element element, double pixelRatio) async {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    // ignore: unnecessary_cast
    renderObject = renderObject.parent! as RenderObject;
  }
  assert(!renderObject.debugNeedsPaint);

  final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
  final ui.Image image = await layer.toImage(
    renderObject.paintBounds,
    pixelRatio: pixelRatio,
  );

  if (element.renderObject is RenderBox) {
    final expectedSize = (element.renderObject as RenderBox?)!.size;
    if (expectedSize.width != image.width ||
        expectedSize.height != image.height) {
      // ignore: avoid_print
      print(
        'Warning: The screenshot captured of ${element.toStringShort()} is '
        'larger (${image.width}, ${image.height}) than '
        '${element.toStringShort()} (${expectedSize.width}, ${expectedSize.height}) itself.\n'
        'Wrap the ${element.toStringShort()} in a RepaintBoundary to be able to capture only that layer. ',
      );
    }
  }

  return image;
}

/// Returns the frame in the call stack that is most useful for identifying for
/// humans
Frame? _caller({StackTrace? stack}) {
  final trace = stack != null ? Trace.parse(stack.toString()) : Trace.current();
  final relevantLines = trace.frames.where((line) {
    if (line.isCore) return false;
    final url = line.uri.toString();
    if (url.contains('package:spot')) return false;
    if (url.startsWith('package:flutter_test')) return false;
    return true;
  }).toList();
  final Frame? bestGuess = relevantLines.firstOrNull;
  return bestGuess;
}
