import 'package:flutter_test/flutter_test.dart';

Matcher throwsSpotErrorContaining(
  List<String> errorMessageParts, {
  List<String> not = const [],
}) {
  return throwsErrorContaining<TestFailure>(errorMessageParts);
}

Matcher throwsErrorContaining<E>(
  List<String> errorMessageParts, {
  List<String> not = const [],
}) {
  final List<TypeMatcher<E>> failures = [];
  for (final part in errorMessageParts) {
    failures.add(
      isA<E>().having(
        // ignore: avoid_dynamic_calls
        (it) => (it as dynamic).message,
        'message',
        contains(part),
      ),
    );
  }

  for (final part in not) {
    failures.add(
      isA<E>().having(
        // ignore: avoid_dynamic_calls
        (it) => (it as dynamic).message,
        'message',
        isNot(contains(part)),
      ),
    );
  }

  return throwsA(allOf(failures));
}
