import 'dart:async';

import 'package:spot/spot.dart';

/// Loading fonts is spot in use, so counting runs before any test in this
/// directory, and every test is counted from its first frame — including the
/// first test of the process.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  await testMain();
}
