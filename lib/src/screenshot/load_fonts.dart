import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads all font from the apps FontManifest and embedded in the Flutter SDK
///
/// ## App Fonts (FontManifest)
/// - All fonts defined in the pubspec.yaml
/// - All fonts of dependencies that define fonts in their pubspec.yaml
///
/// ## Embedded Flutter SDK Fonts
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
/// Sometimes you don't want to ship a font with your app, but use a system
/// font e.g. "Segoe UI" on [TargetPlatform.windows] or "Apple Color Emoji"
/// on [TargetPlatform.iOS].
/// Those fonts are not loaded by [loadAppFonts], load them individually with
/// [loadFont].
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // First we load the Roboto font from the Flutter SDK, which most Android apps use.
  // In case the app defines a custom Roboto fontFamily it will be overwritten when
  // loading the fonts from the manifest
  await _loadMaterialFontsFromSdk();

  // Load all fonts defined in the FontManifest.json file
  await _loadFontsFromFontManifest();
}

/// Loads a fontFamily consisting of multiple font files.
///
/// ```dart
/// debugDefaultTargetPlatformOverride = TargetPlatform.windows;
/// await loadFont('Segoe UI', [
///   r'C:\Windows\Fonts\segoeui.ttf', // Regular
///   r'C:\Windows\Fonts\segoeuib.ttf', // Bold
///   r'C:\Windows\Fonts\segoeuii.ttf', // Italic
/// ]);
///
/// tester.pumpWidget(
///   MaterialApp(
///     home: Center(
///       child: Text(
///         'Loaded custom Font',
///         style: TextStyle(
///           fontFamily: 'Segoe UI', // optional, Segoe UI is the default font on Windows
///         ),
///       ),
///     ),
///   ),
/// );
/// ```
///
/// Flutter support the following formats: .ttf, .otf, .ttc
///
/// Calling [loadFont] multiple times with the same family will overwrite the previous
///
/// The [family] is optional: '' will extract the family name from the font file.
Future<void> loadFont(String family, List<String> fontPaths) async {
  if (fontPaths.isEmpty) {
    return;
  }
  final fontLoader = FontLoader(family);
  for (final path in fontPaths) {
    final Uint8List bytes = File(path).readAsBytesSync();
    fontLoader.addFont(Future.sync(() => bytes.buffer.asByteData()));
  }
  // the fontLoader is unusable after calling load().
  // No need to cache or return it.
  await fontLoader.load();
}

/// Loads the Roboto/RobotoCondensed/MaterialIcons fonts from the executing Flutter SDK
Future<void> _loadMaterialFontsFromSdk() async {
  final flutterSdkRoot = _flutterSdkRoot().absolute.path;

  final materialFontsDir =
      Directory('$flutterSdkRoot/bin/cache/artifacts/material_fonts/');

  final fontFormats = ['.ttf', '.otf', '.ttc'];
  final existingFonts = materialFontsDir
      .listSync()
      // dartfmt come on,...
      .whereType<File>()
      .where(
        (font) => fontFormats.any((element) => font.path.endsWith(element)),
      );

  final robotoFonts = existingFonts
      .map((font) => font.path)
      .where((path) => path.contains('Roboto-'))
      .toList();
  await loadFont('Roboto', robotoFonts);

  final robotoCondensedFonts = existingFonts
      .map((font) => font.path)
      .where((path) => path.contains('RobotoCondensed-'))
      .toList();
  await loadFont('RobotoCondensed', robotoCondensedFonts);

  final materialIcons = existingFonts
      .map((font) => font.path)
      .where((path) => path.contains('MaterialIcons-'))
      .toList();
  await loadFont('MaterialIcons', materialIcons);
}

/// Returns the Flutter SDK root directory based on the current flutter
/// executable running the tests.
Directory _flutterSdkRoot() {
  final fontPath = Platform.executable;
  final root2 = fontPath.split('/bin/cache/')[0];
  return Directory(root2);
}

/// Loads the fonts from the FontManifest.json file.
///
/// Fonts defined in an app are accessible via it family name "MyFont"
/// Fonts defined in a package are accessible via "packages/myPackage/MyFont"
///
/// Because each app can also be a package, each font is available with both
/// notations.
/// This allows packages to access their own fonts also via
/// "packages/myPackage/MyFont" like users of the package would.
Future<void> _loadFontsFromFontManifest() async {
  // The FontManifest.json file is generated by the Flutter build process
  // located in /build/flutter_assets/FontManifest.json and bundled within the app
  final fontManifestContent = await rootBundle.loadString('FontManifest.json');
  final json = jsonDecode(fontManifestContent);
  final fontManifest = _FontManifest.fromJson(json);

  for (final item in fontManifest.fontFamilies) {
    final String fontFamilyName;
    final asset =
        item.assets.firstOrNullWhere((it) => it.startsWith('packages'));
    final packageName = asset?.split('/')[1];

    final rawFamily = item.family;
    if (rawFamily.startsWith('packages/')) {
      fontFamilyName = rawFamily.split('/').last;
    } else {
      fontFamilyName = rawFamily;
    }

    // Apps directly use the fontFamily name
    await loadFont(fontFamilyName, item.assets);
    if (packageName != null) {
      // packages use the full path
      await loadFont('packages/$packageName/$fontFamilyName', item.assets);
    }
  }
}

/// Parsed representation of the FontManifest.json file
class _FontManifest {
  final List<_FontManifestFontFamily> fontFamilies;

  /// Represents a Flutter FontManifest
  _FontManifest(this.fontFamilies);

  /// Parses the FontManifest.json file
  ///
  /// Example:
  /// ```json
  ///  [
  ///    {
  ///      "family": "packages/app_font/Montserrat",
  ///      "fonts": [
  ///        {
  ///          "asset": "packages/app_font/fonts/Montserrat-Regular.ttf"
  ///        }
  ///      ]
  ///    }
  ///  ]
  /// ```
  factory _FontManifest.fromJson(dynamic json) {
    if (json is! List) {
      throw const FormatException('FontManifest must begin with a List');
    }
    final List<_FontManifestFontFamily> fontFamilies = [];
    for (final family in json) {
      if (family is! Map) continue;
      final familyName = family['family'];
      if (familyName is! String) continue;
      final List<String> assets = [];
      final fonts = family['fonts'];
      if (fonts is! List) continue;
      for (final font in fonts) {
        if (font is! Map) continue;
        final asset = font['asset'];
        if (asset is! String) continue;
        // there are other values like weight and style, but those are ignored by Flutter
        // https://github.com/flutter/website/issues/3591#issuecomment-521806077
        assets.add(asset);
      }
      fontFamilies.add(_FontManifestFontFamily(familyName, assets));
    }
    return _FontManifest(fontFamilies);
  }
}

class _FontManifestFontFamily {
  final String family;
  final List<String> assets;

  _FontManifestFontFamily(this.family, this.assets);
}
