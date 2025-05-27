import 'dart:async';
import 'dart:core' as core;
import 'dart:core';
import 'dart:ui' as ui;

import 'package:dartx/dartx_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nanoid2/nanoid2.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot.dart' as self
    show takeScreenshot;
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:spot/src/screenshot/screenshot_io.dart'
    if (dart.library.html) 'package:spot/src/screenshot/screenshot_web.dart';
import 'package:stack_trace/stack_trace.dart';

export 'package:stack_trace/stack_trace.dart' show Frame;

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
  List<ScreenshotAnnotator> annotators = const [],
  String? name,
  bool print = true,
  double? devicePixelRatio,
}) async {
  assert(devicePixelRatio == null || devicePixelRatio > 0.0);
  final binding = TestWidgetsFlutterBinding.instance;
  final pixelRatio = devicePixelRatio ??
      binding.platformDispatcher.implicitView?.devicePixelRatio ??
      1.0;

  final Frame? frame = _caller();
  final liveElement = _findSingleElement(
    element: element,
    snapshot: snapshot,
    selector: selector,
  );

  final ui.Image? plainImage = await binding.runAsync(() async {
    return await _captureImage(liveElement);
  });
  if (plainImage == null) {
    throw 'Could not take screenshot, see the logs for more details';
  }

  String callerFileName() {
    final file = frame?.uri.pathSegments.last.replaceFirst('.dart', '');
    final line = frame?.line;
    if (file != null && line != null) {
      return '${file}_$line';
    }
    if (file != null) {
      return file;
    }
    return 'unknown';
  }

  final String screenshotName = () {
    final String n;
    if (name != null) {
      // escape /
      n = Uri.encodeQueryComponent(name);
    } else {
      n = callerFileName();
    }
    // always append a unique id to avoid name collisions
    final uniqueId = nanoid(length: 5);
    return '$n-$uniqueId';
  }();

  final screenshot = Screenshot.fromImage(
    image: plainImage,
    pixelRatio: pixelRatio,
    name: screenshotName,
    initiator: frame,
  );

  if (annotators.isNotEmpty) {
    await screenshot.annotateScreenshot(annotators);
  }

  if (kIsWeb) {
    return screenshot;
  }

  final String filePath = await screenshot.createTempPngFile();

  if (print) {
    final frame = screenshot.initiator;
    // ignore: avoid_print
    core.print(
      'Screenshot file://$filePath\n'
      '  taken at ${frame?.member} ${frame?.uri}:${frame?.line}:${frame?.column}',
    );
  }

  return screenshot;
}

/// Allows taking screenshot synchronously for the [timeline]
extension TimelineSyncScreenshot on Timeline {
  /// Takes a screenshot of the entire screen or a single widget.
  /// This method returns synchronously but does not actually write the image to disk until the test has completed.
  ///
  /// This method is only intended to be used within the [timeline]
  Screenshot takeScreenshotSync({
    Element? element,
    WidgetSnapshot? snapshot,
    WidgetSelector? selector,
    String? name,
    List<ScreenshotAnnotator> annotators = const [],
    double? devicePixelRatio,
  }) {
    assert(devicePixelRatio == null || devicePixelRatio > 0.0);
    final binding = TestWidgetsFlutterBinding.instance;
    final pixelRatio = devicePixelRatio ??
        binding.platformDispatcher.implicitView?.devicePixelRatio ??
        1.0;

    final Frame? frame = _caller();

    if (timeline.mode == TimelineMode.off) {
      // ignore: avoid_print
      print(
        'Warning: The timeline is off, do not take screenshots for the timeline\n'
        ' at ${frame?.member} ${frame?.uri}:${frame?.line}:${frame?.column}',
      );
    }
    final liveElement = _findSingleElement(
      element: element,
      snapshot: snapshot,
      selector: selector,
    );

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
      return '$n-$uniqueId';
    }();

    final ui.Image plainImage = _captureImageSync(liveElement);
    final screenshot = Screenshot.fromImage(
      name: screenshotFileName,
      image: plainImage,
      pixelRatio: pixelRatio,
      initiator: frame,
    );
    plainImage.dispose();

    // At the end of the test, do the actual screenshot processing, because runAsync must be awaited or it crashes
    if (annotators.isNotEmpty) {
      timeline.addScreenshotProcessing(() async {
        await screenshot.annotateScreenshot(annotators);
      });
    }

    return screenshot;
  }
}

/// A screenshot taken in a widget test of a single widget or the entire screen.
///
/// It holds a reference to the plain pixels or [ui.Image] and contains
/// additional layers (annotations) that draw on top of the screenshot to
/// highlight certain areas.
class Screenshot extends ImageDataRef {
  /// Creates a [Screenshot] that holds the bytes of the image
  Screenshot({
    required super.bytes,
    required super.width,
    required super.height,
    required super.pixelRatio,
    required super.name,
    this.initiator,
  });

