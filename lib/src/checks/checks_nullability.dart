import 'package:spot/spot.dart';

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
}
