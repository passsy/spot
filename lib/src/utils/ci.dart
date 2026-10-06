/// Detection of CI environments.
///
/// CI is detected from environment variables, which a browser cannot read, so
/// the web implementation always reports false.
library;

export 'package:spot/src/utils/ci_web.dart'
    if (dart.library.io) 'package:spot/src/utils/ci_io.dart';
