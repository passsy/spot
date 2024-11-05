import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Loads the app fonts so they are readable in tests.
/// This is especially helpful when using takeScreenshot();
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Load the font manifest
  final fontManifest =
      await rootBundle.loadStructuredData<List<Map<String, dynamic>>>(
    'FontManifest.json',
    (string) async {
      // Parse and cast the JSON to List<Map<String, dynamic>>
      return (json.decode(string) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    },
  );
  await loadFontsFromFontsManifest(fontManifest);
}

/// Loads the fonts from the FontManifest content.
@visibleForTesting
Future<void> loadFontsFromFontsManifest(
  List<Map<String, dynamic>> fontManifest,
) async {
  // When no special fonts are defined or there is no roboto in the manifest we load it from the manifest to render standard Text widgets
  if (fontManifest.isEmpty ||
      fontManifest.every((element) => element['family'] != 'Roboto')) {
    final fontLoader = FontLoader('Roboto');
    final fontPath = Platform.executable;
    final desiredPath = fontPath.split('/engine/')[0];
    fontLoader.addFont(
      rootBundle.load('$desiredPath/material_fonts/Roboto-Regular.ttf'),
    );
    await fontLoader.load();
  }

  // Load the fonts from the manifest. These can be the ones defined in the app or in dependencies.
  for (final Map<String, dynamic> font in fontManifest) {
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

  if (_overridableFonts.contains(fontFamily)) {
    return fontFamily;
  }

  if (fontFamily.startsWith('packages/')) {
    final fontFamilyName = fontFamily.split('/').last;
    if (_overridableFonts.any((font) => font == fontFamilyName)) {
      return fontFamilyName;
    }
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

const List<String> _overridableFonts = [
  'Roboto',
  '.SF UI Display',
  '.SF UI Text',
  '.SF Pro Text',
  '.SF Pro Display',
];
