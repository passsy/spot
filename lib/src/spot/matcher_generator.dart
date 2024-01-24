// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spot/spot.dart';

Type _typeOf<T>() => T;

/// Extension on [WidgetSelector] that allows to generate matchers for
/// the properties of a widget.
extension CreateMatchers<W extends Widget> on WidgetSelector<W> {
  /// Prints the generated matchers for the properties of [W] to the console.
  void printMatchers({
    Map<String, String> propNameOverrides = const {},
  }) {
    final value = createMatcherString(
      propNameOverrides: propNameOverrides,
    );
    if (value == null) {
      return;
    }

    // ignore: avoid_print
    print(value);
  }

  /// Writes the generated matchers for the properties of [W] to a file.
  void writeMatchersToFile({
    required String path,
    Map<String, String> propNameOverrides = const {},
    String? imports,
    bool Function(DiagnosticsNode node)? filter,
  }) {
    final content = createMatcherString(
      propNameOverrides: propNameOverrides,
      imports: imports,
      filter: filter,
    );
    final file = File(path);
    if (content == null) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } else {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }
  }

  /// Generates matchers for the properties of [W].
  String? createMatcherString({
    Map<String, String> propNameOverrides = const {},
    String? imports,
    bool Function(DiagnosticsNode node)? filter,
  }) {
    final s = snapshot()..existsAtLeastOnce();
    final anyElement = s.discoveredElements.first;

    final elementProps = anyElement.toDiagnosticsNode().getProperties();
    final widgetProps =
        mapElementToWidget(anyElement).toDiagnosticsNode().getProperties();

    String widgetType = _typeOf<W>().toString().capitalize();
    if (widgetType.contains('<')) {
      widgetType = widgetType.substring(0, widgetType.indexOf('<'));
    }
    bool addedMethods = false;

    final matcherSb = StringBuffer();
    matcherSb.writeln('''
/// Matchers for the properties of [$widgetType] provided via [Diagnosticable.debugFillProperties]
extension ${widgetType}Matcher on WidgetMatcher<$widgetType> {
''');

    final selectorSb = StringBuffer();
    selectorSb.writeln(
      '''
/// Allows filtering [$widgetType] by the properties provided via [Diagnosticable.debugFillProperties]
extension ${widgetType}Selector on WidgetSelector<$widgetType> {
''',
    );

    final distinctProps =
        [...widgetProps, ...elementProps].distinctBy((it) => it.name).toList();
    for (final DiagnosticsNode prop in distinctProps) {
      if (filter != null && !filter(prop)) {
        continue;
      }
      final String diagnosticPropName = prop.name!;
      final String methodPropName = () {
        final String name = prop.name!;
        final parts = name.split(RegExp('[^a-zA-Z]'));
        if (parts.length == 1) {
          return name;
        }

        // camel case
        return parts
            .mapIndexed((index, it) => index == 0 ? it : it.capitalize())
            .join();
      }();
      final humanPropName = propNameOverrides[methodPropName] ?? methodPropName;
      String propType = prop.getType();
      if (prop is ObjectFlagProperty &&
          (propType == 'Widget' || propType == 'Widget?')) {
        // matchers on widgets are not supported, use .spot() to check the tree further down
        continue;
      }
      if (prop is FlagProperty && methodPropName == 'dirty') {
        // dirty flags are irrelevant for assertions (and always false)
        continue;
      }
      if (propType.contains('=>')) {
        // ignore lambda properties
        continue;
      }
      if (prop.name == 'depth' || prop.name == 'key') {
        // ignore default properties that are covered by general Wiget selectors
        continue;
      }
      if (prop.name == 'dependencies') {
        if (propType == 'List<DiagnosticsNode>' ||
            propType == 'Set<InheritedElement>') {
          // Widget dependencies are only indirect properties
          continue;
        }
      }
      if (prop.name == 'renderObject' && propType == 'RenderObject') {
        final propValueRuntimeType = prop.value.runtimeType.toString();
        if (!propValueRuntimeType.startsWith('_')) {
          propType = propValueRuntimeType;
        }
      }

      if (prop.name == 'state' && propType.contains('State<StatefulWidget>')) {
        final propValueRuntimeType = prop.value.runtimeType.toString();
        if (propValueRuntimeType.startsWith('_')) {
          // this is not useful without type
          continue;
        }
        propType = propValueRuntimeType;
        continue;
      }
      final propTypeNullable = propType.endsWith('?') ? propType : '$propType?';

      String matcherVerb = 'has';
      if (humanPropName == 'enabled') {
        matcherVerb = 'is';
      }

      addedMethods = true;
      final widgetMatcherWithValueName =
          '$matcherVerb${humanPropName.capitalize()}';
      final widgetMatcherWithPropName = '${widgetMatcherWithValueName}Where';

      final String valueExample = _getExampleValue(node: prop);
      final String matcherExample = _getExampleValue(node: prop, matcher: true);

      matcherSb.writeln('''
  /// Expects that $humanPropName of [$widgetType] matches the condition in [match].
  /// #### Example usage:
  /// ```dart     
  ///   spot<$widgetType>().existsOnce().$widgetMatcherWithPropName($matcherExample);
  /// ```
  WidgetMatcher<$widgetType> $widgetMatcherWithPropName(MatchProp<$propType> match) {
    return hasDiagnosticProp<$propType>('$diagnosticPropName', match);
  }
  
  /// Expects that $humanPropName of [$widgetType] equals (==) [value].
  /// #### Example usage:
  /// ```dart     
  ///   spot<$widgetType>().existsOnce().$widgetMatcherWithValueName($valueExample);
  /// ```
  WidgetMatcher<$widgetType> $widgetMatcherWithValueName($propTypeNullable value) {
    return hasDiagnosticProp<$propType>('$diagnosticPropName', (it) => value == null ? it.isNull() : it.equals(value));
  }
''');

      final propPart = humanPropName.capitalize();

      selectorSb.writeln('''
  /// Creates a [WidgetSelector] that finds all [$widgetType] where $humanPropName matches the condition.
  /// #### Example usage:
  /// ```dart     
  ///   spot<$widgetType>().where$propPart($matcherExample).existsOnce();
  /// ```
  @useResult
  WidgetSelector<$widgetType> where$propPart(MatchProp<$propType> match) {
    return withDiagnosticProp<$propType>('$diagnosticPropName', match);
  }
  
  /// Creates a [WidgetSelector] that finds all [$widgetType] where $humanPropName equals (==) [value].
  /// #### Example usage:
  /// ```dart     
  ///   spot<$widgetType>().with$propPart($valueExample).existsOnce();
  /// ```
  @useResult
  WidgetSelector<$widgetType> with$propPart($propTypeNullable value) {
    return withDiagnosticProp<$propType>('$diagnosticPropName', (it) => value == null ? it.isNull() : it.equals(value));
  }
''');
    }

    matcherSb.writeln('}');
    selectorSb.writeln('}');

    if (addedMethods == false) {
      // nothing added, don't generate the file at all
      return null;
    }

    final overridesParam = propNameOverrides.isEmpty
        ? ''
        : () {
            final map = propNameOverrides
                .mapEntries((it) => MapEntry("'${it.key}'", "'${it.value}'"))
                .map((it) => '${it.key}: ${it.value}')
                .joinToString(separator: ', ', prefix: '{', postfix: '}');
            return 'propNameOverrides: $map';
          }();

    return '''
// ignore_for_file: require_trailing_commas
\/\/ coverage:ignore-file

${imports ?? "import 'package:flutter/widgets.dart';"}
import 'package:spot/spot.dart';

/// Matchers for [$widgetType] auto-generated by spot
///
/// ```dart
/// spot<$widgetType>().printMatchers($overridesParam);
/// ```
$matcherSb
$selectorSb    
    ''';
  }
}

