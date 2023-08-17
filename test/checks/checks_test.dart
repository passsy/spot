import 'package:spot/src/checks/checks_nullability.dart';
// import 'package:checks/checks.dart';
import 'package:checks/context.dart' show softCheck;
import 'package:checks/checks.dart' show it;
import 'package:spot/spot.dart';
import 'package:test/test.dart';

void main() {
  test('hide Subject nullability', () {
    bool called = false;
    void externalCall(Subject<String> subject) {
      expect(subject.runtimeType, isNot(contains('?')));
      called = true;
    }

    final ConditionSubject<String?> nullableSubject = it();
    final Subject<String> subject = nullableSubject.hideNullability();

    // can call API that expects a non-nullable type
    externalCall(subject);
    expect(called, isTrue);

    // can be check for null despite being non-nullable
    subject.isNull();

    // null value is rejected
    final failure = softCheck<String?>(null, nullableSubject);
    expect(failure, isNotNull);
  });
}
