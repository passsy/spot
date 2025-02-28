import 'dart:async';

import 'package:flutter/foundation.dart';

Future<String> captureConsoleOutput(
  Future<void> Function() testFunction,
) async {
  final StringBuffer buffer = StringBuffer();
  final ZoneSpecification spec = ZoneSpecification(
    print: (self, parent, zone, line) {
      if (kIsWeb && line.contains('not supported on the web')) {
        return;
      }
      buffer.writeln(line);
    },
  );

  await Zone.current.fork(specification: spec).run(() async {
    await testFunction();
  });

  return buffer.toString();
}
