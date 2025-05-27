import 'package:ci/ci.dart' as ci;
import 'package:flutter/foundation.dart';

/// Returns true if the code is running in a CI environment.
///
/// Always return false on web, as CI detection is not applicable.
bool get isCI {
  if (kIsWeb) return false;
  return ci.isCI;
}
