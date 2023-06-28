import 'dart:core';
import 'dart:core' as core;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dartx/dartx_io.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test_api/hooks.dart';
import 'package:ulid/ulid.dart';

Future<File> takeScreenshot({String? name, bool print = true}) async {
  final frame = _caller();
  final callerFileName = () {
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
  }();

  final String screenshotFileName = () {
    final n = name ?? callerFileName;
    final uniqueId = Ulid().toCanonical().substring(0, 5); // nanoid(5)
    return '$n-$uniqueId.png';
  }();

  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.instance;

  late final Uint8List bytes;
  await binding.runAsync(() async {
    final element = binding.renderViewElement!;
    final image = await _captureImage(element);
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
  final file = spotTempDir.file(screenshotFileName);
  file.writeAsBytesSync(bytes);
  if (print) {
    // ignore: avoid_print
    core.print(
      'Screenshot file://${file.path}\n'
      '  taken at ${frame?.member} ${frame?.uri}:${frame?.line}:${frame?.column}',
    );
  }
  return file;
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
