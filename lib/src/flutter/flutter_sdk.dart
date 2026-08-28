/// Access to the Flutter SDK that is executing the tests.
///
/// The SDK lives on disk, which a browser cannot reach, so the web
/// implementation throws. Callers are expected to check [kIsWeb] first.
library;

export 'package:spot/src/flutter/flutter_sdk_web.dart'
    if (dart.library.io) 'package:spot/src/flutter/flutter_sdk_io.dart';
