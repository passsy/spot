import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart' as flt;
import 'package:spot/src/timeline/html/ide_link.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/source_excerpt.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart' as x;
import 'package:spot/src/timeline/timeline.dart';
import 'package:spot/src/utils/invoker.dart';
import 'package:stack_trace/stack_trace.dart';

/// Writes the timeline as an HTML file
extension HtmlTimelinePrinter on Timeline {
  /// Prints the timeline as an HTML file.
  Future<void> printHTML() async {
    final pubspecYaml = File('pubspec.yaml');
    if (!pubspecYaml.existsSync()) {
      // test is executed on a device (or simulator), we can't store the file to be accessible from the host system
      flt.debugPrint(
        'Warning: The timeline is only available for widget tests on the host system, not on a device',
      );
      return;
    }

    String timelineDirName({int maxLength = 50}) {
      String name = test.test.name;

      if (name.isEmpty) {
        name = 'Unnamed test';
      }

      // Replace spaces and underscores with hyphens
      name = name.replaceAll(RegExp('[ _]'), '-');

      // Remove problematic characters
      name = name.replaceAll(RegExp('[^a-zA-Z0-9-]'), '');

      // Collapse multiple hyphens into a single hyphen
      name = name.replaceAll(RegExp('-+'), '-');

      // Convert to lowercase
      name = name.toLowerCase();

      // Remove leading or trailing hyphens
      name = name.replaceAll(RegExp(r'^-+|-+$'), '');

      if (name.length > maxLength) {
        // Shorten name by using a hash
        final fullName = name;
        final hash = fullName.md5.takeFirst(8);

        // taking the end of the name for variation, because the start usually is a common group name
        String testNameEnd = fullName.takeLast(maxLength - 9);
        if (testNameEnd.startsWith('-')) {
          testNameEnd = testNameEnd.dropFirst(1);
        }
        if (testNameEnd.endsWith('-')) {
          testNameEnd = testNameEnd.dropLast(1);
        }
        return '$testNameEnd-$hash';
      }

      return name;
    }

    // Limit the number of characters in the file paths of the timeline to 256 characters (for windows)
    const maxScreenshotFilenameLength = 40;
    const maxTimelineDirNameLength = 60;
    final timelineBuildDir = Directory('build').directory('timeline');
    final reserved = [
      // C:\Users\<YourUsername>\AppData\Local\Temp
      timelineBuildDir.absolute.path.length,
      'screenshots'.length,
      maxScreenshotFilenameLength,
      10, // padding for slashes, file extensions and other miscalculations
    ];
    final remainingSpace = 256 - reserved.reduce((a, b) => a + b);
    assert(
      remainingSpace > 0,
      'The remaining space for the timeline directory name is too small: $remainingSpace/256 left. '
      'The plan was to place the timeline in ${timelineDirName(maxLength: 1000)}',
    );
    final timelineDirNameTrimmed = timelineDirName(
      maxLength: remainingSpace.clamp(0, maxTimelineDirNameLength),
    );

    final spotTempDir = timelineBuildDir.directory(timelineDirNameTrimmed);
    if (spotTempDir.existsSync()) {
      spotTempDir.deleteSync(recursive: true);
    }
    spotTempDir.createSync(recursive: true);

    const screenshotsDirName = 'screenshots';
    final screenshotsDir = spotTempDir.directory(screenshotsDirName);
    screenshotsDir.createSync(recursive: true);

    final screenshotsByFrame = <int, TimelineEvent>{};
    for (final event in this.events) {
      if (event.screenshot != null) {
        screenshotsByFrame.putIfAbsent(event.frameNumber, () => event);
      }
    }

    final screenshotUrlsByFrame = <int, String>{};
    for (final entry in screenshotsByFrame.entries) {
      final screenshot = entry.value.screenshot!;
      final pngName = 'frame-${entry.key}';
      final screenshotFile = screenshotsDir.file('$pngName.png');
      final pngBytes = await screenshot.readPngBytes();
      screenshotFile.writeAsBytesSync(pngBytes);
      screenshotUrlsByFrame[entry.key] = './$screenshotsDirName/$pngName.png';
    }

    final overlayUrlsByEvent = <TimelineEventId, List<String>>{};
    for (final (eventIndex, event) in this.events.indexed) {
      final annotations = event.screenshot?.annotations ?? const [];
      final overlayUrls = <String>[];
      for (final (annotationIndex, annotation) in annotations.indexed) {
        final pngName =
            'frame-${event.frameNumber}-event-$eventIndex-overlay-$annotationIndex';
        final annotationFile = screenshotsDir.file('$pngName.png');
        annotationFile.writeAsBytesSync(await annotation.image.readPngBytes());
        overlayUrls.add('./$screenshotsDirName/$pngName.png');
      }
      overlayUrlsByEvent[event.id] = overlayUrls;
    }

    final events = spotTempDir.file('events.json');
    final List<x.TimelineEvent> jsonTimelineEvents = [];
    final firstEventByFrame = <int, TimelineEvent>{};
    for (final event in this.events) {
      firstEventByFrame.putIfAbsent(event.frameNumber, () => event);
    }
    final framesWithPayload = <int>{};
    final sourceFiles = readTimelineSourceFiles(
      this.events.map((event) => event.initiator),
    );
    for (final e in this.events) {
      final includeFramePayload = framesWithPayload.add(e.frameNumber);
      final framePayloadEvent =
          screenshotsByFrame[e.frameNumber] ??
          firstEventByFrame[e.frameNumber]!;
      final compressedFrameData = includeFramePayload
          ? x.compressTimelineFrameData(
              widgetTree: framePayloadEvent.widgetTree,
              structuredWidgetTree: framePayloadEvent.structuredWidgetTree,
            )
          : null;
      final ideLink = ideLinkFor(
        e.initiator,
        environment: Platform.environment,
        workingDirectory: Directory.current,
      );
      final timelineEvent = x.TimelineEvent(
        eventType: e.eventType.label,
        details: e.details,
        timestamp: e.timestamp.toIso8601String(),
        wallTimestamp: e.wallTime.toIso8601String(),
        screenshotUrl: screenshotUrlsByFrame[e.frameNumber],
        overlayUrls: overlayUrlsByEvent[e.id] ?? const [],
        frameNumber: e.frameNumber,
        color: e.color == flt.Colors.grey
            ? null
            // ignore: deprecated_member_use
            : e.color.value & 0xFFFFFF,
        caller: _eventCaller(e.initiator) ?? 'N/A',
        ideLink: ideLink?.url,
        ideName: ideLink?.name,
        sourcePath: sourceFilePathOf(e.initiator),
        callerLine: e.initiator?.line,
        isFailure: _isFailureEvent(e),
        widgetTree: '',
        structuredWidgetTree: const {},
        compressedFrameData: compressedFrameData,
      );
      jsonTimelineEvents.add(timelineEvent);
    }
    final json = jsonEncode(
      jsonTimelineEvents.map((event) => event.toMap()).toList(),
    );
    events.writeAsStringSync(json);

    final htmlFile = spotTempDir.file('index.html');
    final isHotReloadServerRunning = await _isTimelineHotRestartServerRunning();
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final content = await renderTimelineWithJaspr(
        jsonTimelineEvents,
        sourceFiles: sourceFiles,
        hotRestart: isHotReloadServerRunning,
      );
      stopwatch.stop();
      if (stopwatch.elapsed > const Duration(seconds: 1)) {
        flt.debugPrint('Rendered HTML in ${stopwatch.elapsedMilliseconds}ms');
      }
      htmlFile.writeAsStringSync(content);
      if (await _isTimelineHotRestartServerRunning()) {
        flt.debugPrint(
          'View timeline here: http://localhost:5907/$timelineDirName',
        );
      } else {
        flt.debugPrint('View timeline here: file://${htmlFile.path}');
      }
    } catch (e, st) {
      developer.log(
        'Error writing timeline HTML file',
        name: 'spot.timeline',
        error: e,
        stackTrace: st,
      );
    }
  }
}

