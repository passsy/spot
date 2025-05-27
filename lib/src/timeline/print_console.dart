import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:spot/src/screenshot/screenshot_io.dart'
    if (dart.library.html) 'package:spot/src/screenshot/screenshot_web.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:spot/src/utils/ci.dart';

/// Extension that adds a method to print the timeline to the console.
extension ConsoleTimelinePrinter on Timeline {
  /// Prints the complete timeline to the console.
  Future<void> printToConsole() async {
    // ignore: avoid_print
    final frame = mostRelevantCaller(trace: test.test.trace);
    final location = frame != null
        ? ' at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : '';
    // ignore: avoid_print
    print('Timeline of test: ${test.test.name}$location');
    for (final event in events) {
      await printEventToConsole(event);
    }
  }

  /// Prints a single event to the console.
  Future<void> printEventToConsole(TimelineEvent event) async {
    final StringBuffer buffer = StringBuffer();
    final frame = event.initiator;
    final caller = frame != null
        ? 'at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : 'N/A';
    final details =
        kIsWeb || !isCI ? event.details.split('\n').firstOrNull : event.details;
    buffer.writeln('==================== Timeline Event ====================');
    buffer.writeln('Event Type: ${event.eventType}');
    if (details != null) {
      buffer.writeln('Details: $details');
    }
    buffer.writeln('Caller: $caller');
    final screenshot = event.screenshot;
    if (screenshot != null) {
      // create dummy file to be printed into the console (sync)
      final fileName = screenshot.name;
      final pngPath = createSpotTempFile(fileName, Uint8List(0));
      // fill it with data (async)
      timeline.addScreenshotProcessing(() async {
        final flattened = await screenshot.flattenedImage();
        final pngBytes = await flattened.readPngBytes();
        final binding = TestWidgetsFlutterBinding.instance;
        final path = await binding.runAsync(() async {
          return createSpotTempFile(fileName, pngBytes);
        });
        assert(path == pngPath);
      });
      buffer.writeln('Screenshot: file://$pngPath');
    }

    buffer.writeln('Timestamp: ${event.timestamp.toIso8601String()}');
    buffer.writeln('========================================================');

    // ignore: avoid_print
    print(buffer);
  }
}
