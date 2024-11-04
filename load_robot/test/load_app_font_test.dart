import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'test_project_files.dart';

void main() {
  test('When loadAppFonts ', () async {
    await createTestApp('test_project');
  });

  // testWidgets('Robot is loaded from SDK when nothing else is defined (default)', (WidgetTester tester) async {
  //   await loadAppFonts();
  //   await tester.pumpWidget(
  //     const MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       home: FontTestWidget(),
  //     ),
  //   );
  //   await takeScreenshot();
  //   await expectLater(
  //     find.byType(MaterialApp),
  //     matchesGoldenFile('golden_load_robot.png'),
  //   );
  // });
  // testWidgets('Additional fonts are loaded with loadAppFonts', (WidgetTester tester) async {
  //   final fontManifestWithMontserrat = [
  //     {
  //       'family': 'Montserrat',
  //       'fonts': [
  //         {'asset': 'fonts/Montserrat-Regular.ttf'},
  //       ],
  //     }
  //   ];
  //   await loadFontsFromFontsManifest(fontManifestWithMontserrat);
  //   await tester.pumpWidget(
  //     const MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       home: FontTestWidget(
  //         fontFamily: 'Montserrat',
  //       ),
  //     ),
  //   );
  //   await takeScreenshot();
  //   await expectLater(
  //     find.byType(MaterialApp),
  //     matchesGoldenFile('golden_load_montserrat_success.png'),
  //   );
  // });
}

Future<void> createTestApp(String name) async {
  int exitCode = -1;
  try {
    final testProjectDir = await Directory.systemTemp.createTemp(name);
    final pubspec = buildPubspecString(name, true);

    // Create pubspec.yaml
    final File file = File('${testProjectDir.path}/pubspec.yaml');
    file.writeAsStringSync(pubspec);

    // Create test file
    final testFile = File('${Directory.current.path}/test/virtual/font_test.dart');
    final testFolder = await Directory('${testProjectDir.path}/test').create();
    testFile.copySync('${testFolder.path}/font_test.dart');

    // Move golden golden_load_robot.png
    final goldenFolder = await Directory('${testProjectDir.path}/test').create();
    final goldenFile = File('${Directory.current.path}/test/virtual/golden_load_robot.png');
    goldenFile.copySync('${goldenFolder.path}/golden_load_robot.png');

    // Run pub get
    await Process.run('flutter', ['create', '--platforms=macos', '-e' '.'], workingDirectory: testProjectDir.path);

    // Run pub get
    await Process.run('flutter', ['pub', 'get'], workingDirectory: testProjectDir.path);

    // Run tests
    final test = await Process.start('flutter', ['test'], workingDirectory: testProjectDir.path);
    test.stdout.transform(utf8.decoder).listen((event) {
      print(event);
    });
    test.stderr.transform(utf8.decoder).listen((event) {
      print(event);
    });
    exitCode = await test.exitCode;
  } catch (e) {
    print(e);
  } finally {
    expect(exitCode, equals(0));

    // Cleanup: Remove the temporary directory after test
    // tempDir.deleteSync(recursive: true);
  }
}
