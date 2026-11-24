import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';

void main() {
  test('limits tree text without scanning or rendering the remainder', () {
    final tree = [
      for (var line = 1; line <= 1000; line++) 'Widget $line',
    ].join('\n');

    final slice = sliceTimelineText(tree, startLine: 1, maximumLines: 250);

    expect(slice.startLine, 1);
    expect(slice.endLine, 250);
    expect(slice.visibleLineCount, 250);
    expect(slice.hasPrevious, isFalse);
    expect(slice.hasMore, isTrue);
    expect(slice.text, startsWith('Widget 1\n'));
    expect(slice.text, endsWith('Widget 250'));
    expect(slice.text, isNot(contains('Widget 251')));
  });

  test('returns the complete tree when it fits', () {
    const tree = 'Root\n  Child\n    Leaf';

    final slice = sliceTimelineText(tree, startLine: 1, maximumLines: 250);

    expect(slice.startLine, 1);
    expect(slice.endLine, 3);
    expect(slice.visibleLineCount, 3);
    expect(slice.hasPrevious, isFalse);
    expect(slice.hasMore, isFalse);
    expect(slice.text, tree);
  });

  test('pages through the complete tree without growing rendered text', () {
    final tree = [
      for (var line = 1; line <= 620; line++) 'Widget $line',
    ].join('\n');

    final slice = sliceTimelineText(tree, startLine: 251, maximumLines: 250);

    expect(slice.startLine, 251);
    expect(slice.endLine, 500);
    expect(slice.visibleLineCount, 250);
    expect(slice.hasPrevious, isTrue);
    expect(slice.hasMore, isTrue);
    expect(slice.text, startsWith('Widget 251\n'));
    expect(slice.text, endsWith('Widget 500'));
    expect(slice.text, isNot(contains('Widget 250')));
    expect(slice.text, isNot(contains('Widget 501')));
  });
}