  /// Creates a [Screenshot] that holds a reference to a [ui.Image] and later loads the actual bytes
  Screenshot.fromImage({
    required super.image,
    required super.pixelRatio,
    required super.name,
    this.initiator,
  }) : super.fromImage();

  /// Returns the screenshot as File
  ///
  /// This method is deprecated and will be removed in the future.
  ///
  /// Use the async [createTempPngFile()] instead, which also works on web
  @Deprecated('Use createTempPngFile() instead')
  dynamic /*File?*/ get file {
    if (kIsWeb) {
      return null;
    }
    final bytes = readPngBytesSync();
    final path = createSpotTempFile('$name.png', bytes);
    return fileFromPath(path);
  }

  /// Merges the image itself and all annotations into a single image
  Future<ImageDataRef> flattenedImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final binding = TestWidgetsFlutterBinding.instance;
    await binding.runAsync(() async {
      final base = await readImage();
      canvas.drawImage(base, Offset.zero, Paint());
      for (final annotation in annotations) {
        final image = await annotation.image.readImage();
        canvas.drawImage(image, Offset.zero, Paint());
      }
    });
    final merged = recorder.endRecording().toImageSync(width, height);
    return ImageDataRef.fromImage(
      image: merged,
      pixelRatio: pixelRatio,
      name: '$name-flattened',
    );
  }

  /// Call stack of the code that initiated the screenshot
  final Frame? initiator;

  final List<ScreenshotAnnotation> _annotations = [];

  /// The annotations which have been added to the raw screenshot
  List<ScreenshotAnnotation> get annotations =>
      _annotations.toList(growable: false);

  /// Renders the annotations as separate images
  Future<void> annotateScreenshot(List<ScreenshotAnnotator> annotators) async {
    final binding = TestWidgetsFlutterBinding.instance;
    await binding.runAsync(() async {
      // Create transparent image the same size as plainImage to start with
      final ui.Image transparentBackground = _transparentImage(width, height);
      for (final annotator in annotators) {
        final image = await annotator.annotate(transparentBackground);

        final String screenshotName = () {
          // escape /
          final String n = Uri.encodeQueryComponent(annotator.name);
          // always append a unique id to avoid name collisions
          final uniqueId = nanoid(length: 5);
          return '$n-$uniqueId';
        }();

        final annotationScreenshot = Screenshot.fromImage(
          image: image,
          pixelRatio: pixelRatio,
          name: screenshotName,
        );
        final annotation = ScreenshotAnnotation(
          image: annotationScreenshot,
          name: annotator.name,
        );
        addAnnotation(annotation);
      }
    });
  }

  /// Adds an annotation to the screenshot
  void addAnnotation(ScreenshotAnnotation annotation) {
    assert(annotation.image.width == width);
    assert(annotation.image.height == height);
    _annotations.add(annotation);
  }
}

/// A reference to image data (raw pixels or a [ui.Image])
class ImageDataRef {
  /// Creates a [ImageDataRef] that holds the bytes of the image
  ImageDataRef({
    required Uint8List bytes,
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.name,
  })  : _bytes = bytes,
        _image = null;

  /// Creates a [ImageDataRef] that holds a reference to a [ui.Image] and later loads the actual bytes
  ImageDataRef.fromImage({
    required ui.Image image,
    required this.pixelRatio,
    required this.name,
  })  : _image = image.clone(),
        _bytes = null,
        width = image.width,
        height = image.height {
    assert(_image != null || _bytes != null);
    timeline.addTearDown(() {
      _image?.dispose();
      _image = null;
    });
  }

  /// The name of the file, without file extension
  final String name;

  /// The raw image before it is converted to bytes
  ui.Image? _image;

  /// The raw bytes in raw RGBA format, 8bits per channel
  Uint8List? _bytes;

