/// A timeline event as spot prints it to the console.
class PrintedEvent {
  PrintedEvent(this.lines);

  /// The lines between the header and the separator.
  final List<String> lines;

  String get type => _field('Event Type') ?? '';

  /// Spans several lines on CI, everything up to the caller.
  String get details {
    final start = lines.indexWhere((line) => line.startsWith('Details: '));
    if (start == -1) {
      return '';
    }
    final end = lines.indexWhere((line) => line.startsWith('Caller: '));
    return lines
        .sublist(start, end == -1 ? null : end)
        .join('\n')
        .substring('Details: '.length);
  }

  String? get caller => _field('Caller');

  /// The file path, or the note that the platform has no screenshot links.
  String? get screenshot =>
      _field('Screenshot') ??
      lines.where((line) => line.startsWith('Screenshot links ')).firstOrNull;

  String? get timestamp => _field('Timestamp');

  /// Type and first line of the details, the part that tells events apart.
  String get summary => '$type: ${details.split('\n').first}';

  String? _field(String name) => lines
      .where((line) => line.startsWith('$name: '))
      .map((line) => line.substring(name.length + 2))
      .firstOrNull;

  @override
  String toString() => summary;
}

const String _header =
    '==================== Timeline Event ====================';
const String _separator =
    '========================================================';

/// Every timeline event in [output], in the order it was printed.
List<PrintedEvent> printedEvents(String output) {
  return output.split('$_header\n').skip(1).map((block) {
    final lines = block.split('\n');
    return PrintedEvent(lines.takeWhile((l) => l != _separator).toList());
  }).toList();
}
