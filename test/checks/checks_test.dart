import 'package:spot/src/checks/checks_nullability.dart';

import 'package:checks/context.dart' show softCheck;
import 'package:spot/spot.dart';
import 'package:test/test.dart';

void main() {
  test('hide Subject nullability but allows isNull() check', () {
    bool called = false;
    void condition(Subject<String> subject) {
      expect(subject.runtimeType, isNot(contains('?')));

      // can be check for null despite being non-nullable
      subject.isNull();
      called = true;
    }

    final failure =
        softCheckHideNull<String?>(null, condition.hideNullability());
    expect(failure, isNull);
    expect(called, isTrue);
  });

  test('hide Subject nullability and rejects', () {
    bool called = false;

    void condition(Subject<String> subject) {
      called = true;
      // can be check for null despite being non-nullable
      subject.isNull();
    }

    // null value is rejected
    final failure =
        softCheckHideNull<String?>('a', condition.hideNullability());
    expect(failure, isNotNull);
    expect(called, isTrue);
  });
}
