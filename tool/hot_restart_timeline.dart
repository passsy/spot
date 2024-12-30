import 'dart:convert';
import 'dart:io';

import 'package:server_nano/server_nano.dart';
import 'package:spot/src/timeline/html/render_timeline.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

import 'compile_js.dart' as compile_js;

Future<void> main() async {
  ProcessSignal.sigint.watch().listen((event) {
    exit(0);
  });

  // Watch for changes in lib/ and then call compile_js.dart
  final libDir = Directory('lib');

  final watcher = libDir.watch(recursive: true);
  watcher.listen((event) {
    if (event.path.endsWith('script.js.g.dart')) {
      return;
    }
    print(event);
    triggerRebuild();
  });

  triggerRebuild();

  final timelineDir = Directory('build/timeline');
  if (!timelineDir.existsSync()) {
    timelineDir.createSync(recursive: true);
  }

  final server = Server();
  server.static('build/timeline/');

  server.listen(port: 3000);
  final timelineFiles = timelineDir.listSync();
  for (final file in timelineFiles) {
    print('http://localhost:3000/${file.path.split('/').last}');
  }
}

bool _rebuilding = false;
bool _pendingRebuild = false;

void triggerRebuild() {
  if (_rebuilding) {
    _pendingRebuild = true;
    return;
  }
  _rebuilding = true;
  // ignore: avoid_print
  print('Recompiling...');
  (compile_js.main(), renderHtml()).wait.whenComplete(() {
    _rebuilding = false;
    if (_pendingRebuild) {
      _pendingRebuild = false;
      triggerRebuild();
    }
  });
}

Future<void> renderHtml() async {
  final eventsFile = File('build/timeline/events.json');
  if (!eventsFile.existsSync()) {
    return;
  }
  final eventsText = await eventsFile.readAsString();
  final eventsJson = jsonDecode(eventsText) as List;
  final events = eventsJson
      .map((e) => TimelineEvent.fromMap(e as Map<String, dynamic>))
      .toList();

  final htmlText = await renderTimelineWithJaspr(
    events,
    renderMode: RenderMode.hotRestartHtml,
  );
  final htmlFile = File('build/timeline/index.html');
  htmlFile.writeAsStringSync(htmlText);
}
