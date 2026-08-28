/// File system access needed to load fonts from disk.
///
/// A browser has no file system, so the web implementation reports "nothing
/// found" rather than throwing. Fonts come from the asset bundle there.
library;

export 'package:spot/src/screenshot/font_files_web.dart'
    if (dart.library.io) 'package:spot/src/screenshot/font_files_io.dart';
