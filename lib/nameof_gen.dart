/// Modern Dart code generator for the nameof_annotation package.
///
/// Provides compile-time access to class member names with analyzer 8.x+ support.
library nameof_gen;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

/// Builds generators for `build_runner` to run
Builder nameof(BuilderOptions options) {
  return PartBuilder(
    [NameofGenerator(options.config)],
    '.nameof.dart',
    options: options,
  );
}
