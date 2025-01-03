import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final globalTimelineDir = Directory('build').directory('timeline');
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
      renderMode: HtmlTimelineRenderMode.hotRestartHtml,
    );
    file.writeAsStringSync(htmlText);
  }
}