/// Extension on [DiagnosticsNode] with helper methods to
/// extract the type of a property.
extension ReadType on DiagnosticsNode {
  /// Returns the type of the property.
  String getType() {
    if (this is StringProperty) {
      return 'String';
    }

    if (this is FlagProperty) {
      return 'bool';
    }

    if (this is DoubleProperty) {
      return 'double';
    }

    if (this is IntProperty) {
      return 'int';
    }
    if (this is IconDataProperty) {
      return 'IconData';
    }
    if (this is ColorProperty) {
      return 'Color';
    }

    if (this is AttributedStringProperty) {
      return 'String';
    }

    if (this is EnumProperty) {
      // "EnumProperty<TextAlign>"
      final Type runtimeType = this.runtimeType;
      // "TextAlign"
      final String? genericType = () {
        try {
          final regex = RegExp('<(.*)>');
          return regex.firstMatch(runtimeType.toString())?.group(1);
        } catch (_) {
          return null;
        }
      }();

      if (genericType != null) {
        return genericType;
      }
    }

    if (this is DiagnosticsProperty) {
      final Type runtimeType = this.runtimeType;
      final String? genericType = () {
        try {
          final regex = RegExp('<(.*)>');
          return regex.firstMatch(runtimeType.toString())?.group(1);
        } catch (_) {
          return null;
        }
      }();
      if (genericType != null) {
        return genericType;
      }
    }

    return 'Object?';
  }
}

