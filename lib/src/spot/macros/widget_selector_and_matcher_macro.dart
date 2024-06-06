import 'dart:async';
import 'dart:io';
import 'package:dartx/dartx.dart';
import 'package:macros/macros.dart';

/// A macro that generates extension methods for [WidgetSelector] and [WidgetMatcher] for a given widget class.
macro class WidgetSelectorAndMatcherMacro implements ClassDeclarationsMacro {
  const WidgetSelectorAndMatcherMacro();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final className = clazz.identifier.name;
    final fields = await builder.fieldsOf(clazz);
    // TODO decide whether to use for example values in documentation
    // final enums = await builder.typesOf(clazz.library).then((types) => types.whereType<EnumDeclaration>().toList());

    // Find better way to boil down
    final allImports = readImports(clazz.library.uri.path);

    builder.declareInLibrary(
      DeclarationCode.fromParts(['''
// ignore_for_file: unused_import
// ignore_for_file: duplicate_import
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/spot.dart';
$allImports'''
      ]),
    );
    _buildWidgetMatcher(className, fields, builder);
    builder.declareInLibrary(DeclarationCode.fromString(''));
    _buildWidgetSelector(className, fields, builder);
  }

  Future<void> _buildWidgetMatcher(String className, List<FieldDeclaration> fields, MemberDeclarationBuilder builder) async {
    builder.declareInLibrary(
      DeclarationCode.fromParts([
        'extension ${className}Matcher on WidgetMatcher<$className> {',
      ]),
    );

    for (final FieldDeclaration field in fields) {
      if (field.type is NamedTypeAnnotation || field.type is FunctionTypeAnnotation) {
        final fieldName = field.identifier.name;

        final String matcher = (){
          if(field.type.isNullable){
            return "$fieldName == null ? it.isNull() : it.equals($fieldName)";
          }
          return "it.equals($fieldName)";
        }();

        final fieldType = _fieldType(field);
        final matcherName = 'has${fieldName.capitalize()}';
        builder.declareInLibrary(
          DeclarationCode.fromString('''
  /// Expects that $fieldName of [$className] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<$className>().existsOnce().$matcherName($fieldType value);
  /// ```
  WidgetMatcher<$className> $matcherName($fieldType $fieldName) {             
    return hasWidgetProp(
      prop: widgetProp('$fieldName', ($className widget) => widget.$fieldName),
      match: (it) => $matcher,
    );
  }''',
          ),
        );
      }
    }

    builder.declareInLibrary(DeclarationCode.fromParts(['}']));
  }

  void _buildWidgetSelector(String className, List<FieldDeclaration> fields, MemberDeclarationBuilder builder) {
    builder.declareInLibrary(
        DeclarationCode.fromParts([
        'extension ${className}Selector on WidgetSelector<$className> {',
      ]),
    );

    for (final field in fields) {
      final fieldName = field.identifier.name;
      if (field.type is NamedTypeAnnotation || field.type is FunctionTypeAnnotation) {
        final fieldType = _fieldType(field);
        final selectorName = 'where${fieldName.capitalize()}';
        builder.declareInLibrary(
          DeclarationCode.fromString('''
  /// Creates a [WidgetSelector] that finds all [$className] where [$fieldName] equals (==) [value].
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<$className>().$selectorName($fieldType $fieldName).existsOnce();
  /// ```
  WidgetSelector<$className> $selectorName($fieldType $fieldName) {
    return whereWidgetProp(
      widgetProp('$fieldName', ($className widget) => widget.$fieldName),
      ($fieldType value) => value == $fieldName,
    );
  }''',
          ),
        );
      }
    }

    builder.declareInLibrary(DeclarationCode.fromParts(['}']));
  }

  String _fieldType(FieldDeclaration declaration) {
    final buffer = StringBuffer();
    final declarationType = declaration.type;

    switch(declarationType) {
      case NamedTypeAnnotation():
        final paramSuffix = declarationType.isNullable ? '?' : '';
        final name = '${declarationType.identifier.name}$paramSuffix';
        buffer.write(name);

      case FunctionTypeAnnotation():
        final returnType = declarationType.returnType;
        final returnTypeString = _typeAnnotationToString(returnType);
        final positionalParams = declarationType.positionalParameters;
        final namedParams = declarationType.namedParameters;

        buffer.write('$returnTypeString Function(');

        if (positionalParams.isNotEmpty) {
          buffer.write(positionalParams.map((param) => _parameterTypeString(param)).join(', '));
        }

        if (namedParams.isNotEmpty) {
          if (positionalParams.isNotEmpty) {
            buffer.write(', ');
          }
          buffer.write('{');
          // Check nullability of callback params
          buffer.write(namedParams.map((param) => _parameterTypeString(param)).join(', '));
          buffer.write('}');
        }

        buffer.write(')');

        if (declarationType.isNullable) {
          buffer.write('?');
        }
    }

    return buffer.toString();
  }

  String _typeAnnotationToString(TypeAnnotation typeAnnotation) {
    if (typeAnnotation is NamedTypeAnnotation) {
      return typeAnnotation.identifier.name;
    } else if (typeAnnotation is FunctionTypeAnnotation) {
      return _fieldType(typeAnnotation as FieldDeclaration);
    }
    return 'dynamic'; // Default case, if the type is not recognized
  }

  String _parameterTypeString(FormalParameter param) {
    final typeString = _typeAnnotationToString(param.type);
    return '$typeString value';
  }

  /// Reads the imports of the file where the annotated class lives
  static String readImports(String filePath) {
    final file = File(filePath);
    final lines = file.readAsLinesSync();

    // Find the first import statement
    final firstLine = lines.indexWhere((line) => line.startsWith('import'));
    if (firstLine == -1) {
      return '';
    }

    // Find the last import statement
    final lastLine = lines.lastIndexWhere((line) => line.startsWith('import'));

    // All lines, starting from the last import statement, until the first semicolon is found
    final rest = lines.sublist(lastLine);
    final endLine = rest.indexWhere((line) => line.contains(';'));

    final allImports = [];

    // Capture all lines between the first and last import statements
    allImports.addAll(lines.sublist(firstLine, lastLine));
    // Capture the lines from the last import to the semicolon
    allImports.addAll(rest.sublist(0, endLine + 1));

    // Combine the parts correctly
    return '${allImports.join('\n')}\n';
  }
}
