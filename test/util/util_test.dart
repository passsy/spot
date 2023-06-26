import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/spot/snapshot.dart';

void main() {
  group('getAllSubsets', () {
    test('populated list', () {
      final original = [1, 2, 3, 4];
      final subsets = getAllSubsets(original);
      const expected = [
        [1, 2, 3],
        [1, 2, 4],
        [1, 3, 4],
        [2, 3, 4],
        [1, 2],
        [1, 3],
        [2, 3],
        [1, 4],
        [2, 4],
        [3, 4],
        [1],
        [2],
        [3],
        [4],
        [],
      ];
      expect(subsets, expected);
    });

    test('one entry', () {
      final original = [1];
      final subsets = getAllSubsets(original);
      const expected = [[]];
      expect(subsets, expected);
    });

    test('empty', () {
      final original = [];
      final subsets = getAllSubsets(original);
      const expected = [];
      expect(subsets, expected);
    });
  });
}
