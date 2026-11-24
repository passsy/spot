import 'dart:async';
import 'dart:io';

import 'package:spot/src/timeline/html/serve_timeline.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    stdout.writeln(
      'Usage: dart run tool/serve_timeline.dart '
      '[timeline-directory-or-index.html] [--port PORT]',
    );
    return;
  }

  final port = _readPort(arguments);
  final reportDirectory = _readReportDirectory(arguments);
  final server = await serveTimeline(reportDirectory, port: port);
  final url = Uri(
    scheme: 'http',
    host: server.address.address,
    port: server.port,
    path: '/',
  );

  stdout.writeln(url);
  stdout.writeln('Serving ${reportDirectory.absolute.path}');
  stdout.writeln('Press Ctrl+C to stop.');

  final stopped = Completer<void>();
  final signalSubscription = ProcessSignal.sigint.watch().listen((_) async {
    await server.close(force: true);
    if (!stopped.isCompleted) {
      stopped.complete();
    }
  });
  await stopped.future;
  await signalSubscription.cancel();
}

int _readPort(List<String> arguments) {
  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument.startsWith('--port=')) {
      return _parsePort(argument.substring('--port='.length));
    }
    if (argument == '--port') {
      if (index + 1 >= arguments.length) {
        throw const FormatException('--port requires a value');
      }
      return _parsePort(arguments[index + 1]);
    }
  }
  return 0;
}

int _parsePort(String value) {
  final port = int.tryParse(value);
  if (port == null || port < 0 || port > 65535) {
    throw FormatException('Invalid port: $value');
  }
  return port;
}

Directory _readReportDirectory(List<String> arguments) {
  final positional = <String>[];
  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument == '--port') {
      index++;
      continue;
    }
    if (!argument.startsWith('--')) {
      positional.add(argument);
    }
  }

  if (positional.length > 1) {
    throw const FormatException('Expected at most one timeline path');
  }
  if (positional.isEmpty) {
    return _latestTimelineDirectory();
  }

  final entityType = FileSystemEntity.typeSync(positional.single);
  if (entityType == FileSystemEntityType.file) {
    return File(positional.single).absolute.parent;
  }
  return Directory(positional.single);
}

Directory _latestTimelineDirectory() {
  final timelineRoot = Directory('build/timeline');
  if (!timelineRoot.existsSync()) {
    throw StateError('No generated timelines found in build/timeline');
  }

  final candidates =
      timelineRoot.listSync().whereType<Directory>().where((directory) {
        final index = File(
          '${directory.path}${Platform.pathSeparator}index.html',
        );
        return index.existsSync();
      }).toList()..sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });
  if (candidates.isEmpty) {
    throw StateError('No generated timelines found in build/timeline');
  }
  return candidates.first;
}
