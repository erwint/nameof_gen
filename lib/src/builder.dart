/// Builder configuration for nameof_gen package
library nameof_gen.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Builds generators for `build_runner` to run
Builder nameofGen(BuilderOptions options) {
  return PartBuilder(
    [NameofGenerator(options.config)],
    '.nameof.dart',
    options: options,
  );
}