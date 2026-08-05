import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/flutter/frame_clock.dart';

/// Starts counting before any test in this directory runs, which is the setup
/// that makes [FrameClock.frameNumberInTest] count every test from its first
/// frame, including the first test of the process.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FrameClock.startCounting();
  await testMain();
}
