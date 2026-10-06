/// The dart:io implementation of writing generated matchers to disk.
///
/// `package:spot/src/spot/matcher_file.dart` picks between this library and
/// the web one.
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/matcher_generator.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// Generates the matchers for [selector] and writes them to [path].
///
/// Deletes the file at [path] when there is nothing worth matching on.
void writeMatchersToFile<W extends Widget>(
  WidgetSelector<W> selector, {
  required String path,
  Map<String, String> propNameOverrides = const {},
  String? imports,
  bool Function(DiagnosticsNode node)? filter,
}) {
  final content = selector.createMatcherString(
    propNameOverrides: propNameOverrides,
    imports: imports,
    filter: filter,
  );
  final file = File(path);
  if (content == null) {
    if (file.existsSync()) {
      file.deleteSync();
    }
    return;
  }
  file
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
}