bool? _isTimelineHotRestartServerRunningCached;

/// Check if the Timeline Hot-Restart Server is running located at
/// `hot_restart_timeline/bin/main.dart`
///
/// This method is heavily cached because it might be executed for every tests
/// and it only is required for development.
/// The current implementation adds `100µs` for every test
Future<bool> _isTimelineHotRestartServerRunning() async {
  if (_isTimelineHotRestartServerRunningCached != null) {
    return _isTimelineHotRestartServerRunningCached!;
  }
  if (!_isSpotTest()) {
    return _isTimelineHotRestartServerRunningCached = false;
  }
  if (!await _isHotRestartServerRunning()) {
    return _isTimelineHotRestartServerRunningCached = false;
  }
  return _isTimelineHotRestartServerRunningCached = true;
}

/// Primitive check whether the current test is from the spot package.
///
/// Assumes the path of the spot package is called `spot`
///
/// This check is intended to be really fast because it is the check that is also
/// executed on every users device for every test where the timeline need to be rendered.
bool _isSpotTest() {
  final liveTest = getLiveTest();
  final suitePath = liveTest?.suite.path;
  if (suitePath == null) {
    return false;
  }
  if (Platform.isWindows) {
    if (suitePath.contains(r'\spot\test\')) {
      return true;
    }
  }
  if (suitePath.contains('/spot/test/')) {
    return true;
  }

  return false;
}

/// Checks if the spot hot-restart server is running on port 5907
Future<bool> _isHotRestartServerRunning() async {
  const host = 'localhost';
  const port = 5907;
  Socket? socket;
  try {
    socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 1),
    );
    flt.debugPrint('Server is running on $host:$port');
    return true;
  } on SocketException {
    return false;
  } finally {
    socket?.destroy();
  }
}

/// Whether [event] is the test failing.
///
/// Failures are reported through `addEvent` like everything else, so the label
/// is the only thing that separates them. Kept here, next to the labels spot
/// itself writes, rather than in the report UI.
bool _isFailureEvent(TimelineEvent event) {
  final label = event.eventType.label;
  return label.contains('Failed') || label.contains('Error');
}

String? _eventCaller(Frame? initiator, {String? line}) {
  if (initiator == null) {
    return null;
  }

  final memberPart = initiator.member != null ? '${initiator.member} ' : '';
  final uriPart = initiator.uri;
  final linePart = line ?? initiator.line?.toString() ?? '0';
  final columnPart = initiator.column?.toString() ?? '0';

  return '$memberPart$uriPart:$linePart:$columnPart';
}

extension on String {
  String takeFirst(int count) {
    if (count < 0) {
      throw ArgumentError('Count must be non-negative');
    }
    return substring(0, count.clamp(0, length));
  }

  String takeLast(int count) {
    if (count < 0) {
      throw ArgumentError('Count must be non-negative');
    }
    return substring(length - count.clamp(0, length));
  }

  String dropFirst(int count) {
    if (count < 0) {
      throw ArgumentError('Count must be non-negative');
    }
    return substring(count.clamp(0, length));
  }

  String dropLast(int count) {
    if (count < 0) {
      throw ArgumentError('Count must be non-negative');
    }
    return substring(0, length - count.clamp(0, length));
  }
}
