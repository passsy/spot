import 'package:spot/src/screenshot/screenshot.dart';
import 'package:spot/src/timeline/timeline.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Extension that adds a method to print the timeline to the console.
extension ConsoleTimelinePrinter on Timeline {
  /// Prints the complete timeline to the console.
  void printToConsole() {
    // ignore: avoid_print
    final frame = mostRelevantCaller(trace: test.test.trace);
    final location = frame != null
        ? ' at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : '';
    // ignore: avoid_print
    print('Timeline of test: ${test.test.name}$location');
    for (final event in events) {
      printEventToConsole(event);
    }
  }

  /// Prints a single event to the console.
  Future<void> printEventToConsole(TimelineEvent event) async {
    final isCi = Invoker.current?.liveTest.isCI == true;
    final StringBuffer buffer = StringBuffer();
    final frame = event.initiator;
    final caller = frame != null
        ? 'at ${frame.member} ${frame.uri}:${frame.line}:${frame.column}'
        : 'N/A';
    final details =
        isCi ? event.details : event.details.split('\n').firstOrNull;
    buffer.writeln('==================== Timeline Event ====================');
    buffer.writeln('Event Type: ${event.eventType}');
    if (details != null) {
      buffer.writeln('Details: $details');
    }
    buffer.writeln('Caller: $caller');
    final pngPath = await event.screenshot?.materializePng();
    if (pngPath != null) {
      buffer.writeln('Screenshot: file://$pngPath');
    }
    buffer.writeln('Timestamp: ${event.timestamp.toIso8601String()}');
    buffer.writeln('========================================================');

    // ignore: avoid_print
    print(buffer);
  }
}
