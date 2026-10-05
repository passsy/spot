/// The web implementation of writing generated matchers to disk.
///
/// `package:spot/src/spot/matcher_file.dart` picks between this library and
/// the dart:io one.
library;

import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Generates the matchers for [selector] and writes them to [path].
///
/// A browser has no file system to write them to.
void writeMatchersToFile<W extends Widget>(
  WidgetSelector<W> selector, {
  required String path,
  Map<String, String> propNameOverrides = const {},
  String? imports,
  bool Function(DiagnosticsNode node)? filter,
}) {
  throw UnsupportedError(
    'Matchers cannot be written to a file on the web. '
    'Run the generating test on the Dart VM instead.',
  );
}
