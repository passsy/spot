import 'dart:core';
import 'dart:core' as core;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartx/dartx_io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:spot/spot.dart';
import 'package:stack_trace/stack_trace.dart';

class Screenshot {
  Screenshot({required this.file});
  final File file;
}

Future<Screenshot> takeScreenshot({
  Element? element,
  SingleWidgetSnapshot? snapshot,
  SingleWidgetSelector? selector,
  String? name,
  bool print = true,
}) async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.instance;
  final frame = _caller();

  // Element that is currently active in the widget tree, to take a screenshot of
  final Element liveElement = () {
    if (selector != null) {
      // taking a fresh snapshot guarantees an element that is currently in the
      // tree and can be screenshotted
      final snapshot = selector.snapshot().existsOnce();
      return snapshot.element;
    }

    if (snapshot != null) {
      if (!snapshot.element.mounted) {
        throw StateError(
          'Can not take a screenshot of snapshot $snapshot, because it is not mounted anymore. '
          'Only Elements that are currently mounted can be screenshotted.',
        );
      }
      if (snapshot.widget != snapshot.element.widget) {
        throw StateError(
          'Can not take a screenshot of snapshot $snapshot, because the Element has been updated since the snapshot was taken. '
          'This happens when the widget tree is rebuilt.',
        );
      }
      return snapshot.element;
    }

    if (element != null) {
      if (!element.mounted) {
        throw StateError(
          'Can not take a screenshot of Element $element, because it is not mounted anymore. '
          'Only Elements that are currently mounted can be screenshotted.',
        );
      }
      return element;
    }

    // fallback to screenshotting the entire app
    return binding.renderViewElement!;
  }();

  late final Uint8List bytes;
  await binding.runAsync(() async {
    final image = await _captureImage(liveElement);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return 'Could not take screenshot';
    }
    bytes = byteData.buffer.asUint8List();
    image.dispose();
  });

  final spotTempDir = Directory.systemTemp.directory('spot');
  if (!spotTempDir.existsSync()) {
    spotTempDir.createSync();
  }
  String callerFileName() {
    final file = frame?.uri.pathSegments.last
        .replaceFirst('_test.dart', '')
        .replaceFirst('.dart', '');
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
    final n = name ?? callerFileName();
    // always append a unique id to avoid name collisions
    final uniqueId = nanoid(length: 5);
    return '$n-$uniqueId.png';
  }();
  final file = spotTempDir.file(screenshotFileName);
  file.writeAsBytesSync(bytes);
  if (print) {
    // ignore: avoid_print
    core.print(
      'Screenshot file://${file.path}\n'
      '  taken at ${frame?.member} ${frame?.uri}:${frame?.line}:${frame?.column}',
    );
  }
  return Screenshot(file: file);
}

/// Render the closest [RepaintBoundary] of the [element] into an image.
///
/// See also:
///
///  * [OffsetLayer.toImage] which is the actual method being called.
Future<ui.Image> _captureImage(Element element) {
  assert(element.renderObject != null);
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent! as RenderObject;
  }
  assert(!renderObject.debugNeedsPaint);
  final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
  return layer.toImage(renderObject.paintBounds);
}

/// Returns the frame in the call stack that is most useful for identifying for
/// humans
Frame? _caller({StackTrace? stack}) {
  final trace = stack != null ? Trace.parse(stack.toString()) : Trace.current();
  final relevantLines = trace.frames.where((line) {
    if (line.isCore) return false;
    final url = line.uri.toString();
    if (url.contains('package:spot')) return false;
    return true;
  }).toList();
  final Frame? bestGuess = relevantLines.firstOrNull;
  return bestGuess;
}
