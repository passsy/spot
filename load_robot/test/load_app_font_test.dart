import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Without loadAppFonts FlutterTest font is used', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestPage(),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_load_default.png'),
    );
  });
  testWidgets('Robot is loaded from SDK when nothing else is defined (default)', (WidgetTester tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestPage(),
      ),
    );
    await takeScreenshot();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_load_robot.png'),
    );
  });
  testWidgets('When another font is used its not found when loadAppFonts not called', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestPage(
          fontFamily: 'Montserrat',
        ),
      ),
    );
    await takeScreenshot();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_load_montserrat_fail.png'),
    );
  });
  testWidgets('Additional fonts are loaded with loadAppFonts', (WidgetTester tester) async {
    final fontManifestWithMontserrat = [
      {
        'family': 'Montserrat',
        'fonts': [
          {'asset': 'fonts/Montserrat-Regular.ttf'},
        ],
      }
    ];
    await loadFontsFromFontsManifest(fontManifestWithMontserrat);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestPage(
          fontFamily: 'Montserrat',
        ),
      ),
    );
    await takeScreenshot();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_load_montserrat_success.png'),
    );
  });
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({
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
              style: TextStyle(fontSize: 24, fontFamily: fontFamily),
            ),
            const SizedBox(height: 10),
            Text(
              'Bold Text',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Italic Text',
              style: TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Colored Text',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Underlined Text',
              style: TextStyle(
                fontSize: 24,
                decoration: TextDecoration.underline,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Custom Font Size (32)',
              style: TextStyle(fontSize: 32, fontFamily: fontFamily),
            ),
          ],
        ),
      ),
    );
  }
}
