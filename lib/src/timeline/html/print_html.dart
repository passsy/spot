// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart' as flt;
import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/sources/script.js.g.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart' as x;
import 'package:spot/src/timeline/timeline.dart';
import 'package:stack_trace/stack_trace.dart';

/// Enable during development of the timeline
///
/// Set to true to print the localhost path when a timeline is generated.
const bool timelineHtmlDev = false;

/// Writes the timeline as an HTML file
extension HtmlTimelinePrinter on Timeline {
  /// Prints the timeline as an HTML file.
  Future<void> printHTML() async {
    final Directory spotTempDir;

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

    final timelineBuildDir = Directory('build/timeline');
    spotTempDir = timelineBuildDir.directory(timelineDirName);

    if (spotTempDir.existsSync()) {
      spotTempDir.deleteSync(recursive: true);
    }
    spotTempDir.createSync(recursive: true);
    final screenshotsDir = Directory(
      '${spotTempDir.absolute.path}/screenshots',
    );
    screenshotsDir.createSync(recursive: true);

    final events = File('${spotTempDir.absolute.path}/events.json');
    final jsonTimelineEvents = this.events.map((e) {
      // save screenshots relative to the events.json file in screenshots/
      File? screenshotFile;
      if (e.screenshot != null) {
        final name = e.screenshot!.file.name;
        screenshotFile = screenshotsDir.file(name);
        e.screenshot!.file.copySync(screenshotFile.path);
      }

      return x.TimelineEvent(
        eventType: e.eventType.label,
        details: e.details,
        timestamp: e.timestamp.toIso8601String(),
        screenshotUrl: screenshotFile?.path,
        color: e.color == flt.Colors.grey
            ? null
            // ignore: deprecated_member_use
            : e.color.value & 0xFFFFFF,
        caller: _eventCaller(e.initiator) ?? 'N/A',
        jetBrainsLink: _jetBrainsURL(e),
      );
    }).toList();
    final json = const JsonEncoder.withIndent('  ')
        .convert(jsonTimelineEvents.map((e) => e.toMap()).toList());
    events.writeAsStringSync(json);

    final scriptFile = File('${spotTempDir.absolute.path}/script.js');
    scriptFile.writeAsStringSync(timelineJS);
    final htmlFile = File('${spotTempDir.absolute.path}/index.html');
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final content = await renderTimelineWithJaspr(
        jsonTimelineEvents,
        renderMode: HtmlTimelineRenderMode.staticHtml,
      );
      stopwatch.stop();
      if (stopwatch.elapsed > const Duration(seconds: 1)) {
        print('Rendered HTML in ${stopwatch.elapsedMilliseconds}ms');
      }
      htmlFile.writeAsStringSync(content);
      if (timelineHtmlDev) {
        print('View timeline here: http://localhost:3000/$timelineDirName');
      } else {
        print('View timeline here: file://${htmlFile.path}');
      }
    } catch (e, st) {
      print('Error writing HTML file: $e $st');
    }
  }
}

String? _projectName() {
  Directory? dir = Directory.current;
  String? projectDir;

  while (dir != null) {
    final ideaDir = Directory('${dir.path}/.idea');
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

  final isIntelliJ = Platform.environment.values.any(
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
