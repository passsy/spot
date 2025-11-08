import 'package:flutter_test/flutter_test.dart';

/// Returns the already initialized [TestWidgetsFlutterBinding]
TestWidgetsFlutterBinding get testBinding {
  return TestWidgetsFlutterBinding.ensureInitialized();
}
