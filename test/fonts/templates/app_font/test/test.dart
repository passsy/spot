// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Montserrat is loaded from fonts folder when set',
      (WidgetTester tester) async {
    final previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.parse('test/test_test.dart'),
      precisionTolerance: 0.10,
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
    required this.fontFamily,
  });

  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTextStyle(
        style: TextStyle(
          inherit: false,
          height: 1.2,
          letterSpacing: 0.0,
          fontSize: 64,
          color: Colors.black,
          fontFamily: fontFamily,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Default Font',
              ),
              SizedBox(height: 10),
              Text(
                'Italic Text',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Colored Text',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Underlined Text',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Custom Font Size (56)',
                style: TextStyle(
                  fontSize: 56,
                ),
              ),
            ],
          ),
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
      if (result.diffPercent > 0.0) {
        debugPrint(
          'The golden file $golden has a difference\n'
          'of ${result.diffPercent * 100}%\n'
          'which is within the tolerance of $_precisionTolerance',
        );
      }
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
