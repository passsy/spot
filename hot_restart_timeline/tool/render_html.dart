import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

// Platform.script points to tool/render_html.dart
final packageRoot = Directory(Platform.script.path).parent.parent;
final spotPackageRoot = packageRoot.parent;

/// Renders the timeline HTML files to be served by the server
Future<void> main() async {
  final globalTimelineDir =
      spotPackageRoot.directory('build').directory('timeline');
  if (!globalTimelineDir.existsSync()) {
    return;
  }

  final generatedScriptFile = globalTimelineDir.file('script.js');

  final htmlFiles = globalTimelineDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) {
    return file.path.endsWith('.html');
  });

  for (final file in htmlFiles) {
    final timelineDir = file.parent;
    final eventsFile = timelineDir.file('events.json');
    if (!eventsFile.existsSync()) {
      continue;
    }

    final scriptLinkFile = timelineDir.file('script.js');
    final scriptLink = Link(scriptLinkFile.path);
    if (scriptLink.existsSync()) {
      if (scriptLink.targetSync() != generatedScriptFile.path) {
        scriptLink.updateSync(generatedScriptFile.path);
      }
    } else {
      if (scriptLinkFile.existsSync()) {
        scriptLinkFile.deleteSync();
      }
      scriptLink.createSync(generatedScriptFile.path, recursive: true);
    }

    final eventsText = await eventsFile.readAsString();
    final eventsJson = jsonDecode(eventsText) as List;
    final events = eventsJson.map((e) {
      final map = e as Map<String, dynamic>;
      final screenshotPath = map['screenshotUrl'] as String?;
      if (screenshotPath != null) {
        final relative =
            path.relative(screenshotPath, from: globalTimelineDir.path);
        map['screenshotUrl'] = relative;
      }
      return TimelineEvent.fromMap(map);
    }).toList();

    final htmlText = await renderTimelineWithJaspr(
      events,
      inlineScripts: false,
      hotRestart: true,
    );
    file.writeAsStringSync(htmlText);
  }
}
