import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'act_drag_test.dart';

void main() {
  // Runs the tests as executed with `flutter run` (on a device)
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is LiveTestWidgetsFlutterBinding);
  group('Drag with LiveTestWidgetsFlutterBinding', dragTests);
}
