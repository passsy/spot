import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/utils/stack_trace_frames.dart';
import 'package:stack_trace/stack_trace.dart';

/// A frame the way dart2wasm reports it: everything points at the module and
/// the real location is appended to the member.
Frame wasmFrame(String member) =>
    Frame(Uri.parse('http://localhost:1234/main.dart.wasm'), 1, 1, member);

/// A frame the way DDC reports it without a source map: the url the browser
/// loaded the compiled library from.
Frame servedFrame(String path, {int line = 7, int column = 3}) =>
    Frame(Uri.parse('http://localhost:1234$path'), line, column, 'f');

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

  group('dart2js and DDC frames', () {
    test('a served dependency becomes a package uri', () {
      final frames = resolveFrames([
        servedFrame(
            '/packages/stack_trace/src/stack_zone_specification.dart.js'),
      ]);

      expect(
        frames.single.uri.toString(),
        'package:stack_trace/src/stack_zone_specification.dart',
      );
      expect(frames.single.package, 'stack_trace');
    });

    test('a served suite file becomes a path in the test directory', () {
      // `flutter test` serves the test directory as the server root.
      final frames = resolveFrames([
        servedFrame('/timeline/tap/act_tap_timeline_test_bodies.dart.js'),
      ]);

      expect(
        frames.single.uri.toString(),
        'test/timeline/tap/act_tap_timeline_test_bodies.dart',
      );
      expect(frames.single.package, isNull);
    });

    test('line, column and member survive the rewrite', () {
      final frames = resolveFrames([
        servedFrame('/a_test.dart.js', line: 235, column: 71),
      ]);

      expect(frames.single.line, 235);
      expect(frames.single.column, 71);
      expect(frames.single.member, 'f');
    });

    test('an SDK url is left alone', () {
      // Naming the library from the path would get it wrong, and isSdkFrame
      // already recognises these.
      const path =
          '/dart-sdk/lib/_internal/js_dev_runtime/patch/async_patch.dart';
      final frames = resolveFrames([servedFrame(path)]);

      expect(frames.single.uri.toString(), 'http://localhost:1234$path');
      expect(isSdkFrame(frames.single), isTrue);
    });

    test('javascript that was never a Dart library is left alone', () {
      // The DDC runtime, for one, is not somebody's source file.
      final frames = resolveFrames([servedFrame('/dart_sdk.js')]);

      expect(frames.single.uri.toString(), 'http://localhost:1234/dart_sdk.js');
    });

    test('a uri a source map already resolved is left alone', () {
      final resolved =
          Frame(Uri.parse('package:spot/src/act/act.dart'), 1, 2, 'f');

      expect(resolveFrames([resolved]).single.uri, resolved.uri);
    });
  }, skip: !kIsWeb || kIsWasm);

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
