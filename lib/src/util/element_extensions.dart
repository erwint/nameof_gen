import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension AnnotationChecker on Element {
  bool hasAnnotation(final Type type) {
    // Use source_gen's TypeChecker for more reliable annotation detection
    return _createTypeChecker(type).hasAnnotationOfExact(this);
  }

  DartObject? getAnnotation(final Type type) {
    // Use source_gen's TypeChecker for more reliable annotation detection
    return _createTypeChecker(type).firstAnnotationOfExact(this);
  }
}

TypeChecker _createTypeChecker(Type type) {
  final typeName = type.toString();
  
  // Create TypeChecker from package URL - this is more reliable than runtime type
  switch (typeName) {
    case 'NameofKey':
      return TypeChecker.fromUrl('package:nameof_annotation/nameof_annotation.dart#NameofKey');
    case 'NameofIgnore':
      return TypeChecker.fromUrl('package:nameof_annotation/nameof_annotation.dart#NameofIgnore');
    case 'Nameof':
      return TypeChecker.fromUrl('package:nameof_annotation/nameof_annotation.dart#Nameof');
    default:
      // Fallback: use the URL approach with the type name
      return TypeChecker.fromUrl('package:nameof_annotation/nameof_annotation.dart#$typeName');
  }
}
