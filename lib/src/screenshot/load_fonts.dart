import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/flutter_sdk.dart';
import 'package:spot/src/flutter/frame_clock.dart';
import 'package:spot/src/screenshot/font_files.dart';

Future<void>? _loadAppFontsFuture;

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
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Loading fonts is spot in use, usually from flutter_test_config.dart
  // before any test ran, which is what makes the first test's frames counted
  // from the very first one.
  FrameClock.startCounting();
  final existingFuture = _loadAppFontsFuture;
  if (existingFuture != null) {
    return existingFuture;
  }

  if (kIsWeb) {
    // ignore: avoid_print
    print('⚠️ - loadAppFonts is not supported on the web!');
    final future = Future<void>.value();
    _loadAppFontsFuture = future;
    return future;
  }

  final future = _loadAppFontsOnce();
  _loadAppFontsFuture = future;

  try {
    await future;
  } catch (e, stackTrace) {
    _loadAppFontsFuture = null;
    Error.throwWithStackTrace(e, stackTrace);
  }
}

Future<void> _loadAppFontsOnce() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await TestAsyncUtils.guard<void>(() async {
    // First we load the Roboto font from the Flutter SDK, which most Android apps use.
    // In case the app defines a custom Roboto fontFamily it will be overwritten when
    // loading the fonts from the manifest
    await _loadMaterialFontsFromSdk();

    // Load all fonts defined in the FontManifest.json file
    await _loadFontsFromFontManifest();
  });
}

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
Future<void> loadFont(String family, List<String> fontPaths) async {
  if (kIsWeb) {
    // ignore: avoid_print
    print('⚠️ - loadFont is not supported on the web!');
    return;
  }

  if (fontPaths.isEmpty) {
    return;
  }

  await TestAsyncUtils.guard<void>(() async {
    final fontLoader = FontLoader(family);
    for (final path in fontPaths) {
      final decodedPath = Uri.decodeComponent(path);
      try {
        final Uint8List? bytes = readFileBytesSync(decodedPath);
        if (bytes != null) {
          fontLoader.addFont(Future.value(bytes.buffer.asByteData()));
        } else {
          final data = rootBundle.load(decodedPath);
          fontLoader.addFont(Future.value(data));
        }
      } catch (e, stack) {
        debugPrint("Could not load font $decodedPath\n$e\n$stack");
      }
    }
    // the fontLoader is unusable after calling load().
    // No need to cache or return it.
    await fontLoader.load();
  });
}

/// Loads the Roboto/RobotoCondensed/MaterialIcons fonts from the executing Flutter SDK
Future<void> _loadMaterialFontsFromSdk() async {
  final root = flutterSdkRootPath();

  final fontFormats = ['.ttf', '.otf', '.ttc'];
  final existingFonts = listFilesWithExtension(
    '$root/bin/cache/artifacts/material_fonts/',
    fontFormats,
  );

  final robotoFonts = existingFonts
      .where((path) => path._fileName.startsWith('Roboto-'.toLowerCase()))
      .toList();
  if (robotoFonts.isEmpty) {
    debugPrint("Warning: No Roboto font found in SDK");
  }
  await loadFont('Roboto', robotoFonts);

  final robotoCondensedFonts = existingFonts
      .where(
        (path) => path._fileName.startsWith('RobotoCondensed-'.toLowerCase()),
      )
      .toList();
  await loadFont('RobotoCondensed', robotoCondensedFonts);

  final materialIcons = existingFonts
      .where(
        (path) => path._fileName.startsWith('MaterialIcons-'.toLowerCase()),
      )
      .toList();
  await loadFont('MaterialIcons', materialIcons);
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
  final binding = TestWidgetsFlutterBinding.instance;
  final fontManifestContent =
      await binding.runAsync(() => rootBundle.loadString('FontManifest.json'));
  final json = jsonDecode(fontManifestContent!);
  final fontManifest = _FontManifest.fromJson(json);

  // The name of the package running the tests. Used to also expose the test
  // target's own fonts under "packages/<self>/MyFont", matching how Flutter
  // resolves a `package:` set on a TextStyle/IconData.
  final thisPackageName = readPackageNameFromPubspec();

  for (final item in fontManifest.fontFamilies) {
    final packageAsset =
        item.assets.firstOrNullWhere((it) => it.startsWith('packages/'));
    final packageName = packageAsset?.split('/')[1];

    if (packageName == null) {
      // font asset in pubspec.yaml references a file relative to the pubspec.yaml
      // e.g. asset: lib/fonts/MyFont.ttf

      // Make it accessible as "MyFont" for the app/package itself
      await loadFont(item.family, item.assets);

      // A package may reference its own fonts with `package: '<self>'`, which
      // Flutter resolves to "packages/<self>/MyFont" at lookup time. Register
      // that name too so the font is reachable both ways, mirroring the
      // packages/ asset case below.
      if (thisPackageName != null) {
        await loadFont(
          'packages/$thisPackageName/${item.family}',
          item.assets,
        );
      }
    } else {
      // font uses the package notation, which resolves relative to the packages lib/* directory
      // asset: packages/<packageName>/<somewhereInsideLib>/MyFont.ttf

      // Make it accessible as "MyFont" to be used by the package itself
      final fontFamilyName = item.family.split('/').last;
      await loadFont(fontFamilyName, item.assets);
      // and "packages/<packageName>/MyFont" so that other packages would reference it.
      await loadFont('packages/$packageName/$fontFamilyName', item.assets);
    }
  }
}

/// The lower-cased last path segment of a file path.
extension on String {
  String get _fileName => split(RegExp(r'[/\\]')).last.toLowerCase();
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
