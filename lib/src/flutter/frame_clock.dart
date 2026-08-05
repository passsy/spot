import 'package:flutter/scheduler.dart';
import 'package:spot/src/utils/invoker.dart';

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
  /// are not in the number. Introducing spot before the test — see
  /// [startCounting] — makes this count from the test's first frame. Once
  /// counting runs, every later test in the process is counted from its
  /// first frame either way, because each frame is attributed to the test it
  /// rendered in.
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
  /// Everything here starts itself on first use, so the one reason to call
  /// this is a project's `flutter_test_config.dart`, where it runs before any
  /// test has rendered a frame and [frameNumberInTest] counts every test from
  /// its first frame:
  ///
  /// ```dart
  /// Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  ///   TestWidgetsFlutterBinding.ensureInitialized();
  ///   FrameClock.startCounting();
  ///   await testMain();
  /// }
  /// ```
  static void startCounting() {
    if (_counting) {
      return;
    }
    _counting = true;
    _testOfFrame = getLiveTest();
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      final test = getLiveTest();
      if (!identical(test, _testOfFrame)) {
        // The first counted frame of a test the counter has not seen, so the
        // count for it starts here, even when that test does not touch spot
        // until much later.
        _testOfFrame = test;
        _framesAtTestStart = _frames;
      }
      _frames++;
    });
  }
}

int _frames = 0;
bool _counting = false;

/// The test the frames since [_framesAtTestStart] belong to.
///
/// Deliberately held until the next test's first frame replaces it. Clearing
/// it in a teardown instead would let a frame pumped by a later teardown of
/// the same test read as a new test and re-baseline the count mid-test.
LiveTest? _testOfFrame;

/// [_frames] when counting reached [_testOfFrame], which is its first frame
/// unless counting started in the middle of it.
int _framesAtTestStart = 0;
