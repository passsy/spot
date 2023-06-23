import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import 'act_test.dart';

void main() {
  // Runs the tests as executed with `flutter run` (on a device)
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is LiveTestWidgetsFlutterBinding);
  group('LiveTestWidgetsFlutterBinding', actTests);
}
