import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/source_excerpt.dart';
import 'package:stack_trace/stack_trace.dart';

File setupSourceFile({required int lineCount}) {
  final directory = Directory.systemTemp.createTempSync('spot-source-excerpt-');
  addTearDown(() => directory.deleteSync(recursive: true));
  return File('${directory.path}/example_test.dart')..writeAsStringSync(
    [
      for (var line = 1; line <= lineCount; line++) 'source line $line',
    ].join('\n'),
  );
}

void main() {
  test('reads the whole file, not a window around the caller', () {
    final source = setupSourceFile(lineCount: 20);

    final file = readTimelineSourceFile(
      Frame(source.uri, 10, 3, 'main.<anonymous closure>'),
    );

    expect(file, isNotNull);
    expect(file!.lines, hasLength(20));
    expect(file.lines.first, 'source line 1');
    expect(file.lines.last, 'source line 20');
    expect(file.truncated, isFalse);
  });

  test('ignores source locations that cannot be read locally', () {
    final file = readTimelineSourceFile(
      Frame(Uri.parse('package:example/example.dart'), 10, 3, 'example'),
    );

    expect(file, isNull);
  });

  test('ignores a caller line past the end of the file', () {
    final source = setupSourceFile(lineCount: 5);

    final file = readTimelineSourceFile(Frame(source.uri, 99, 1, 'main'));

    expect(file, isNull);
  });

  test('cuts off files that are too long to be worth showing', () {
    final source = setupSourceFile(lineCount: 5200);

    final file = readTimelineSourceFile(Frame(source.uri, 10, 1, 'main'));

    expect(file!.lines, hasLength(5000));
    expect(file.truncated, isTrue);
  });

  test('reads each file once, however many callers point into it', () {
    final source = setupSourceFile(lineCount: 12);
    final other = setupSourceFile(lineCount: 4);

    final files = readTimelineSourceFiles([
      Frame(source.uri, 2, 1, 'main'),
      Frame(source.uri, 7, 1, 'main'),
      Frame(other.uri, 1, 1, 'main'),
      null,
      Frame(Uri.parse('package:example/example.dart'), 1, 1, 'example'),
    ]);

    expect(files, hasLength(2));
    expect(
      files[sourceFilePathOf(Frame(source.uri, 2, 1, 'main'))]!.lines,
      hasLength(12),
    );
    expect(
      files[sourceFilePathOf(Frame(other.uri, 1, 1, 'main'))]!.lines,
      hasLength(4),
    );
  });

  test('has no path for a file that is not readable from here', () {
    expect(
      sourceFilePathOf(Frame(Uri.parse('package:example/x.dart'), 1, 1, 'x')),
      isNull,
    );
  });
}
