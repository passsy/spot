import 'package:flutter/scheduler.dart';
import 'package:spot/src/utils/per_test_reset.dart';

/// Identity of the frames the process draws.
///
/// [SchedulerBinding] keeps no frame counter and persistent frame callbacks
/// cannot be removed again, so one callback counts for the whole process and
/// callers compare deltas off it.
abstract final class FrameClock {
  /// Frames drawn since counting started.
  ///
  /// The absolute value means nothing on its own, callers compare. Reading
  /// this starts the counting when [startCounting] has not already, so
  /// anything comparing the number across two points in time sees every
  /// frame in between: nobody can hold a number from before counting ran,
  /// because taking one is what starts it.
  static int get frameNumberInProcess {
    startCounting();
    return _frames;
  }

  /// Frames rendered since spot was introduced in the current test.
  ///
  /// spot counts from its first use, so frames a test rendered before that
  /// are not in the number. Introducing spot before the test makes this
  /// count from the test's first frame: `loadAppFonts()` in a project's
  /// `flutter_test_config.dart` and setting `globalTimelineMode` in `main()`
  /// both count as use. Once counting runs, every later test in the process
  /// is counted from its first frame either way, because each frame is
  /// attributed to the test it rendered in.
  ///
  /// Every rendered frame counts, not just the ones the test body pumped:
  /// `flutter_test` resets the tree with a frame of its own before each body
  /// runs, so a test counted from its start is already at 1 when the body
  /// begins.
  static int get frameNumberInTest {
    startCounting();
    return _frames - _framesAtTestStart;
  }

  /// Installs the persistent frame callback that counts. Idempotent.
  ///
  /// spot's entry points call this on first use, so nobody else ever needs
  /// to: using spot is what starts the counting.
  ///
  /// Before a binding exists there is no scheduler to count with, and the
  /// call is skipped — setting `globalTimelineMode` at the top of `main()`
  /// runs this early. The next spot use tries again.
  static void startCounting() {
    if (_counting) {
      return;
    }
    final binding = _bindingIfInitialized();
    if (binding == null) {
      return;
    }
    _counting = true;
    // Counting starts in whatever test is running now, so that test is not a
    // boundary when its first frame arrives.
    _testBaseline.resetOnNewTest();
    binding.addPersistentFrameCallback((_) {
      _testBaseline.resetOnNewTest();
      _frames++;
    });
  }
}

int _frames = 0;
bool _counting = false;

/// The scheduler, or `null` before a binding was initialized.
///
/// [SchedulerBinding.instance] throws before a binding exists, and that throw
/// is its whole answer to "is there one yet", so it is converted to a value
/// right here.
SchedulerBinding? _bindingIfInitialized() {
  try {
    return SchedulerBinding.instance;
    // ignore: avoid_catching_errors
  } on Error {
    return null;
  }
}

/// Starts a test's count at its first counted frame.
///
/// A test the counter has not seen starts counting here, even when it does not
/// touch spot until much later.
///
/// Deliberately latched until the next test's first frame. Resetting in a
/// teardown instead would let a frame pumped by a later teardown of the same
/// test read as a new test and re-baseline the count mid-test.
final _testBaseline = PerTestReset(() => _framesAtTestStart = _frames);

/// [_frames] when counting reached the test [_testBaseline] holds, which is
/// its first frame unless counting started in the middle of it.
int _framesAtTestStart = 0;
