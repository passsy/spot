// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart' as flt;
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart' as x;
import 'package:spot/src/timeline/invoker.dart';
import 'package:spot/src/timeline/timeline.dart';
import 'package:spot/src/utils/file_extensions.dart';
import 'package:stack_trace/stack_trace.dart';

/// Writes the timeline as an HTML file
extension HtmlTimelinePrinter on Timeline {
  /// Prints the timeline as an HTML file.
  Future<void> printHTML() async {
    final pubspecYaml = io.File('pubspec.yaml');
    if (!pubspecYaml.existsSync()) {
      // test is executed on a device (or simulator), we can't store the file to be accessible from the host system
      print(
        'Warning: The timeline is only available for widget tests on the host system, not on a device',
      );
      return;
    }

    final String timelineDirName = () {
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
      return name;
    }();

    final timelineBuildDir = io.Directory('build').directory('timeline');
    final spotTempDir = timelineBuildDir.directory(timelineDirName);
    if (spotTempDir.existsSync()) {
      spotTempDir.deleteSync(recursive: true);
    }
    spotTempDir.createSync(recursive: true);

    const screenshotsDirName = 'screenshots';
    final screenshotsDir = spotTempDir.directory(screenshotsDirName);
    screenshotsDir.createSync(recursive: true);

    final events = spotTempDir.file('events.json');
    final List<x.TimelineEvent> jsonTimelineEvents = [];
    for (final e in this.events) {
      final screenshot = e.screenshot;
      io.File? screenshotFile;
      if (screenshot != null) {
        // save screenshots relative to the events.json file in screenshots/
        screenshotFile = screenshotsDir.file('${screenshot.name}.png');
        final flattened = await screenshot.flattenedImage();
        final pngBytes = await flattened.readPngBytes();
        screenshotFile.writeAsBytesSync(pngBytes);
      }

      final timelineEvent = x.TimelineEvent(
        eventType: e.eventType.label,
        details: e.details,
        timestamp: e.timestamp.toIso8601String(),
        screenshotUrl: screenshotFile != null
            ? './$screenshotsDirName/${screenshotFile.name}'
            : null,
        color: e.color == flt.Colors.grey
            ? null
            // ignore: deprecated_member_use
            : e.color.value & 0xFFFFFF,
        caller: _eventCaller(e.initiator) ?? 'N/A',
        jetBrainsLink: _jetBrainsURL(e),
      );
      jsonTimelineEvents.add(timelineEvent);
    }
    final json = const JsonEncoder.withIndent('  ')
        .convert(jsonTimelineEvents.map((e) => e.toMap()).toList());
    events.writeAsStringSync(json);

    final htmlFile = spotTempDir.file('index.html');
    final isHotReloadServerRunning = await _isTimelineHotRestartServerRunning();
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final content = await renderTimelineWithJaspr(
        jsonTimelineEvents,
        hotRestart: isHotReloadServerRunning,
      );
      stopwatch.stop();
      if (stopwatch.elapsed > const Duration(seconds: 1)) {
        print('Rendered HTML in ${stopwatch.elapsedMilliseconds}ms');
      }
      htmlFile.writeAsStringSync(content);
      if (await _isTimelineHotRestartServerRunning()) {
        print('View timeline here: http://localhost:5907/$timelineDirName');
      } else {
        print('View timeline here: file://${htmlFile.path}');
      }
    } catch (e, st) {
      print('Error writing HTML file: $e $st');
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
  if (io.Platform.isWindows) {
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
  io.Socket? socket;
  try {
    socket = await io.Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 1),
    );
    print('Server is running on $host:$port');
    return true;
  } on io.SocketException catch (_) {
    print('No server running on $host:$port');
    return false;
  } finally {
    socket?.destroy();
  }
}

String? _projectName() {
  io.Directory? dir = io.Directory.current;
  String? projectDir;

  while (dir != null) {
    final ideaDir = io.Directory('${dir.path}/.idea');
    if (ideaDir.existsSync()) {
      // Update to the current directory path
      projectDir = dir.path;
      break;
    }

    // Move up to the parent directory
    final parentDir = dir.parent;
    if (dir.path == parentDir.path) {
      // Reached the root directory
      break;
    }
    dir = parentDir;
  }

  if (projectDir == null) return null;
  final name = projectDir.split('/').lastOrNull;
  return name;
}

String? _eventCaller(Frame? initiator, {String? line}) {
  if (initiator == null) return null;

  final memberPart = initiator.member != null ? '${initiator.member} ' : '';
  final uriPart = initiator.uri;
  final linePart = line ?? initiator.line?.toString() ?? '0';
  final columnPart = initiator.column?.toString() ?? '0';

  return '$memberPart$uriPart:$linePart:$columnPart';
}

String? _jetBrainsURL(TimelineEvent event) {
  final initiator = event.initiator;
  if (initiator == null) return null;

  final isIntelliJ = io.Platform.environment.values.any(
    (value) => value.toLowerCase().contains('intellij'),
  );
  if (!isIntelliJ) return null;

  final lineNumber = (initiator.line ?? 0) - 1;
  final clampedLine = lineNumber >= 0 ? lineNumber.toString() : '0';

  final caller = _eventCaller(initiator, line: clampedLine);
  final name = _projectName();
  if (caller == null || name == null) return null;

  final path = caller.trim().split(name).last.trim();
  if (path.isEmpty) return null;

  final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

  return 'jetbrains://idea/navigate/reference?project=$name&path=$normalizedPath';
}
