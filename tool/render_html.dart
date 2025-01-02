import 'dart:convert';
import 'dart:io';

import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

Future<void> main() async {
  final timelineDir = Directory('build/timeline/');
  if (!timelineDir.existsSync()) {
    return;
  }

  final generatedScriptFile = File('${timelineDir.path}/script.js');

  final htmlFiles =
      timelineDir.listSync(recursive: true).whereType<File>().where((file) {
    return file.path.endsWith('.html');
  });

  for (final file in htmlFiles) {
    final timelineDir = file.parent;
    final eventsFile = File('${timelineDir.path}/events.json');
    if (!eventsFile.existsSync()) {
      continue;
    }

    final scriptLink = Link('${timelineDir.path}/script.js');
    final scriptLinkFile = File('${timelineDir.path}/script.js');
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
      final relative = screenshotPath?.split('build/timeline/').last;
      if (relative != null) {
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
