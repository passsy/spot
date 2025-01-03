// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:hot_restart_timeline/server.dart';

// Platform.script points to bin/main.dart
final packageRoot = Directory(Platform.script.path).parent.parent;
final spotPackageRoot = packageRoot.parent;

Future<void> main() async {
  // Watch for changes in lib/ and then call compile_js.dart
  final libDir = spotPackageRoot.directory('lib');

  final spotLibWatcher = libDir.watch(recursive: true);
  spotLibWatcher.listen((event) {
    if (event.path.endsWith('script.js.g.dart')) {
      return;
    }
    rebuildJs();
    rebuildHtml();
  });

  final timelineHotReloadDir = spotPackageRoot.directory('build/timeline/');
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

  startServer(timelineHotReloadDir);
  print('http://localhost:5907/');
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
    final result = await Process.run(
      dartExecutable,
      ['tool/compile_js.dart'],
      workingDirectory: spotPackageRoot.path,
    );
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
    final result = await Process.run(
      dartExecutable,
      ['tool/render_html.dart'],
      workingDirectory: packageRoot.path,
    );
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
