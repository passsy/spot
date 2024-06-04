import 'dart:async';
import 'dart:io';
import 'package:dartx/dartx.dart';
import 'package:macros/macros.dart';

macro class WidgetSelectorAndMatcherMacro implements ClassDeclarationsMacro{
  const WidgetSelectorAndMatcherMacro();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final className = clazz.identifier.name;
    final fields = await builder.fieldsOf(clazz);

    // Find better way to boil down
    final allImports = _readImports(clazz.library.uri.path);

    builder.declareInLibrary(DeclarationCode.fromParts([
      '''import 'package:spot/spot.dart';
$allImports\n
    '''
    ]));
    _buildWidgetMatcher(className, fields, builder);
    builder.declareInLibrary(DeclarationCode.fromString('\n'));
    _buildWidgetSelector(className, fields, builder);
  }

  Future<void> _buildWidgetMatcher(String className, List<FieldDeclaration> fields, MemberDeclarationBuilder builder) async {

    builder.declareInLibrary(DeclarationCode.fromParts([
      'extension ${className}Matcher on WidgetMatcher<$className> {',
    ]));

    for (final FieldDeclaration field in fields) {
      final fieldName = field.identifier.name;
      if (field.type is NamedTypeAnnotation || field.type is FunctionTypeAnnotation) {
        final fieldType = _fieldType(field);
        builder.declareInLibrary(
          DeclarationCode.fromString('''
          WidgetMatcher<$className> has${fieldName.capitalize()}({required $fieldType $fieldName}) {             
              return hasWidgetProp(
                prop: widgetProp('$fieldName', ($className widget) => widget.$fieldName),
                match: (it) => it.equals($fieldName),
              );
            }''',
          ),
        );
      }
    }

    builder.declareInLibrary(DeclarationCode.fromParts([
      '}',
    ]));
  }

  void _buildWidgetSelector(String className, List<FieldDeclaration> fields, MemberDeclarationBuilder builder) {
    builder.declareInLibrary(DeclarationCode.fromParts([
      'extension ${className}Selector on WidgetSelector<$className> {',
    ]));

    for (final field in fields) {
      final fieldName = field.identifier.name;
      if (field.type is NamedTypeAnnotation || field.type is FunctionTypeAnnotation) {
        final fieldType = _fieldType(field);
        builder.declareInLibrary(
          DeclarationCode.fromString('''
            WidgetSelector<$className> where${fieldName.capitalize()}({required $fieldType $fieldName}) {
              return whereWidgetProp(
                widgetProp('$fieldName', ($className widget) => widget.$fieldName),
                ($fieldType value) => value == $fieldName,
              );
            }''',
          ),
        );
      }
    }

    builder.declareInLibrary(DeclarationCode.fromParts([
      '}',
    ]));
  }

  String _fieldType(FieldDeclaration declaration) {
    StringBuffer buffer = StringBuffer();
    final declarationType = declaration.type;

    if (declarationType is NamedTypeAnnotation) {
      buffer.writeln(declarationType.identifier.name);
    } else if (declarationType is FunctionTypeAnnotation) {
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
    final nameString = param.name != null ? ' ${param.name}' : '';
    return '$typeString$nameString';
  }

  String _readImports(String filePath) {
    final file = File(filePath);
    final lines = file.readAsLinesSync();
    final importLines = lines.where((line) => line.trim().startsWith('import')).join('\n');

    return importLines;
  }
}
