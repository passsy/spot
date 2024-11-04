import 'package:flutter_test/flutter_test.dart';

Matcher throwsSpotErrorContaining(
  List<Pattern> errorMessageParts, {
  List<Pattern> not = const [],
}) {
  return throwsErrorContaining<TestFailure>(errorMessageParts);
}

Matcher throwsErrorContaining<E>(
  List<Pattern> errorMessageParts, {
  List<Pattern> not = const [],
}) {
  final List<TypeMatcher<E>> failures = [];
  for (final part in errorMessageParts) {
    failures.add(
      isA<E>().having(
        // ignore: avoid_dynamic_calls
        (it) => (it as dynamic).toString(),
        'toString()',
        contains(part),
      ),
    );
  }

  for (final part in not) {
    failures.add(
      isA<E>().having(
        // ignore: avoid_dynamic_calls
        (it) => (it as dynamic).toString(),
        'toString()',
        isNot(contains(part)),
      ),
    );
  }

  return throwsA(allOf(failures));
}
