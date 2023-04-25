import 'package:flutter_test/flutter_test.dart';

Matcher throwsSpotErrorContaining(
  List<String> errorMessageParts, {
  List<String> not = const [],
}) {
  TypeMatcher<TestFailure> testFailureWithErrorsContaining = isA<TestFailure>();
  for (final part in errorMessageParts) {
    testFailureWithErrorsContaining = testFailureWithErrorsContaining.having(
      (it) => it.message,
      'message',
      contains(part),
    );
  }

  for (final part in not) {
    testFailureWithErrorsContaining = testFailureWithErrorsContaining.having(
      (it) => it.message,
      'message',
      isNot(contains(part)),
    );
  }

  return throwsA(testFailureWithErrorsContaining);
}
