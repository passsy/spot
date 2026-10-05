/// The web implementation of the font loading API.
///
/// `package:spot/src/screenshot/load_fonts.dart` documents these functions and
/// picks between this library and the dart:io one.
library;

/// {@macro spot.loadAppFonts}
///
/// Fonts are read from disk, which a browser cannot do, so this loads nothing
/// and says so. Text still renders, in whatever font the browser picks.
Future<void> loadAppFonts() async {
  // ignore: avoid_print
  print('⚠️ - loadAppFonts is not supported on the web!');
}

/// {@macro spot.loadFont}
///
/// The files are read from disk, which a browser cannot do.
Future<void> loadFont(String family, List<String> fontPaths) async {
  // ignore: avoid_print
  print('⚠️ - loadFont is not supported on the web!');
}
