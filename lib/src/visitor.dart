import 'package:analyzer/dart/element/visitor2.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:nameof_annotation/nameof_annotation.dart';

import 'model/element_info.dart';
import 'model/property_info.dart';
import 'util/element_extensions.dart';
import 'util/string_extensions.dart';

/// Class for collect info about inner elements of class (or mixin)
class NameofVisitor extends RecursiveElementVisitor2<void> {
  late String className;

  final constructors = <String, ElementInfo>{};
  final fields = <String, ElementInfo>{};
  final functions = <String, ElementInfo>{};
  final properties = <String, PropertyInfo>{};

  NameofVisitor(this.className);

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementName = element.name ?? 'new';

    // In analyzer 8.2+, the name of unnamed constructors is 'new'
    // For backward compatibility, we treat 'new' as the unnamed constructor
    final isDefaultConstructor = elementName == 'new' || elementName.isEmpty;

    // For backward compatibility:
    // - Use 'constructor' as the property name for default constructors
    // - Use empty string as the property value for default constructors
    final constructorKey = isDefaultConstructor ? 'constructor' : 'constructor${elementName.substring(0,1).toUpperCase()}${elementName.substring(1)}';

    final constructorInfo = ElementInfo(
      name: isDefaultConstructor ? '' : elementName,
      originalName: isDefaultConstructor ? '' : elementName,
      isPrivate: !isDefaultConstructor && elementName.startsWith('_'),
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

    final name = element.name;
    if (name != null) {
      fields[name] = _getFieldInfo(element);
    }
  }

  @override
  void visitPropertyAccessorElement(PropertyAccessorElement element) {
    _handlePropertyAccessor(element);
  }

  @override
  void visitGetterElement(GetterElement element) {
    _handlePropertyAccessor(element);
  }

  @override
  void visitSetterElement(SetterElement element) {
    _handlePropertyAccessor(element);
  }

  void _handlePropertyAccessor(PropertyAccessorElement element) {
    if (element.isSynthetic) {
      return;
    }

    final name = element.name;
    if (name != null) {
      properties[name] = PropertyInfo.fromElementInfo(
          _getPropertyInfo(element),
          isGetter: element.kind == ElementKind.GETTER,
          isSetter: element.kind == ElementKind.SETTER);
    }
  }

  @override
  void visitMethodElement(MethodElement element) {
    final name = element.name;
    if (name != null) {
      functions[name] = _getElementInfo(element);
    }
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
    if (elementName == null || elementName.isEmpty) {
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
