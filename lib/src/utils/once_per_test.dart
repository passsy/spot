import 'package:spot/src/utils/invoker.dart';

/// Runs something the first time it is reached in each test.
///
/// A library has no hook that fires when a test starts: `addTearDown` only
/// works from inside a test, and `setUp` lives in the project's
/// `flutter_test_config.dart`. State scoped to a test therefore notices the
/// boundary when it is next touched, by comparing the running test against the
/// one it last ran for. Holding that comparison here keeps every cache from
/// keeping a [LiveTest] of its own.
///
/// Nothing fires this on its own. [runOnNewTest] runs where it is called and
/// nowhere else.
class OncePerTest {
  /// Runs [run] once in every test that reaches [runOnNewTest].
  OncePerTest(void Function() run) : _run = run;

  /// What a test needs done before it touches the guarded state.
  final void Function() _run;

  /// The test [_run] last ran for.
  LiveTest? _test;

  /// Runs, unless this already ran in the running test.
  ///
  /// Call before every use of the state this guards, so no test ever sees what
  /// an earlier one left behind.
  void runOnNewTest() {
    final test = getLiveTest();
    if (identical(test, _test)) {
      return;
    }
    _test = test;
    _run();
  }
}
