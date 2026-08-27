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
              {
                'id': '5',
                'name': 'TextButton',
                'isUserCode': true,
                'children': <dynamic>[],
              },
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

  test('keeps a selected tree row in place when rows are added above it', () {
    expect(
      treeScrollTopPreservingSelectedRow(
        currentScrollTop: 125,
        previousIndex: 4,
        nextIndex: 9,
      ),
      250,
    );
    expect(
      treeScrollTopPreservingSelectedRow(
        currentScrollTop: 25,
        previousIndex: 4,
        nextIndex: 9,
      ),
      150,
    );
    expect(
      treeScrollTopPreservingSelectedRow(
        currentScrollTop: 25,
        previousIndex: 9,
        nextIndex: 11,
      ),
      75,
    );
    expect(
      treeScrollTopPreservingSelectedRow(
        currentScrollTop: 25,
        previousIndex: 9,
        nextIndex: 0,
      ),
      0,
    );
  });

  test('user-code filter keeps only user-code widgets', () {
    final result = searchStructuredWidgetTree(
      tree,
      '',
      userCodeOnly: true,
      includeAncestorPaths: false,
    );

    expect(result.matches, {'5'});
    expect(result.visible, {'5'});
    expect(result.visible, isNot(contains('0')));
    expect(result.visible, isNot(contains('1')));
    expect(result.visible, isNot(contains('3')));
    expect(result.visible, isNot(contains('2')));
    expect(result.visible, isNot(contains('4')));
  });

  test('search and user-code filter apply together', () {
    final result = searchStructuredWidgetTree(
      tree,
      'text',
      userCodeOnly: true,
      includeAncestorPaths: false,
    );

    expect(result.matches, {'5'});
    expect(result.visible, {'5'});
  });

  test('user-code tree keeps framework branch points, not wrappers', () {
    final tree = <String, dynamic>{
      'id': '0',
      'name': 'RootWidget',
      'children': [
        {
          'id': '1',
          'name': 'Column',
          'children': [
            {'id': '2', 'name': 'TripCard', 'isUserCode': true},
            {'id': '3', 'name': 'MapCard', 'isUserCode': true},
          ],
        },
        {
          'id': '4',
          'name': 'Padding',
          'children': [
            {'id': '5', 'name': 'SaveButton', 'isUserCode': true},
          ],
        },
      ],
    };
    final visible = searchStructuredWidgetTree(
      tree,
      '',
      userCodeOnly: true,
      includeAncestorPaths: false,
    ).visible;

    final rows = flattenWidgetTree(
      tree,
      expandedNodeIds: const {},
      visibleNodeIds: visible,
      searchActive: true,
      promoteVisibleNodes: true,
    );

    expect(rows.map((row) => row.node['name']), [
      'RootWidget',
      'Column',
      'TripCard',
      'MapCard',
      'SaveButton',
    ]);
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
