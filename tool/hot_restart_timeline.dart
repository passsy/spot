// ignore_for_file: avoid_print

import 'dart:io';

import 'package:server_nano/server_nano.dart';

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
  server.get('/', (req, resp) {
    final timelines = timelineHotReloadDir
        .listSync(recursive: true)
        .where((file) => file.path.endsWith('.html'))
        .map((file) {
      final relative = file.path.split('build/timeline/').last;
      return '<li><a href="/$relative">$relative</a></li>\n';
    }).join('\n');
    resp.sendHtmlText(
      '<h1>Spot timelines</h1>\n\n'
      '<ul>\n$timelines</ul>',
    );
  });

  server.listen(port: 5907);
  final timelineFiles = timelineHotReloadDir.listSync(recursive: true);
  for (final file in timelineFiles) {
    if (!file.path.endsWith('.html')) {
      continue;
    }
    final relative = file.path.split('build/timeline/').last;
    print('http://localhost:5907/$relative');
  }
}

bool _rebuildingJs = false;
bool _pendingRebuildJs = false;

final dartExecutable = Platform.resolvedExecutable;

Future<void> rebuildJs() async {
  if (_rebuildingJs) {
    _pendingRebuildJs = true;
    return;
  }
  _rebuildingJs = true;
  await Future.delayed(const Duration(milliseconds: 100)); // debounce
  _pendingRebuildJs = false;
  final timestamp = DateTime.now().toIso8601String().substring(11, 19);
  print('$timestamp Recompiling...');
  try {
    final result = await Process.run(dartExecutable, ['tool/compile_js.dart']);
    if (result.exitCode != 0) {
      print('Compilation failed');
      print(result.stdout);
      print(result.stderr);
    }
  } finally {
    _rebuildingJs = false;
    if (_pendingRebuildJs) {
      _pendingRebuildJs = false;
      rebuildJs();
    }
  }
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
  final timestamp = DateTime.now().toIso8601String().substring(11, 19);
  print('$timestamp Rendering...');
  // start a new process so that it picks up the changes in the jaspr code
  final stopwatch = Stopwatch()..start();
  try {
    final result = await Process.run(dartExecutable, ['tool/render_html.dart']);
    if (result.exitCode != 0) {
      print('Render failed');
      print(result.stdout);
      print(result.stderr);
    }
  } finally {
    print('Rendered in ${stopwatch.elapsedMilliseconds}ms');
    _rebuildingHtml = false;
    if (_pendingRebuildHtml) {
      _pendingRebuildHtml = false;
      rebuildHtml();
    }
  }
}
