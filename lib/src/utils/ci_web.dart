/// Returns true if the code is running in a CI environment.
///
/// Always false in a browser, where the environment variables that identify a
/// CI system are not readable.
bool get isCI => false;
