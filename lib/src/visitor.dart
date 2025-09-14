import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:nameof_annotation/nameof_annotation.dart';

import 'model/element_info.dart';
import 'model/property_info.dart';
import 'util/element_extensions.dart';
import 'util/string_extensions.dart';

/// Class for collect info about inner elements of class (or mixin)
class NameofVisitor extends RecursiveElementVisitor<void> {
  late String className;

  final constructors = <String, ElementInfo>{};
  final fields = <String, ElementInfo>{};
  final functions = <String, ElementInfo>{};
  final properties = <String, PropertyInfo>{};

  NameofVisitor(this.className);

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementName = element.name;
    
    // In the new analyzer, default constructors may be named 'new' instead of null/empty
    // We need to detect default constructors differently
    final isDefaultConstructor = elementName.isEmpty;
    
    // For backward compatibility: 
    // - Use 'constructor' as the property name for default constructors
    // - Use empty string as the property value for default constructors
    final constructorKey = isDefaultConstructor ? 'constructor' : 'constructor${elementName.substring(0,1).toUpperCase()}${elementName.substring(1)}';
    
    final constructorInfo = ElementInfo(
      name: isDefaultConstructor ? '' : elementName,
      originalName: isDefaultConstructor ? '' : elementName,
      isPrivate: elementName.startsWith('_'),
      isAnnotated: element.hasAnnotation(NameofKey),
      isIgnore: element.hasAnnotation(NameofIgnore)
    );
    
    constructors[constructorKey] = constructorInfo;
  }

  @override
  void visitFieldElement(FieldElement element) {
    if (element.isSynthetic) {
      return;
    }

    fields[element.name] = _getFieldInfo(element);
  }

  @override
  void visitPropertyAccessorElement(PropertyAccessorElement element) {
    if (element.isSynthetic) {
      return;
    }

    properties[element.name] = PropertyInfo.fromElementInfo(
        _getPropertyInfo(element),
        isGetter: element.isGetter,
        isSetter: element.isSetter);
  }


  @override
  void visitMethodElement(MethodElement element) {
    functions[element.name] = _getElementInfo(element);
  }

  ElementInfo _getElementInfo(Element element) {
    if (element.name == null) {
      throw UnsupportedError('Element does not have a name!');
    }

    final elementName = element.name!;
    final isPrivate = elementName.startsWith('_');
    final isAnnotated = element.hasAnnotation(NameofKey);
    final isIgnore = element.hasAnnotation(NameofIgnore);

    // Get the custom name from @NameofKey annotation if present
    String? customName = isAnnotated
        ? element.getAnnotation(NameofKey)?.getField('name')?.toStringValue()
        : null;

    // For the property value, use custom name if available, otherwise use original name
    String name = (customName ?? elementName).cleanFromServiceSymbols();

    // For the property name, always use the original element name
    String originalName = elementName.cleanFromServiceSymbols();

    return ElementInfo(
        name: name,
        originalName: originalName,
        isPrivate: isPrivate,
        isAnnotated: isAnnotated,
        isIgnore: isIgnore);
  }

  // For fields: property name uses original name, property value uses custom name
  ElementInfo _getFieldInfo(Element element) {
    if (element.name == null) {
      throw UnsupportedError('Element does not have a name!');
    }

    final elementName = element.name!;
    final isPrivate = elementName.startsWith('_');
    final isAnnotated = element.hasAnnotation(NameofKey);
    final isIgnore = element.hasAnnotation(NameofIgnore);

    // Get the custom name from @NameofKey annotation if present
    String? customName = isAnnotated
        ? element.getAnnotation(NameofKey)?.getField('name')?.toStringValue()
        : null;

    // For fields: value uses custom name, property name uses original name
    String name = (customName ?? elementName).cleanFromServiceSymbols();
    String originalName = elementName.cleanFromServiceSymbols(); // Always original for property name

    return ElementInfo(
        name: name,
        originalName: originalName,
        isPrivate: isPrivate,
        isAnnotated: isAnnotated,
        isIgnore: isIgnore);
  }

  // For properties: both property name and value use custom name
  ElementInfo _getPropertyInfo(PropertyAccessorElement element) {
    final elementName = element.name;
    if (elementName.isEmpty) {
      throw UnsupportedError('Element does not have a name!');
    }

    final isPrivate = elementName.startsWith('_');
    final isAnnotated = element.hasAnnotation(NameofKey);
    final isIgnore = element.hasAnnotation(NameofIgnore);

    // Get the custom name from @NameofKey annotation if present
    String? customName = isAnnotated
        ? element.getAnnotation(NameofKey)?.getField('name')?.toStringValue()
        : null;

    // For properties: both name and originalName use custom name if available
    String name = (customName ?? elementName).cleanFromServiceSymbols();
    String originalName = (customName ?? elementName).cleanFromServiceSymbols();

    return ElementInfo(
        name: name,
        originalName: originalName,
        isPrivate: isPrivate,
        isAnnotated: isAnnotated,
        isIgnore: isIgnore);
  }
}
