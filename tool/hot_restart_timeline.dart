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

  final spotLibWatcher = libDir.watch(recursive: true);
  spotLibWatcher.listen((event) {
    if (event.path.endsWith('script.js.g.dart')) {
      return;
    }
    rebuildJs();
  });

  final timelineHotReloadDir = Directory('build/timeline/');
  if (!timelineHotReloadDir.existsSync()) {
    timelineHotReloadDir.createSync(recursive: true);
  }

  final timelineWatcher = timelineHotReloadDir.watch(recursive: true);
  timelineWatcher.listen((event) {
    if (event.path.endsWith('events.json')) {
      renderHtml();
    }
  });

  rebuildJs();
  rebuildHtml();

  final server = Server();
  server.static('build/timeline/');

  server.listen(port: 3000);
  final timelineFiles = timelineHotReloadDir.listSync(recursive: true);
  for (final file in timelineFiles) {
    if (!file.path.endsWith('.html')) {
      continue;
    }
    final relative = file.path.split('build/timeline/').last;
    print('http://localhost:3000/$relative');
  }
}

bool _rebuildingJs = false;
bool _pendingRebuildJs = false;

void rebuildJs() {
  if (_rebuildingJs) {
    _pendingRebuildJs = true;
    return;
  }
  _rebuildingJs = true;
  // ignore: avoid_print
  print('Recompiling...');
  compile_js.main().printErrors.whenComplete(() {
    _rebuildingJs = false;
    if (_pendingRebuildJs) {
      _pendingRebuildJs = false;
      rebuildJs();
    }
  });
}

bool _rebuildingHtml = false;
bool _pendingRebuildHtml = false;

void rebuildHtml() {
  if (_rebuildingHtml) {
    _pendingRebuildHtml = true;
    return;
  }
  _rebuildingHtml = true;
  // ignore: avoid_print
  print('Rendering...');
  renderHtml().printErrors.whenComplete(() {
    _rebuildingHtml = false;
    if (_pendingRebuildHtml) {
      _pendingRebuildHtml = false;
      rebuildHtml();
    }
  });
}

extension JustPrintErrors<T> on Future<T> {
  Future<void> get printErrors async {
    try {
      await this;
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }
}

Future<void> renderHtml() async {
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
      renderMode: RenderMode.hotRestartHtml,
    );
    file.writeAsStringSync(htmlText);
  }
}
