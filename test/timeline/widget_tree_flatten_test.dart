import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';

Map<String, dynamic> node(
  String id, {
  List<Map<String, dynamic>> children = const [],
}) {
  return {'id': id, 'name': 'Widget$id', 'children': children};
}

/// `id@depth` for every row, which is what the flattening decides.
List<String> rowsOf(
  Map<String, dynamic>? root, {
  Set<String>? expanded,
  Set<String> visible = const {},
  bool searchActive = false,
}) {
  return flattenWidgetTree(
    root,
    expandedNodeIds: expanded ?? _allIds(root),
    visibleNodeIds: visible,
    searchActive: searchActive,
  ).map((row) => '${row.id}@${row.depth}').toList();
}

Set<String> _allIds(Map<String, dynamic>? node) {
  if (node == null) {
    return {};
  }
  return {
    node['id'] as String,
    for (final child in (node['children'] as List).cast<Map<String, dynamic>>())
      ..._allIds(child),
  };
}

void main() {
  test('a chain of single children stays at one indentation', () {
    // The Flutter inspector shows wrapper chains without stepping right for
    // each one, otherwise a real widget tree walks off the pane.
    final root = node(
      'a',
      children: [
        node(
          'b',
          children: [
            node('c', children: [node('d')]),
          ],
        ),
      ],
    );

    expect(rowsOf(root), ['a@0', 'b@0', 'c@0', 'd@0']);
  });

  test('a branch indents its children', () {
    final root = node(
      'a',
      children: [
        node('b', children: [node('c')]),
        node('d'),
      ],
    );

    expect(rowsOf(root), ['a@0', 'b@1', 'c@1', 'd@1']);
  });

  test('indentation only grows where the tree actually branches', () {
    final root = node(
      'a',
      children: [
        node(
          'b',
          children: [
            node('c', children: [node('d'), node('e')]),
          ],
        ),
      ],
    );

    expect(rowsOf(root), ['a@0', 'b@0', 'c@0', 'd@1', 'e@1']);
  });

  test('a collapsed node hides its children', () {
    final root = node(
      'a',
      children: [
        node('b', children: [node('c')]),
        node('d'),
      ],
    );

    expect(rowsOf(root, expanded: {'a'}), ['a@0', 'b@1', 'd@1']);
  });

  test('an empty tree has no rows', () {
    expect(rowsOf(null), isEmpty);
  });

  test('a search shows the path to its matches, whatever is expanded', () {
    final root = node(
      'a',
      children: [
        node('b', children: [node('match')]),
        node('other'),
      ],
    );

    // Nothing is expanded, yet the match and its ancestors are listed: the
    // search would otherwise hide what it just found.
    expect(
      rowsOf(
        root,
        expanded: const {},
        visible: {'a', 'b', 'match'},
        searchActive: true,
      ),
      ['a@0', 'b@0', 'match@0'],
    );
  });

  test('a search drops branches that hold no match', () {
    final root = node(
      'a',
      children: [
        node('b', children: [node('match')]),
        node('other', children: [node('ignored')]),
      ],
    );

    final rows = rowsOf(root, visible: {'a', 'b', 'match'}, searchActive: true);

    expect(rows, isNot(contains('other@1')));
    expect(rows, isNot(contains('ignored@1')));
    expect(rows, ['a@0', 'b@0', 'match@0']);
  });
}
