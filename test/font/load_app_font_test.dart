import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Loading App fonts', (WidgetTester tester) async {
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
      matchesGoldenFile('golden_load_app_font.png'),
    );
  });
  testWidgets('Loading App fonts 2', (WidgetTester tester) async {
    final manifestWithMontserrat = [
      {
        "family": "Montserrat",
        "fonts": [
          {"asset": "test/font/Montserrat-Regular.ttf"},
        ],
      }
    ];
    await loadFontsFromFontsManifest(manifestWithMontserrat);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestPage(),
      ),
    );
    await takeScreenshot();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('golden_load_app_font.png'),
    );
  });
}

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Default Font',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Bold Text',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Italic Text',
              style: TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Colored Text',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Underlined Text',
              style: TextStyle(
                fontSize: 24,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Custom Font Size (32)',
              style: TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
