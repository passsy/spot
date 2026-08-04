import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';

void main() {
  final tree = <String, dynamic>{
    'id': '0',
    'name': 'MaterialApp',
    'children': [
      {
        'id': '1',
        'name': 'Scaffold',
        'children': [
          {'id': '2', 'name': 'AppBar', 'children': <dynamic>[]},
          {
            'id': '3',
            'name': 'Column',
            'children': [
              {'id': '4', 'name': 'Text', 'children': <dynamic>[]},
              {'id': '5', 'name': 'TextButton', 'children': <dynamic>[]},
            ],
          },
        ],
      },
    ],
  };

  test('collects every widget node for default expansion', () {
    expect(collectStructuredWidgetNodeIds(tree), {
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
    });
  });

  test('search matches widget types and keeps their ancestor paths', () {
    final result = searchStructuredWidgetTree(tree, 'text');

    expect(result.matches, {'4', '5'});
    expect(result.matches.toList(), ['4', '5']);
    expect(result.visible, {'0', '1', '3', '4', '5'});
    expect(result.visible, isNot(contains('2')));
  });

  test('search ignores case and surrounding whitespace', () {
    final result = searchStructuredWidgetTree(tree, '  appBAR ');

    expect(result.matches, {'2'});
    expect(result.visible, {'0', '1', '2'});
  });

  test('empty and unknown searches produce no filtered nodes', () {
    expect(searchStructuredWidgetTree(tree, '').matches, isEmpty);
    expect(searchStructuredWidgetTree(tree, 'ListView').visible, isEmpty);
  });

  test('Enter navigation cycles through matches in tree order', () {
    const matches = ['4', '5'];

    expect(nextStructuredWidgetSearchMatch(matches, null, reverse: false), '4');
    expect(nextStructuredWidgetSearchMatch(matches, '4', reverse: false), '5');
    expect(nextStructuredWidgetSearchMatch(matches, '5', reverse: false), '4');
  });

  test(
    'reverse search navigation starts at and cycles from the last match',
    () {
      const matches = ['4', '5'];

      expect(
        nextStructuredWidgetSearchMatch(matches, null, reverse: true),
        '5',
      );
      expect(nextStructuredWidgetSearchMatch(matches, '4', reverse: true), '5');
      expect(nextStructuredWidgetSearchMatch([], null, reverse: true), isNull);
    },
  );
}
