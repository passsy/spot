import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

/// Runs once per test file before its tests (Flutter's `flutter_test_config.dart`
/// hook).
///
/// Works around a Flutter master-channel regression where the `flutter test`
/// asset server intermittently fails to serve `shaders/ink_sparkle.frag` while
/// several test processes request assets at the same time (introduced by the
/// "unify asset processing" devfs rework, flutter/flutter#186902).
///
/// Widget tests run as [TargetPlatform.android], where Material uses the
/// InkSparkle ink splash. The first tap on a Material widget loads the shader
/// via a fire-and-forget `Future` without an error handler, so a failed load
/// surfaces as an unhandled exception that fails an otherwise unrelated test.
///
/// `flutter test` runs every test file in its own OS process, so an exclusive
/// lock on a shared file serializes the shader load across all of them. The
/// asset server serves the shader reliably when asked one request at a time,
/// and [ui.FragmentProgram.fromAsset] caches the result, so the later InkSparkle
/// load reuses the cached program instead of hitting the asset server again.
/// Only the (fast) shader load is serialized; the tests themselves still run
/// concurrently.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Note: deliberately does not initialize a binding here. Some test files use
  // LiveTestWidgetsFlutterBinding and assert on it, which would break if this
  // hook initialized the default (automated) binding first.
  await _warmUpInkSparkleShader();
  await testMain();
}

Future<void> _warmUpInkSparkleShader() async {
  const asset = 'shaders/ink_sparkle.frag';
  final lockFile = File('${Directory.systemTemp.path}/spot_ink_sparkle.lock');
  RandomAccessFile? handle;
  try {
    handle = await lockFile.open(mode: FileMode.write);
    await handle.lock(FileLock.blockingExclusive);
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await ui.FragmentProgram.fromAsset(asset);
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  } catch (_) {
    // Best effort. If the shader genuinely cannot be loaded the test that needs
    // it will surface the original error.
  } finally {
    try {
      await handle?.unlock();
    } catch (_) {}
    await handle?.close();
  }
}
