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
      return 'recordLiveTimeline()';
    case TimelineMode.record:
      return 'recordOnErrorTimeline()';
    case TimelineMode.off:
      return 'stopRecordingTimeline()';
  }
}
