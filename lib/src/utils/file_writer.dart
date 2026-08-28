/// Writing generated files to disk.
///
/// A browser has no file system, so the web implementation throws.
library;

export 'package:spot/src/utils/file_writer_web.dart'
    if (dart.library.io) 'package:spot/src/utils/file_writer_io.dart';
