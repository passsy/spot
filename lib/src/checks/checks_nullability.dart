import 'package:checks/context.dart';

export 'package:checks/context.dart';

extension HideNullableSubject<T> on Subject<T?> {
  /// Converts a Subject<T?> to Subject<T> by hiding the nullable type
  ///
  /// Checking for null is still possible by using [isNull] or [isNotNull]
  Subject<T> hideNullability() {
    return context.nest<T>(
      () => [], // no label, this is synthetic
      (actual) {
        if (actual == null) return Extracted.rejection();
        return Extracted.value(actual);
      },
      atSameLevel: true,
    );
  }

  Subject<T?> revealNullability() {
    return context.nest<T?>(
      () => [], // no label, this is synthetic
      (actual) {
        return Extracted.value(actual);
      },
      atSameLevel: true,
    );
  }
}

/// Like [softCheck] but ignores isNotNull() errors when the actual value is null
///
/// Workaround allowing to use
/// `hasProp((subject)=> subject.equals(X));`
/// instead of
/// `hasProp((subject)=> subject.isNotNull().equals(X));`
///
/// when Subject is Subject<T> but the value can actually be null (should be Subject<T?>).
CheckFailure? softCheckHideNull<T>(T value, Condition<T> condition) {
  final failure = softCheck(value, condition);
  if (failure == null) {
    return null;
  }
  final errorParts = describe(condition).map((it) => it.trim()).toList();
  if (errorParts.last == 'is null' &&
      failure.rejection.actual.firstOrNull == '<null>') {
    // property is null and isNull() was called
    // not error because null == null
    return null;
  }
  return failure;
}
