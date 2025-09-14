import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:nameof_annotation/nameof_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'code_processor.dart';
import 'util/enum_extensions.dart';
import 'model/options.dart';
import 'visitor.dart';

class NameofGenerator extends GeneratorForAnnotation<Nameof> {
  final Map<String, dynamic> config;

  NameofGenerator(this.config);

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS && element.kind.name != 'MIXIN') {
      throw UnsupportedError("This is not a class (or mixin)!");
    }

    final options = _parseConfig(annotation);

    final visitor = NameofVisitor(element.name ??
        () {
          throw UnsupportedError(
              'Class or mixin element does not have a name!');
        }());
    element.visitChildren(visitor);

    final code = NameofCodeProcessor(options, visitor).process();

    return code;
  }

  NameofOptions _parseConfig(ConstantReader annotation) {
    final coverageConfigString = config['coverage']?.toString();

    bool covTest(Coverage coverage) =>
        coverageConfigString == coverage.toShortString();

    final coverageConfig = Coverage.values.any(covTest)
        ? Coverage.values.firstWhere(covTest)
        : null;

    final coverageAnnotation = enumValueForDartObject(
      annotation.read('coverage'),
      Coverage.values,
    );

    return NameofOptions(
        coverage:
            coverageAnnotation ?? coverageConfig ?? Coverage.includeImplicit,
        scope: NameofScope.onlyPublic);
  }

  T? enumValueForDartObject<T>(
    ConstantReader reader,
    List<T> items,
  ) {
    return reader.isNull
        ? null
        : items[reader.objectValue.getField('index')!.toIntValue()!];
  }
}
