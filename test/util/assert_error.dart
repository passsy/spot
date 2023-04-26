import 'package:flutter_test/flutter_test.dart';

Matcher throwsSpotErrorContaining(
  List<String> errorMessageParts, {
  List<String> not = const [],
}) {
  final List<TypeMatcher<TestFailure>> failures = [];
  for (final part in errorMessageParts) {
    failures.add(
      isA<TestFailure>().having((it) => it.message, 'message', contains(part)),
    );
  }

  for (final part in not) {
    failures.add(
      isA<TestFailure>()
          .having((it) => it.message, 'message', isNot(contains(part))),
    );
  }

  return throwsA(allOf(failures));
}
