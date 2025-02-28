import 'dart:core' as core;
import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:spot/src/screenshot/screenshot_web.dart' as self
    show takeScreenshot;
import 'package:spot/src/timeline/invoker.dart';
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
}) async {
  //ignore: avoid_print
  core.print('⚠️ - Taking screenshots is not yet supported on web');
  return Screenshot();
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
    List<ScreenshotAnnotator>? annotators,
  }) {
    //ignore: avoid_print
    core.print('⚠️ - Taking screenshots is not yet supported on web');
    return Screenshot();
  }
}

/// Provides the ability to create screenshots of a [WidgetSelector]
extension SelectorScreenshotExtension<W extends Widget> on WidgetSelector<W> {
  /// Takes as screenshot of the widget that can be found by this selector.
  Future<Screenshot> takeScreenshot({String? name}) async {
    return self.takeScreenshot(selector: this, name: name);
  }
}

/// Provides the ability to create screenshots of a [WidgetSnapshot]
extension SnapshotScreenshotExtension<W extends Widget> on WidgetSnapshot<W> {
  /// Takes as screenshot of the widget that was captured in this snapshot.
  ///
  /// The snapshot must have been taken at the same frame
  Future<Screenshot> takeScreenshot({String? name}) async {
    return self.takeScreenshot(snapshot: this, name: name);
  }
}

/// Provides the ability to create screenshots of an [Element]
extension ElementScreenshotExtension on Element {
  /// Takes as screenshot of this element
  ///
  /// The element must be mounted
  Future<Screenshot> takeScreenshot({String? name}) async {
    return self.takeScreenshot(element: this, name: name);
  }
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

extension LiveTestExtensions on LiveTest {
  bool get isCI => false;
}
