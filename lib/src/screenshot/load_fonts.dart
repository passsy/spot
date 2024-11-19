import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads all font from the FontManifest (Asset fonts defined in pubspec.yaml and
/// other Flutter package dependencies) and the following fonts from Flutter SDK:
/// - Roboto
/// - RobotoCondensed
/// - MaterialIcons
///
/// By default, widget tests run with [TargetPlatform.android] which
/// uses the Roboto font by default (see [Typography]). Loading this font,
/// although not defined as asset, allows most Flutter apps to render text.
///
/// If your app depends on other system fonts (like "Segoe UI" on [TargetPlatform.windows]
/// or "Apple Color Emoji" on [TargetPlatform.iOS]) use [loadFont].
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // First we load the Roboto font from the Flutter SDK as a fallback
  // In case the app defines a custom Roboto font it will be overwritten
  await _loadMaterialFontsFromSdk();

  await _loadFontsFromFontManifest();
}

/// Flutter officially support the following formats: .ttf, .otf, .ttc
Future<void> loadFont(String family, List<String> fontPaths) async {
  final fontLoader = FontLoader(family);
  for (final path in fontPaths) {
    final Uint8List bytes = File(path).readAsBytesSync();

    /// TODO catch error when path loads to an unsupported font format (docx);
    /// TODO print warning
    fontLoader.addFont(Future(() => bytes.buffer.asByteData()));
  }
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

  final robotoFonts =
      existingFonts.where((font) => font.path.contains('Roboto-'));
  await loadFont('Roboto', [
    for (final font in robotoFonts) font.path,
  ]);

  final robotoCondensedFonts =
      existingFonts.where((font) => font.path.contains('RobotoCondensed-'));
  await loadFont('RobotoCondensed', [
    for (final font in robotoCondensedFonts) font.path,
  ]);

  final materialIcons =
      existingFonts.where((font) => font.path.contains('MaterialIcons-'));
  await loadFont('MaterialIcons', [
    for (final font in materialIcons) font.path,
  ]);
}

/// Returns the Flutter SDK root directory based on the current executable running the tests.
Directory _flutterSdkRoot() {
  final fontPath = Platform.executable;
  final root2 = fontPath.split('/bin/cache/')[0];
  return Directory(root2);
}

/// Loads the fonts from the FontManifest content.
Future<void> _loadFontsFromFontManifest() async {
  // Every Flutter app has a FontManifest.json file that contains the fonts used in the app.
  final fontManifest = await rootBundle.loadString('FontManifest.json');
  // Parse and cast the JSON to List<Map<String, dynamic>>
  final list = json.decode(fontManifest) as List;
  final data = list.map((e) => e as Map<String, dynamic>).toList();

  // TODO load fonts as "MyFont" and "packages/myPackage/MyFont"
  // Load the fonts from the manifest. These can be the ones defined in the app or in dependencies.
  for (final Map<String, dynamic> font in data) {
    final fontLoader = FontLoader(derivedFontFamily(font));
    // Cast 'fonts' field to List<Map<String, dynamic>> to use in the for loop
    final List<Map<String, dynamic>> fontsList =
        (font['fonts'] as List).map((e) => e as Map<String, dynamic>).toList();

    for (final Map<String, dynamic> fontType in fontsList) {
      final String assetPath = fontType['asset'] as String;
      fontLoader.addFont(rootBundle.load(assetPath));
    }

    await fontLoader.load();
  }
}

/// Derives the font family from the font definition.
@visibleForTesting
String derivedFontFamily(Map<String, dynamic> fontDefinition) {
  if (!fontDefinition.containsKey('family')) {
    return '';
  }

  final String fontFamily = fontDefinition['family'] as String;

  if (fontFamily.startsWith('packages/')) {
    final fontFamilyName = fontFamily.split('/').last;
    return fontFamilyName;
  } else {
    for (final fontType in fontDefinition['fonts'] as List<dynamic>) {
      final String? asset =
          (fontType as Map<String, dynamic>)['asset'] as String?;
      if (asset != null && asset.startsWith('packages')) {
        final packageName = asset.split('/')[1];
        return 'packages/$packageName/$fontFamily';
      }
    }
  }
  return fontFamily;
}
