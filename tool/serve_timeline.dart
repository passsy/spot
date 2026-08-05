import 'dart:async';
import 'dart:io';

/// Serves one generated static timeline report on the loopback interface.
///
/// Passing port `0` lets the operating system select an available port.
Future<HttpServer> serveTimeline(
  Directory reportDirectory, {
  int port = 0,
}) async {
  final directory = reportDirectory.absolute;
  final indexFile = File(
    '${directory.path}${Platform.pathSeparator}index.html',
  );
  if (!indexFile.existsSync()) {
    throw ArgumentError.value(
      reportDirectory.path,
      'reportDirectory',
      'Expected a generated timeline directory containing index.html',
    );
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  server.listen((request) => _serveRequest(request, directory));
  return server;
}

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

Future<void> _serveRequest(HttpRequest request, Directory root) async {
  final response = request.response;
  response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');

  if (request.method != 'GET' && request.method != 'HEAD') {
    response.statusCode = HttpStatus.methodNotAllowed;
    await response.close();
    return;
  }

  final segments = request.uri.pathSegments;
  final escapesRoot = segments.any((segment) {
    return segment == '..' || segment.contains('/') || segment.contains(r'\');
  });
  if (escapesRoot) {
    response.statusCode = HttpStatus.forbidden;
    await response.close();
    return;
  }

  final relativePath = segments.isEmpty
      ? 'index.html'
      : segments.join(Platform.pathSeparator);
  final file = File('${root.path}${Platform.pathSeparator}$relativePath');
  if (!file.existsSync()) {
    response.statusCode = HttpStatus.notFound;
    await response.close();
    return;
  }

  response.headers.contentType = _contentType(file.path);
  response.contentLength = file.lengthSync();
  if (request.method == 'GET') {
    await response.addStream(file.openRead());
  }
  await response.close();
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) {
    return ContentType.html;
  }
  if (path.endsWith('.json')) {
    return ContentType.json;
  }
  if (path.endsWith('.js')) {
    return ContentType('text', 'javascript', charset: 'utf-8');
  }
  if (path.endsWith('.png')) {
    return ContentType('image', 'png');
  }
  if (path.endsWith('.svg')) {
    return ContentType('image', 'svg+xml');
  }
  return ContentType.binary;
}
