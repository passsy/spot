import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:macros/macros.dart';

macro class WidgetSelectorAndMatcherMacro implements ClassDeclarationsMacro {
  const WidgetSelectorAndMatcherMacro();

  @override
  Future<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final className = clazz.identifier.name;
    final fields = await builder.fieldsOf(clazz);

    builder.declareInLibrary(DeclarationCode.fromParts([
      "import 'package:spot/spot.dart';\n",
    ]));

    _buildWidgetMatcher(className, fields, builder);
    builder.declareInLibrary(DeclarationCode.fromString('\n'));
    _buildWidgetSelector(className, fields, builder);
  }

  void _buildWidgetMatcher(String className, List<FieldDeclaration> fields, MemberDeclarationBuilder builder) {
    builder.declareInLibrary(DeclarationCode.fromParts([
      'extension ${className}Matcher on WidgetMatcher<$className> {',
    ]));

    for (final field in fields) {
      final fieldName = field.identifier.name;
      if (field.type is NamedTypeAnnotation || field.type is FunctionTypeAnnotation) {
        final fieldType = _fieldType(field.type);
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
        final fieldType = _fieldType(field.type);
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

  String _fieldType(TypeAnnotation annotation ){
if(annotation is NamedTypeAnnotation) {
  return annotation.identifier.name;
} else if(annotation is FunctionTypeAnnotation) {
  return 'void Function()';
} else {
  return 'dynamic';
}
  }
}
