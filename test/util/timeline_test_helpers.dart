import 'dart:async';

Future<String> captureConsoleOutput(
  Future<void> Function() testFunction,
) async {
  final StringBuffer buffer = StringBuffer();
  final ZoneSpecification spec = ZoneSpecification(
    print: (self, parent, zone, line) {
      buffer.writeln(line);
    },
  );

  await Zone.current.fork(specification: spec).run(() async {
    await testFunction();
  });

  return buffer.toString();
}