String _getExampleValue({
  required DiagnosticsNode node,
  bool matcher = false,
}) {
  if (node is StringProperty || node is DiagnosticsProperty<String>) {
    if (matcher) {
      return '''(it) => it.equals('foo')''';
    }
    return "'foo'";
  }

  if (node is FlagProperty || node is DiagnosticsProperty<bool>) {
    if (matcher) {
      return '''(it) => it.isTrue()''';
    }
    return 'true';
  }

  if (node is DoubleProperty || node is DiagnosticsProperty<double>) {
    if (matcher) {
      return '''(it) => it.isGreaterThan(10.5)''';
    }
    return '10.5';
  }

  if (node is IntProperty || node is DiagnosticsProperty<int>) {
    if (matcher) {
      return '''(it) => it.isGreaterThan(10)''';
    }
    return '10';
  }

  if (node is IconDataProperty || node is DiagnosticsProperty<IconData>) {
    if (matcher) {
      return '''(it) => it.equals(Icons.home)''';
    }
    return 'Icons.home';
  }

  if (node is ColorProperty || node is DiagnosticsProperty<Color>) {
    if (matcher) {
      return '''(it) => it.equals(Colors.red)''';
    }
    return 'Colors.red';
  }

  if (node is AttributedStringProperty) {
    if (matcher) {
      return '''(it) => it.equals('foo')''';
    }
    return "'foo'";
  }

  if (node is EnumProperty || node is DiagnosticsProperty<Enum>) {
    final Type runtimeType = node.runtimeType;
    final String? genericType = () {
      try {
        final regex = RegExp('<(.*)>');
        return regex.firstMatch(runtimeType.toString())?.group(1);
      } catch (_) {
        if (matcher) {
          return '''(it) => it.equals(value to match)''';
        }
        return "value to match";
      }
    }();

    if (genericType != null) {
      if (matcher) {
        return '''(it) => it.equals($genericType.values.first)''';
      }
      return '$genericType.values.first';
    }
  }

  if (node is DiagnosticsProperty) {
    final Type runtimeType = node.runtimeType;
    final String? genericType = () {
      try {
        final regex = RegExp('<(.*)>');
        return regex.firstMatch(runtimeType.toString())?.group(1);
      } catch (_) {
        if (matcher) {
          return '''(it) => it.equals(value to match)''';
        }
        return "value to match";
      }
    }();

    if (genericType != null) {
      final value = _examplesFromGenericType(genericType) ??
          '### your $genericType value to match';
      if (matcher) {
        return '''(it) => it.equals($value)''';
      }
      return value;
    }
  }

  if (matcher) {
    return '''(it) => it.equals(value to match)''';
  }
  return "value to match";
}

