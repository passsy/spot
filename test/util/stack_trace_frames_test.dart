import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/utils/stack_trace_frames.dart';
import 'package:stack_trace/stack_trace.dart';

/// A frame the way dart2wasm reports it: everything points at the module and
/// the real location is appended to the member.
Frame wasmFrame(String member) =>
    Frame(Uri.parse('http://localhost:1234/main.dart.wasm'), 1, 1, member);

void main() {
  group('dart2wasm frames', () {
    test('the application root becomes the test directory', () {
      final frames = resolveFrames([
        wasmFrame(
          'M.main closure at org-dartlang-app:///screenshot/a_test.dart:207:63',
        ),
      ]);

      expect(frames.single.uri.toString(), 'test/screenshot/a_test.dart');
      expect(frames.single.line, 207);
      expect(frames.single.column, 63);
      expect(frames.single.member, 'main closure');
    });

    test('a hosted package becomes a package uri', () {
      final frames = resolveFrames([
        wasmFrame(
          'M.f closure at file:///x/hosted/pub.dev/spot-1.2.3/lib/src/a.dart:5:1',
        ),
      ]);

      expect(frames.single.uri.toString(), 'package:spot/src/a.dart');
    });

    test('a package inside an SDK becomes a package uri', () {
      final frames = resolveFrames([
        wasmFrame(
          'M.f closure at file:///f/packages/flutter_test/lib/src/b.dart:9:2',
        ),
      ]);

      expect(frames.single.uri.toString(), 'package:flutter_test/src/b.dart');
    });

    test('an SDK library becomes a dart uri so it reads as core', () {
      final frames = resolveFrames([
        wasmFrame(
          'M.f closure at org-dartlang-sdk:///dart-sdk/lib/async/zone.dart:743:12',
        ),
      ]);

      expect(frames.single.uri.toString(), 'dart:async');
      expect(frames.single.isCore, isTrue);
    });

    test('the inner and trampoline suffixes are ignored', () {
      final frames = resolveFrames([
        wasmFrame('M.a closure at org-dartlang-app:///a_test.dart:1:2 inner'),
        wasmFrame(
            'M.b wrapper at org-dartlang-app:///a_test.dart:3:4 trampoline'),
      ]);

      expect(frames.map((f) => f.line), [1, 3]);
      expect(frames.map((f) => f.member), ['a closure', 'b wrapper']);
    });

    test('frames without a location are dropped', () {
      final frames = resolveFrames([
        wasmFrame('M.takeScreenshot'),
        wasmFrame('M.main closure at org-dartlang-app:///a_test.dart:1:2'),
      ]);

      expect(frames, hasLength(1));
      expect(frames.single.uri.toString(), 'test/a_test.dart');
    });
  }, skip: !kIsWasm);

  group('isSdkFrame', () {
    test('accepts the dart uri the VM and dart2wasm report', () {
      expect(isSdkFrame(Frame(Uri.parse('dart:async'), 1, 1, 'f')), isTrue);
    });

    test('accepts the served path dart2js and DDC report', () {
      final served = Uri.parse(
        'http://localhost:1234/dart-sdk/lib/_internal/patch/async_patch.dart',
      );
      expect(isSdkFrame(Frame(served, 1, 1, 'f')), isTrue);
    });

    test('rejects a test file', () {
      final test = Uri.parse('http://localhost:1234/timeline/a_test.dart');
      expect(isSdkFrame(Frame(test, 1, 1, 'f')), isFalse);
    });
  });
}
