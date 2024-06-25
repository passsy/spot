import 'dart:async';

import 'package:spot/src/timeline/timeline.dart';

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

String timelineInitiatorForModeAsString(TimelineMode timelineMode) {
  switch (timelineMode) {
    case TimelineMode.live:
      return 'localTimelineMode = TimelineMode.live;';
    case TimelineMode.record:
      return 'localTimelineMode = TimelineMode.record;';
    case TimelineMode.off:
      return 'localTimelineMode = TimelineMode.off;';
  }
}
