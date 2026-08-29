import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/wasm_skips.dart';

import 'act_test.dart';

void main() {
  // Runs the tests as executed with `flutter run` (on a device)
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  assert(WidgetsBinding.instance is LiveTestWidgetsFlutterBinding);
  // Under dart2wasm a tap that throws leaks the error past the test that
  // raised it, and the runner reports it against whichever test completed
  // before. The same bodies run against AutomatedTestWidgetsFlutterBinding in
  // act_test.dart, which does not have that problem.
  group(
    'LiveTestWidgetsFlutterBinding',
    actTests,
    skip: kIsWasm ? liveBindingLeaksOnWasm : false,
  );
}
