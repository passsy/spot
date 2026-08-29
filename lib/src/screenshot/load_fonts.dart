/// @docImport 'package:flutter/material.dart';
/// Loading fonts for widget tests.
///
/// Fonts are read from disk and from the Flutter SDK, neither of which a
/// browser can reach, so the web implementation loads nothing and says so.
library;

import 'package:spot/src/screenshot/load_fonts_web.dart'
    if (dart.library.io) 'package:spot/src/screenshot/load_fonts_io.dart'
    as impl;

/// {@template spot.loadAppFonts}
/// Loads all font from the apps FontManifest and embedded in the Flutter SDK
///
/// ## What is loaded?
/// ### App Fonts (FontManifest)
/// - All fonts defined in the pubspec.yaml
/// - All fonts of dependencies that define fonts in their pubspec.yaml
///
/// ### Embedded Flutter SDK Fonts
/// - Roboto
/// - RobotoCondensed
/// - MaterialIcons
///
/// ## Why load Roboto by default?
///
/// Widget test run with [TargetPlatform.android] by default. [MaterialApp] sets
/// the Roboto fontFamily as default for [TargetPlatform.android] (see
/// [Typography]). Loading the Roboto fontFamily therefore allows showing text
/// in the default scenario of a Flutter app.
/// Fortunately, Robot is part of the Flutter SDK and can be loaded right away.
///
/// ## Custom fonts
///
/// Apps that use custom fonts, should declare them in the pubspec.yaml file (https://docs.flutter.dev/cookbook/design/fonts#declare-the-font-in-the-pubspec-yaml-file).
/// Those fonts are automatically added to the FontManifest.json file during build.
///
/// The [loadAppFonts] function loads all font defined in the FontManifest.json file.
///
/// ## Depending on System fonts
///
/// Some apps do not ship their fonts, but use a system font e.g. "Segoe UI"
/// on [TargetPlatform.windows] or "Apple Color Emoji" on [TargetPlatform.iOS].
///
/// Those system fonts are not loaded by [loadAppFonts], load them individually
/// with [loadFont].
///
/// ## Emojis
///
/// Why are emojis not rendered after calling [loadAppFonts]?
///
/// Emojis are not part of the Roboto font.
/// Each operating system provides their own font that handles
/// emoji glyphs. In Flutter apps, those emoji fonts are automatically loaded
/// by Skia (the rendering engine of Flutter) from the operating system as fallbacks
/// when it encounters an emoji character that is covered by the defined
/// fontFamily or fontFamilyFallback.
///
/// Flutter tests disable the automatic system font loading by Skia. Skia will
/// not search for system fonts. (https://github.com/flutter/engine/blob/a842207f6d90de4fc006ea8f0b649b38d6e104a0/lib/ui/text/font_collection.cc#L148)
///
/// To show emojis in tests, load the system emoji font manually with [loadFont].
/// E.g. "/System/Library/Fonts/Apple Color Emoji.ttc" on macOS.
/// Do not forget to set "Apple Color Emoji" as fontFamilyFallback. Skia will
/// *not* automatically fallback to "Apple Color Emoji" unless it is defined in
/// the TextStyle.
///
/// Because showing emojis in test requires changes to you app code (set fallback)
/// [loadAppFonts] does not automatically load system emoji fonts for you.
/// {@endtemplate}
Future<void> loadAppFonts() => impl.loadAppFonts();

/// {@template spot.loadFont}
/// Loads a fontFamily consisting of multiple font files.
///
/// ```dart
/// debugDefaultTargetPlatformOverride = TargetPlatform.windows;
/// await loadFont('Comic Sans', [
///   r'C:\Windows\Fonts\comic.ttf', // Regular
///   r'C:\Windows\Fonts\comicbd.ttf', // Bold
///   r'C:\Windows\Fonts\comici.ttf', // Italic
/// ]);
///
/// tester.pumpWidget(
///   MaterialApp(
///     home: Center(
///       child: Text(
///         'Loaded custom Font',
///         style: TextStyle(
///           fontFamily: 'Comic Sans',
///         ),
///       ),
///     ),
///   ),
/// );
/// ```
///
/// Flutter support the following formats: .ttf, .otf, .ttc
///
/// Calling [loadFont] multiple times with the same family will overwrites the
/// previous
///
/// The [family] is optional: '' will extract the family name from the font file.
/// {@endtemplate}
Future<void> loadFont(String family, List<String> fontPaths) =>
    impl.loadFont(family, fontPaths);
