/// The web implementation of the font loading API.
///
/// `package:spot/src/screenshot/load_fonts.dart` documents these functions and
/// picks between this library and the dart:io one.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/frame_clock.dart';

/// {@macro spot.loadAppFonts}
///
/// Fonts are read from disk, which a browser cannot do, so this loads nothing
/// and says so. Text still renders, in whatever font the browser picks.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Loading fonts is spot in use, usually from flutter_test_config.dart
  // before any test ran, which is what makes the first test's frames counted
  // from the very first one.
  FrameClock.startCounting();
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
