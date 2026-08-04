import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/timeline/html/ide_link.dart';
import 'package:stack_trace/stack_trace.dart';

/// Creates a `my_project` directory that outlives nothing but this test.
///
/// [withIdeaFolder] decides whether IntelliJ would recognize it as a project.
Directory setupProjectDir({required bool withIdeaFolder}) {
  final tempDir = Directory.systemTemp.createTempSync('spot_ide_link');
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final dir = Directory('${tempDir.path}${Platform.pathSeparator}my_project')
    ..createSync(recursive: true);
  if (withIdeaFolder) {
    Directory('${dir.path}${Platform.pathSeparator}.idea').createSync();
  }
  return dir;
}

Frame frameAt(String path, {int? line, int? column}) {
  return Frame(Uri.file(path), line, column, 'main');
}

void main() {
  test('no IDE in the environment means no link', () {
    final link = ideLinkFor(
      frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
      environment: const {'PATH': '/usr/bin', 'SHELL': '/bin/zsh'},
      workingDirectory: setupProjectDir(withIdeaFolder: true),
    );

    expect(link, isNull);
  });

  test('an event without an initiator has nothing to point at', () {
    final link = ideLinkFor(
      null,
      environment: const {'TERM_PROGRAM': 'vscode'},
      workingDirectory: setupProjectDir(withIdeaFolder: true),
    );

    expect(link, isNull);
  });

  group('VS Code', () {
    test('links the absolute path with a one-based line and column', () {
      final link = ideLinkFor(
        frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
        environment: const {'TERM_PROGRAM': 'vscode'},
        workingDirectory: setupProjectDir(withIdeaFolder: false),
      );

      expect(link!.name, 'VS Code');
      expect(link.url, 'vscode://file//my_project/test/example_test.dart:12:3');
    });

    test(
      'is detected by the variables the debugger sets, without a terminal',
      () {
        final link = ideLinkFor(
          frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
          environment: const {'VSCODE_PID': '4242'},
          workingDirectory: setupProjectDir(withIdeaFolder: false),
        );

        expect(link?.name, 'VS Code');
      },
    );

    test('does not need a project folder, unlike IDEA', () {
      final link = ideLinkFor(
        frameAt('/somewhere/else/example_test.dart', line: 1, column: 1),
        environment: const {'TERM_PROGRAM': 'vscode'},
        workingDirectory: setupProjectDir(withIdeaFolder: false),
      );

      expect(link, isNotNull);
    });

    test('wins over IntelliJ when both are in the environment', () {
      // An IntelliJ install on PATH matches the IntelliJ fingerprint even when
      // the test was started by VS Code. VS Code identifies itself precisely,
      // so it decides.
      final link = ideLinkFor(
        frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
        environment: const {
          'TERM_PROGRAM': 'vscode',
          'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
        },
        workingDirectory: setupProjectDir(withIdeaFolder: true),
      );

      expect(link?.name, 'VS Code');
    });
  });

  group('IDEA', () {
    test('links a project-relative path with a zero-based line', () {
      final link = ideLinkFor(
        frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
        environment: const {
          'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
        },
        workingDirectory: setupProjectDir(withIdeaFolder: true),
      );

      expect(link!.name, 'IDEA');
      expect(
        link.url,
        'jetbrains://idea/navigate/reference'
        '?project=my_project&path=test/example_test.dart:11:3',
      );
    });

    test('finds the project from a subdirectory', () {
      final project = setupProjectDir(withIdeaFolder: true);
      final nested = Directory('${project.path}${Platform.pathSeparator}test')
        ..createSync();

      final link = ideLinkFor(
        frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
        environment: const {
          'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
        },
        workingDirectory: nested,
      );

      expect(link?.url, contains('project=my_project'));
    });

    test(
      'has no link without a project folder to resolve the path against',
      () {
        final link = ideLinkFor(
          frameAt('/my_project/test/example_test.dart', line: 12, column: 3),
          environment: const {
            'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
          },
          workingDirectory: setupProjectDir(withIdeaFolder: false),
        );

        expect(link, isNull);
      },
    );

    test('has no link when the file is outside the project', () {
      final link = ideLinkFor(
        frameAt('/elsewhere/example_test.dart', line: 12, column: 3),
        environment: const {
          'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
        },
        workingDirectory: setupProjectDir(withIdeaFolder: true),
      );

      expect(link, isNull);
    });

    test('clamps the first line instead of reporting line -1', () {
      final link = ideLinkFor(
        frameAt('/my_project/test/example_test.dart', line: 1, column: 1),
        environment: const {
          'PATH': '/Applications/IntelliJ IDEA.app/Contents/MacOS',
        },
        workingDirectory: setupProjectDir(withIdeaFolder: true),
      );

      expect(link?.url, endsWith('example_test.dart:0:1'));
    });
  });
}
