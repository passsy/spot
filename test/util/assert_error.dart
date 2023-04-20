import 'package:flutter_test/flutter_test.dart';

Matcher throwsSpotErrorContaining(List<String> errorMessageParts) {
  TypeMatcher<TestFailure> testFailureWithErrorsContaining = isA<TestFailure>();
  for (final part in errorMessageParts) {
    testFailureWithErrorsContaining = testFailureWithErrorsContaining.having(
      (it) => it.message,
      'message',
      contains(part),
    );
  }

  return throwsA(testFailureWithErrorsContaining);
}