String? _examplesFromGenericType(String genericType) {
  String? example;
  if (genericType.endsWith('?')) {
    return 'null';
  }
  if (genericType == 'String') {
    example = "'foo'";
  } else if (genericType == 'Locale') {
    example = "Locale('en', 'US')";
  } else if (genericType == 'TextHeightBehavior') {
    example =
        "TextHeightBehavior(applyHeightToFirstAscent: true, applyHeightToLastDescent: false)";
  } else if (genericType == 'Widget') {
    example = "Container()";
  } else if (genericType == 'Key') {
    example = "ValueKey('key')";
  } else if (genericType == 'Set') {
    example = "{}";
  } else if (genericType == 'Set<InheritedElement>') {
    example = "<InheritedElement>{}";
  } else if (genericType == 'TextEditingController') {
    example = "TextEditingController()";
  } else if (genericType == 'FocusNode') {
    example = "FocusNode()";
  } else if (genericType == 'FontWeight') {
    example = "FontWeight.bold";
  } else if (genericType == 'Paint') {
    example = "Paint()";
  } else if (genericType == 'TextInputType') {
    example = "TextInputType.text";
  } else if (genericType == 'TextStyle') {
    example = "TextStyle()";
  } else if (genericType == 'ScrollController') {
    example = "ScrollController()";
  } else if (genericType == 'ScrollPhysics') {
    example = "BouncingScrollPhysics()";
  } else if (genericType == 'Iterable') {
    example = "<Iterable>[]";
  } else if (genericType == 'UndoHistoryController') {
    example = "UndoHistoryController()";
  } else if (genericType == 'SpellCheckConfiguration') {
    example = "SpellCheckConfiguration()";
  } else if (genericType == 'List') {
    example = "[]";
  } else if (genericType == 'List<String>' ||
      genericType == 'Iterable<String>') {
    example = "['foo', 'bar']";
  } else if (genericType == 'State<StatefulWidget>') {
    example = "State<StatefulWidget>()";
  } else if (genericType == 'AlignmentGeometry') {
    example = "Alignment.center";
  } else if (genericType == 'EdgeInsetsGeometry') {
    example = "EdgeInsets.all(8.0)";
  } else if (genericType == 'Decoration') {
    example = "BoxDecoration(color: Colors.blue)";
  } else if (genericType == 'BoxConstraints') {
    example = "BoxConstraints.tight(Size(100, 100))";
  } else if (genericType == 'Matrix4') {
    example = "Matrix4.identity()";
  } else if (genericType == 'RenderObject') {
    example = "RenderBox()";
  } else if (genericType == 'Shadow') {
    example = "Shadow(color: Colors.black, blurRadius: 10.0)";
  } else if (genericType == 'Radius') {
    example = "Radius.circular(10.0)";
  } else if (genericType == 'ImageProvider' ||
      genericType == 'ImageProvider<Object>') {
    example = "NetworkImage('https://example.com/image.png')";
  } else if (genericType == 'Function' || genericType == '() => void') {
    example = "() {}";
  } else if (genericType == 'Animation' || genericType == 'Animation<double>') {
    example = "AnimationController(vsync: this)";
  } else if (genericType == 'Rect') {
    example = "Rect.fromLTWH(0, 0, 100, 100)";
  } else if (genericType == 'SemanticsProperties') {
    example = "SemanticsProperties()";
  } else if (genericType == 'SemanticsSortKey') {
    example = "OrdinalSortKey(1.0)";
  } else if (genericType == 'SemanticsHintOverrides') {
    example = "SemanticsHintOverrides()";
  } else if (genericType == 'bool') {
    example = "true";
  } else if (genericType == 'TextSelectionControls') {
    example = "MaterialTextSelectionControls()";
  } else if (genericType == 'TextAlignVertical') {
    example = "TextAlignVertical.center";
  } else if (genericType == 'Duration') {
    example = "Duration(seconds: 30)";
  } else if (genericType == 'InputDecoration') {
    example = "InputDecoration()";
  } else if (genericType == 'VisualDensity') {
    example = "VisualDensity(horizontal: 1.0,vertical: 1.0)";
  } else if (genericType == 'Object') {
    example = "Object()";
  } else if (genericType == 'ShapeBorder') {
    example = "RoundedRectangleBorder()";
  } else if (genericType == 'MouseCursor') {
    example = "SystemMouseCursors.click";
  } else if (genericType == 'ButtonStyle') {
    example =
        "ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue))";
  } else if (genericType == '(bool) => void' ||
      genericType == '(double) => void') {
    example = "(value) {}";
  }

  return example;
}
