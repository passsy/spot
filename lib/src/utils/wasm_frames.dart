import 'package:stack_trace/stack_trace.dart';

/// dart2wasm compiles the whole program into a single module, so every frame
/// of a stack trace points at `main.dart.wasm` and the real location is
/// appended to the member instead:
///
/// ```text
/// M.main closure at org-dartlang-app:///screenshot/screenshot_test.dart:207:63 inner
/// ```
///
/// Rebuilds those frames so that uri, line and column say where the code is,
/// in the shape the JavaScript compilers report, which is what the callers
/// match on.
///
/// Frames the compiler emitted without a location cannot be attributed to a
/// file and are dropped. Traces from other compilers are returned untouched.
List<Frame> resolveWasmFrames(Iterable<Frame> frames) {
  final list = frames.toList();
  if (!list.any(_isWasmFrame)) {
    return list;
  }
  final resolved = <Frame>[];
  for (final frame in list) {
    if (!_isWasmFrame(frame)) {
      resolved.add(frame);
      continue;
    }
    final match = _memberLocation.firstMatch(frame.member ?? '');
    if (match == null) {
      continue;
    }
    resolved.add(
      Frame(
        _readableUri(match.group(2)!),
        int.tryParse(match.group(3)!),
        int.tryParse(match.group(4)!),
        _readableMember(match.group(1)!),
      ),
    );
  }
  return resolved;
}

bool _isWasmFrame(Frame frame) => frame.uri.path.endsWith('.wasm');

/// `<member> at <uri>:<line>:<column>` with an optional `inner` or
/// `trampoline` suffix the compiler adds.
final RegExp _memberLocation = RegExp(r'^(.*?) at (\S+):(\d+):(\d+)(?: \S+)?$');

/// A package in the pub cache, `…/hosted/pub.dev/spot-1.2.3/lib/src/x.dart`.
final RegExp _hostedPackage =
    RegExp(r'/hosted/[^/]+/([a-zA-Z_0-9]+)-[^/]+/lib/(.+)$');

/// A package shipped inside an SDK, `…/flutter/packages/flutter_test/lib/x.dart`.
final RegExp _sdkPackage = RegExp(r'/packages/([a-zA-Z_0-9]+)/lib/(.+)$');

Uri _readableUri(String raw) {
  final uri = Uri.parse(raw);
  if (uri.scheme == 'org-dartlang-app') {
    // `flutter test` compiles with the test directory as the application root.
    return Uri.parse('test${uri.path}');
  }
  if (uri.scheme == 'file') {
    final hosted = _hostedPackage.firstMatch(uri.path);
    if (hosted != null) {
      return Uri.parse('package:${hosted.group(1)}/${hosted.group(2)}');
    }
    final sdk = _sdkPackage.firstMatch(uri.path);
    if (sdk != null) {
      return Uri.parse('package:${sdk.group(1)}/${sdk.group(2)}');
    }
  }
  return uri;
}

/// Drops the `M.` module prefix dart2wasm puts in front of every member.
String _readableMember(String member) =>
    member.startsWith('M.') ? member.substring(2) : member;
