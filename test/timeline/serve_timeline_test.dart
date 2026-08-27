import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/serve_timeline.dart';

void main() {
  test('serves a static timeline and its assets over loopback HTTP', () async {
    final directory = await Directory.systemTemp.createTemp(
      'spot_timeline_preview_',
    );
    addTearDown(() => directory.delete(recursive: true));
    File(
      '${directory.path}${Platform.pathSeparator}index.html',
    ).writeAsStringSync('<h1>Timeline preview</h1>');
    File(
      '${directory.path}${Platform.pathSeparator}events.json',
    ).writeAsStringSync('{"events":2}');

    final server = await serveTimeline(directory);
    addTearDown(() => server.close(force: true));
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final origin = Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
    );

    final indexResponse = await client
        .getUrl(origin)
        .then((request) => request.close());
    final indexBody = await utf8.decodeStream(indexResponse);
    final eventsResponse = await client
        .getUrl(origin.resolve('/events.json'))
        .then((request) => request.close());
    final eventsBody = await utf8.decodeStream(eventsResponse);

    expect(indexResponse.statusCode, HttpStatus.ok);
    expect(indexResponse.headers.contentType?.mimeType, 'text/html');
    expect(indexBody, contains('Timeline preview'));
    expect(eventsResponse.statusCode, HttpStatus.ok);
    expect(eventsResponse.headers.contentType?.mimeType, 'application/json');
    expect(eventsBody, '{"events":2}');
  });

  test('rejects paths escaping the report directory', () async {
    final directory = await Directory.systemTemp.createTemp(
      'spot_timeline_preview_',
    );
    addTearDown(() => directory.delete(recursive: true));
    File(
      '${directory.path}${Platform.pathSeparator}index.html',
    ).writeAsStringSync('timeline');

    final server = await serveTimeline(directory);
    addTearDown(() => server.close(force: true));
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final uri = Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
      path: '/..%2Foutside.txt',
    );

    final response = await client
        .getUrl(uri)
        .then((request) => request.close());

    expect(response.statusCode, HttpStatus.forbidden);
  });
}
