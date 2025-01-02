// ignore_for_file: avoid_print

import 'dart:io';

import 'package:server_nano/server_nano.dart';

Future<void> main() async {
  ProcessSignal.sigint.watch().listen((event) {
    exit(0);
  });

  final timelineFile = File('lib/src/timeline/html/print_html.dart');
  final timelineContent = timelineFile.readAsStringSync();
  if (timelineContent.contains('timelineHtmlDev = false')) {
    print('Warning: Set `timelineHtmlDev = true;` in ${timelineFile.path} '
        'to get the localhost path when a timeline is generated.\n');
    await Future.delayed(const Duration(seconds: 2));
  }

  // Watch for changes in lib/ and then call compile_js.dart
  final libDir = Directory('lib');

  final spotLibWatcher = libDir.watch(recursive: true);
  spotLibWatcher.listen((event) {
    if (event.path.endsWith('script.js.g.dart')) {
      return;
    }
    rebuildJs();
    rebuildHtml();
  });

  final timelineHotReloadDir = Directory('build/timeline/');
  if (!timelineHotReloadDir.existsSync()) {
    timelineHotReloadDir.createSync(recursive: true);
  }

  final timelineWatcher = timelineHotReloadDir.watch(recursive: true);
  timelineWatcher.listen((event) {
    if (event.path.endsWith('events.json')) {
      rebuildHtml();
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

Future<void> rebuildJs() async {
  if (_rebuildingJs) {
    _pendingRebuildJs = true;
    return;
  }
  _rebuildingJs = true;
  await Future.delayed(const Duration(milliseconds: 100)); // debounce
  _pendingRebuildJs = false;
  print('Recompiling...');
  Process.run('dart', ['tool/compile_js.dart']).printErrors.whenComplete(() {
    _rebuildingJs = false;
    if (_pendingRebuildJs) {
      _pendingRebuildJs = false;
      rebuildJs();
    }
  });
}

bool _rebuildingHtml = false;
bool _pendingRebuildHtml = false;

Future<void> rebuildHtml() async {
  if (_rebuildingHtml) {
    _pendingRebuildHtml = true;
    return;
  }
  _rebuildingHtml = true;
  await Future.delayed(const Duration(milliseconds: 100)); // debounce
  _pendingRebuildHtml = false;
  print('Rendering...');
  // start a new process so that it picks up the changes in the jaspr code
  final stopwatch = Stopwatch()..start();
  Process.run('dart', ['tool/render_html.dart']).printErrors.whenComplete(() {
    print('Rendered in ${stopwatch.elapsedMilliseconds}ms');
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
