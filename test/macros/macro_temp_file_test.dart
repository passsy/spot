import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/src/spot/macros/widget_selector_and_matcher_macro.dart';

void main() {
  const String testString = '''
import 'package:spot/src/spot/matcher_generator.dart' show CreateMatchers;
import 'package:spot/src/spot/props.dart'
    show
        MatchProp,
        MatchPropNonNullable,
        MatchPropNullable,
        NamedElementProp,
        NamedRenderObjectProp,
        NamedWidgetProp,
        PropSelectorQueries,
        WidgetSelectorProp,
        elementProp,
        renderObjectProp,
        widgetProp;
''';

  final File tempFile = File('temp_test_file.dart');

  setUp(() async {
    await tempFile.writeAsString(testString);
    // Print the written file content for verification
    final writtenContent = await tempFile.readAsString();
    debugPrint('Written content:\n$writtenContent');
  });

  tearDown(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  test('extractImports returns correct import statements', () async {
    // Define the hardcoded string
    const String testString = '''
import 'package:spot/src/spot/matcher_generator.dart' show CreateMatchers;
import 'package:spot/src/spot/props.dart'
    show
        MatchProp,
        MatchPropNonNullable,
        MatchPropNullable,
        NamedElementProp,
        NamedRenderObjectProp,
        NamedWidgetProp,
        PropSelectorQueries,
        WidgetSelectorProp,
        elementProp,
        renderObjectProp,
        widgetProp;
''';

    // Extract imports from the temporary file
    final extractedImports =
        WidgetSelectorAndMatcherMacro.readImports(tempFile.path);
    debugPrint(extractedImports);
    // Compare the result with the original string
    expect(extractedImports, equals(testString));
  });
}
