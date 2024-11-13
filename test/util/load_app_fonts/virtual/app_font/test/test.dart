import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Montserrat is loaded from fonts folder when set',
      (WidgetTester tester) async {
    // The pipeline does run tests with Flutter 3.10 with dart 3.0.
    // Since that, there were do many changes in the font rendering so we skip those tests for that version.
    if (Platform.version.contains('3.0')) {
      return;
    }
    final previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      // Replace with your test file path:
      Uri.parse('test/widget_test.dart'),
      precisionTolerance: 0.011,
    );
    addTearDown(() => goldenFileComparator = previousGoldenFileComparator);
    await loadFonts();
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestWidget(
          fontFamily: 'Montserrat',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden.png'),
    );
  });
}

class FontTestWidget extends StatelessWidget {
  const FontTestWidget({
    super.key,
    this.fontFamily = 'Roboto',
  });

  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Default Font',
              style: TextStyle(fontSize: 64, fontFamily: fontFamily),
            ),
            const SizedBox(height: 10),
            Text(
              'Italic Text',
              style: TextStyle(
                fontSize: 64,
                fontStyle: FontStyle.italic,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Colored Text',
              style: TextStyle(
                fontSize: 64,
                color: Colors.blue,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Underlined Text',
              style: TextStyle(
                fontSize: 64,
                decoration: TextDecoration.underline,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Custom Font Size (32)',
              style: TextStyle(fontSize: 64, fontFamily: fontFamily),
            ),
          ],
        ),
      ),
    );
  }
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  }) : _precisionTolerance = precisionTolerance;

  /// How much the golden image can differ from the test image.
  ///
  /// It is expected to be between 0 and 1. Where 0 is no difference (the same image)
  /// and 1 is the maximum difference (completely different images).
  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
