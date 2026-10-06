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
