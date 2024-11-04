import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Montserrat is loaded from fonts folder when set', (WidgetTester tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FontTestWidget(
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
  // testWidgets('Third-party font is loaded when used', (WidgetTester tester) async {
  //   await loadAppFonts();
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
  //     matchesGoldenFile('golden_load_roboto.png'),
  //   );
  // });
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