  /// Reads the raw bytes from [_image].
  ///
  /// Noop when the default Screenshot constructor was used
  Future<void> materialize() async {
    if (_bytes != null) {
      // already materialized
      return Future.value();
    }
    final ByteData? byteData =
        // ignore: avoid_redundant_argument_values
        await _image!.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw 'Could not read raw bytes from ui.Image';
    }
    _image!.dispose();
    _bytes = byteData.buffer.asUint8List();
    _image = null;
  }

  /// Returns true when the image data is already available as raw bytes
  ///
  /// Returns false when the data has to be extracted async from the [ui.Image] first
  bool get isMaterialized => _bytes != null;

  /// Returns the image as a [ui.Image]
  Future<ui.Image> readImage() async {
    if (_image != null) {
      return _image!;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      _bytes!,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  /// The pixel data in raw RGBA format, 8bits per channel
  Future<Uint8List> readBytes() {
    if (isMaterialized) {
      return Future.value(_bytes!);
    }
    return materialize().then((_) => _bytes!);
  }

  /// The pixel data in PNG format
  Future<Uint8List> readPngBytes() {
    if (isMaterialized) {
      return Future.value(readPngBytesSync());
    }
    return materialize().then((_) => readPngBytesSync());
  }

  /// The pixel data in PNG format
  Uint8List readPngBytesSync() {
    final b = _bytes;
    if (b == null) {
      throw 'Cannot read PNG bytes, because the screenshot was not materialized yet, call materialize() first';
    }
    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: b.buffer,
      // ignore: avoid_redundant_argument_values
      format: img.Format.uint8,
      order: img.ChannelOrder.rgba,
      numChannels: 4,
    );
    final Uint8List pngBytes = img.encodePng(image);
    return pngBytes;
  }

  /// Creates a temporary file on disk with the screenshot as png
  Future<String> createTempPngFile() async {
    final binding = TestWidgetsFlutterBinding.instance;
    final path = await binding.runAsync(() async {
      final pngBytes = await readPngBytes();
      return createSpotTempFile('$name.png', pngBytes);
    });
    return path!;
  }

  /// The file on disk that contains the screenshot
  final int width;

  /// The width of the screenshot in pixels are represented in [bytes]
  int get logicalWidth => width ~/ pixelRatio;

  /// The height of the screenshot in pixels are represented in [bytes]
  final int height;

  /// The height of the screenshot in logical pixels
  int get logicalHeight => height ~/ pixelRatio;

  /// The pixel ratio of the device that took the screenshot
  ///
  /// A pixel ratio of 2.0 means that the image has 800 pixels where the
  /// device has 400 logical pixels
  final double pixelRatio;
}

/// Additional information about elements on the screenshot like a crosshair or a rect
class ScreenshotAnnotation {
  /// The pixels annotating the screenshot
  final ImageDataRef image;

  /// The name of the annotation
  final String name;

  /// Creates a screenshot annotation
  ScreenshotAnnotation({required this.image, required this.name});
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

/// Given either [element], [snapshot] or [selector], finds the currently single mounted [Element] in the widget tree
///
/// Without any of the three parameters, the entire app is screenshotted
Element _findSingleElement({
  Element? element,
  WidgetSnapshot? snapshot,
  WidgetSelector? selector,
}) {
  final binding = TestWidgetsFlutterBinding.instance;
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
      throw StateError(
        'Cannot take a screenshot of snapshot, because it is not mounted anymore. '
        'Only Elements that are currently mounted can be screenshotted.',
      );
    }
    if (snapshot.discoveredWidget != element.widget) {
      throw StateError(
        'Cannot take a screenshot of snapshot, because the Element has been updated since the snapshot was taken. '
        'This happens when the widget tree is rebuilt.',
      );
    }
    return element;
  }

  if (element != null) {
    if (!element.mounted) {
      throw StateError(
        'Cannot take a screenshot of Element, because it is not mounted anymore. '
        'Only Elements that are currently mounted can be screenshotted.',
      );
    }
    return element;
  }

  // fallback to screenshotting the entire app
  // Deprecated, but as of today there is no multi-window support for widget tests
  // ignore: deprecated_member_use
  return binding.renderViewElement!;
}

/// Render the closest [RepaintBoundary] of the [element] into an image.
///
/// See also:
///
///  * [OffsetLayer.toImage] which is the actual method being called.
///  * [_captureImageSync] sync version with known memory leak issue
Future<ui.Image> _captureImage(Element element) async {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    // ignore: unnecessary_cast
    renderObject = renderObject.parent! as RenderObject;
  }

  final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
  final ui.Image image = await layer.toImage(renderObject.paintBounds);

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

/// Render the closest [RepaintBoundary] of the [element] into an image.
///
/// This sync variant of [_captureImage] is known to cause memory leak issues. Prefer using the async variant.
/// https://github.com/flutter/flutter/issues/138627
///
/// See also:
///
///  * [OffsetLayer.toImage] which is the actual method being called.
///  * [_captureImage] async version without memory leak
ui.Image _captureImageSync(Element element) {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    // ignore: unnecessary_cast
    renderObject = renderObject.parent! as RenderObject;
  }

  final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
  final ui.Image image = layer.toImageSync(renderObject.paintBounds);

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

/// Renders a transparent image of the given size
ui.Image _transparentImage(int width, int height) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
  final picture = recorder.endRecording();
  final ui.Image transparentImage = picture.toImageSync(width, height);
  return transparentImage;
}

/// Returns the frame in the call stack that is most useful for identifying for
/// humans
Frame? _caller({StackTrace? stack}) {
  final trace = stack != null ? Trace.parse(stack.toString()) : Trace.current();
  final relevantLines = trace.frames.where((line) {
    if (line.isCore) return false;
    if (kIsWeb) {
      if (line.toString().startsWith('../')) {
        // usually from external packages, or from the dart sdk
        // ../packages/spot/src/widgets/wrap.g.dart.js 14322:88 in _caller
        // ../dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart 647:23 in <fn>
        return false;
      }
    }
    final url = line.uri.toString();
    if (url.contains('package:spot')) return false;
    if (url.startsWith('package:flutter_test')) return false;
    return true;
  }).toList();
  final Frame? bestGuess = relevantLines.firstOrNull;
  return bestGuess;
}
