import 'package:ci/ci.dart' as ci;

/// Returns true if the code is running in a CI environment.
bool get isCI => ci.isCI;
