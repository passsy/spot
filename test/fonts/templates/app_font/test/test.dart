// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('App font Montserrat is loaded from FontManifest',
      (WidgetTester tester) async {
    final previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.parse('test/test_test.dart'),
      precisionTolerance: 0.10,
    );
    addTearDown(() => goldenFileComparator = previousGoldenFileComparator);
    await loadAppFonts();

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

  testWidgets('Montserrat can be loaded with blank family name',
      (WidgetTester tester) async {
    final previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.parse('test/test_test.dart'),
      precisionTolerance: 0.10,
    );
    addTearDown(() => goldenFileComparator = previousGoldenFileComparator);
    await loadFont('', ['fonts/Montserrat-Regular.ttf']);

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
    this.fontFamily,
    this.fontFamilyFallback = const [],
  });

  final String? fontFamily;
  final List<String> fontFamilyFallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTextStyle(
        style: TextStyle(
          inherit: false,
          height: 1.2,
          letterSpacing: 0.0,
          fontSize: 52,
          color: Colors.black,
          fontFamilyFallback: fontFamilyFallback,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'thin',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'extra-light',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'light',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'normal',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'medium',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'semi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'bold',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'extra',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'thick',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Colored ',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Text ',
                    style: TextStyle(
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    'Rocks',
                    style: TextStyle(
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Italic',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Underlined',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ItalicBold',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFeatures: [
                      FontFeature.liningFigures(),
                    ],
                  ),
                  children: [
                    TextSpan(
                      text: '6 ',
                      style: TextStyle(
                        fontSize: 6,
                      ),
                    ),
                    TextSpan(
                      text: '8 ',
                      style: TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    TextSpan(
                      text: '10 ',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: '11 ',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: '12 ',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '13 ',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: '14 ',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '16 ',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '18 ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '20 ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: '22 ',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: '24 ',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    TextSpan(
                      text: '26 ',
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    TextSpan(
                      text: '32 ',
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    TextSpan(
                      text: '36 ',
                      style: TextStyle(
                        fontSize: 36,
                      ),
                    ),
                    TextSpan(
                      text: '42 ',
                      style: TextStyle(
                        fontSize: 42,
                      ),
                    ),
                    TextSpan(
                      text: '48 ',
                      style: TextStyle(
                        fontSize: 48,
                      ),
                    ),
                    TextSpan(
                      text: '52 ',
                      style: TextStyle(
                        fontSize: 52,
                      ),
                    ),
                    TextSpan(
                      text: '64',
                      style: TextStyle(
                        fontSize: 64,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Emojis 👍 ❤️ 🎉 💩 ✌️',
                style: TextStyle(fontSize: 48),
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
