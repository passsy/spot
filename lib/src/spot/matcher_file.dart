/// Writing generated matchers to a file.
///
/// The file is written with dart:io, which a browser cannot do, so the web
/// implementation throws.
library;

export 'package:spot/src/spot/matcher_file_web.dart'
    if (dart.library.io) 'package:spot/src/spot/matcher_file_io.dart';
