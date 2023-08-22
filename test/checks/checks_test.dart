import 'package:spot/src/checks/checks_nullability.dart';
import 'package:checks/context.dart' show softCheck;
import 'package:spot/spot.dart';
import 'package:test/test.dart';

void main() {
  test('hide Subject nullability', () {
    bool called = false;
    void externalCall(Subject<String> subject) {
      expect(subject.runtimeType, isNot(contains('?')));

      // can be check for null despite being non-nullable
      subject.isNull();

      called = true;
    }

    // null value is rejected
    final failure = softCheck<String?>(null, (subject) {
      externalCall(subject.hideNullability());
    });

    // can call API that expects a non-nullable type
    expect(called, isTrue);

    // check failed
    expect(failure, isNotNull);
  });
}
