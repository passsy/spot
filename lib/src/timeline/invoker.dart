//ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';
//ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

export 'package:test_api/src/backend/live_test.dart' show LiveTest;

/// Expose the private [Invoker] api to get the current [LiveTest].
LiveTest? getLiveTest() {
  final invoker = Invoker.current;
  return invoker?.liveTest;
}
