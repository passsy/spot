import 'package:spot/src/utils/invoker.dart';

/// Restores state that must not be carried from one test into the next.
///
/// A library has no hook that fires when a test starts: `addTearDown` only
/// works from inside a test, and `setUp` lives in the project's
/// `flutter_test_config.dart`. State scoped to a test therefore notices the
/// boundary when it is next touched, by comparing the running test against the
/// one it last reset for. Holding that comparison here keeps every cache from
/// keeping a [LiveTest] of its own.
class PerTestReset {
  /// Guards the state [reset] restores.
  PerTestReset(void Function() reset) : _reset = reset;

  /// Puts the state back to how a test should find it.
  final void Function() _reset;

  /// The test [_reset] last ran for.
  LiveTest? _test;

  /// Resets, unless this already reset for the running test.
  ///
  /// Call before every use of the state this guards, so no test ever sees what
  /// an earlier one left behind.
  void resetOnNewTest() {
    final test = getLiveTest();
    if (identical(test, _test)) {
      return;
    }
    _test = test;
    _reset();
  }
}
