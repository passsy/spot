/// The dart2js and DDC implementation of [resolveFrames].
library;

import 'package:stack_trace/stack_trace.dart';

/// Rebuilds frames whose uri is a url served by the test server.
///
/// With a source map `package:stack_trace` resolves frames back to `package:`
/// uris by itself and there is nothing to do. Without one — which is how
/// `flutter test --platform chrome` compiles on Flutter 3.44 and below — every
/// frame keeps the url the browser loaded it from:
///
/// ```text
/// http://localhost:61970/packages/stack_trace/src/stack_zone_specification.dart.js
/// http://localhost:61970/timeline/tap/act_tap_timeline_test_bodies.dart.js
/// ```
///
/// Both carry no package, so a dependency is indistinguishable from the test
/// that called in and the nearest caller lands inside whichever package
/// happened to drive the callback. The urls say which is which, so they are
/// turned into the `package:` and `test/` uris every other compiler reports.
///
/// Line and column keep pointing into the JavaScript, because without a source
/// map there is nothing better to point at. The file is what callers match on.
List<Frame> resolveFrames(Iterable<Frame> frames) =>
    frames.map(_resolveFrame).toList();

Frame _resolveFrame(Frame frame) {
  final uri = _readableUri(frame.uri);
  if (uri == frame.uri) {
    return frame;
  }
  return Frame(uri, frame.line, frame.column, frame.member);
}

/// A dependency, `http://localhost:1234/packages/spot/src/x.dart.js`.
final RegExp _servedPackage = RegExp(r'^/packages/([a-zA-Z_0-9]+)/(.+)$');

Uri _readableUri(Uri uri) {
  if (!uri.isScheme('http') && !uri.isScheme('https')) {
    return uri;
  }
  // SDK frames are recognised by their path and need no rewrite. Naming the
  // library from the path would also get it wrong: the async implementation
  // lives under `_internal`, not under `async`.
  if (uri.path.contains('/dart-sdk/')) {
    return uri;
  }
  // The server also hands out JavaScript that was never a Dart library, the
  // DDC runtime among it. Those frames are not somebody's source file.
  if (!uri.path.endsWith('.dart.js') && !uri.path.endsWith('.dart')) {
    return uri;
  }

  final package = _servedPackage.firstMatch(uri.path);
  if (package != null) {
    return Uri.parse(
      'package:${package.group(1)}/${_withoutJsSuffix(package.group(2)!)}',
    );
  }

  // `flutter test` serves the test directory as the server root, so what is
  // left is a file of the suite being run.
  return Uri.parse('test${_withoutJsSuffix(uri.path)}');
}

/// `…/x.dart.js` is the compiled form of `…/x.dart`.
String _withoutJsSuffix(String path) =>
    path.endsWith('.dart.js') ? path.substring(0, path.length - 3) : path;
