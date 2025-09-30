# nameof_gen

[![Pub Package](https://img.shields.io/pub/v/nameof_gen.svg)](https://pub.dev/packages/nameof_gen)

A modern Dart code generator for accessing class member names at compile time. This package provides a refactor-safe way to reference field names, method names, property names, and constructor names as string constants, eliminating magic strings from your code.

## Features

**Compile-time name generation** - No runtime reflection, all names are available as constants  
**Refactor-safe** - IDE renames automatically update generated constants  
**Modern analyzer support** - Compatible with the latest Dart analyzer (8.x+)  
**Flexible configuration** - Control which members are included/excluded  
**Custom name overrides** - Use annotations to provide custom names  
**Full backward compatibility** - Smooth migration from the original nameof package  

## Installation

Add `nameof_gen` to your `pubspec.yaml`:

```yaml
dependencies:
  nameof_annotation: ^0.2.1
  
dev_dependencies:
  nameof_gen: ^0.4.0
  build_runner: >=2.4.0
```

Then run:

```bash
dart pub get
```

## Quick Start

1. **Annotate your class:**

```dart
import 'package:nameof_annotation/nameof_annotation.dart';

part 'user.nameof.dart';

@nameof
class User {
  final String name;
  final int age;
  
  String get displayName => name;
  
  User(this.name, this.age);
  
  void save() {
    // implementation
  }
}
```

2. **Run code generation:**

```bash
dart run build_runner build
```

3. **Use the generated constants:**

```dart
print(NameofUser.fieldName);           // 'name'
print(NameofUser.fieldAge);            // 'age'
print(NameofUser.propertyGetDisplayName); // 'displayName'
print(NameofUser.constructor);          // ''
print(NameofUser.functionSave);         // 'save'
```

## Advanced Usage

### Coverage Control

Control which class members are included:

```dart
// Include all members (default)
@Nameof(coverage: Coverage.includeImplicit)
class MyClass { /* ... */ }

// Only include explicitly marked members
@Nameof(coverage: Coverage.excludeImplicit)
class MyClass {
  @NameofKey()
  String markedField = '';
  
  String unmarkedField = '';  // Won't be generated
}
```

### Custom Names

Override generated names with custom values:

```dart
@nameof
class Product {
  @NameofKey(name: 'productId')
  final String id;
  
  @NameofKey(name: 'price')
  String get cost => '\$\${_cost}';
}

// Generated:
// static const String fieldId = 'productId';
// static const String propertyGetCost = 'price';
```

### Ignore Members

Exclude specific members from generation:

```dart
@nameof
class ApiResponse {
  final String data;
  
  @nameofIgnore
  final String debugInfo;  // Won't be generated
}
```

## Migration from `nameof`

This package is a drop-in replacement for the original `nameof` package with modern analyzer support:

1. **Replace dependencies:**
   ```yaml
   dependencies:
     nameof_annotation: ^0.2.1    # Keep (unchanged)
   
   dev_dependencies:
     # nameof: ^0.2.0             # Remove
     nameof_gen: ^0.3.0           # Add (generator only)
     build_runner: >=2.4.0        # Compatible with reflectable
   ```

2. **No import changes needed:**
   ```dart
   // UNCHANGED - continue using:
   import 'package:nameof_annotation/nameof_annotation.dart';
   ```

3. **Clean migration:**
   
   All generated constants use the same names as the updated original package.

## Generated Code Format

For a class annotated with `@nameof`, the generator creates:

```dart
abstract class NameofMyClass {
  static const String className = 'MyClass';
  
  // Constructors
  static const String constructor = '';           // Default constructor
  static const String constructorNamed = 'named'; // Named constructors
  
  // Fields
  static const String fieldMyField = 'myField';
  
  // Properties (getters/setters)
  static const String propertyGetMyProp = 'myProp';
  static const String propertySetMyProp = 'myProp';
  
  // Methods
  static const String functionMyMethod = 'myMethod';
}
```

## Build Configuration

The generator can be configured in `build.yaml`:

```yaml
targets:
  $default:
    builders:
      nameof_gen:
        enabled: true
        generate_for:
          exclude:
            - test/**
          include:
            - lib/**
```

## Requirements

- Dart SDK: >=2.16.0 <4.0.0
- Dart analyzer: >=8.1.1 <9.0.0
- build: ^4.0.0
- source_gen: ^4.0.0
- build_runner: >=2.4.0 <3.0.0

## Compatibility

This package uses modern build dependencies and requires:

- **analyzer 8.1.1+**: Requires packages compatible with analyzer 8.x-9.x
- **build 4.x**: Uses the latest build system APIs
- **source_gen 4.x**: Modern source generation support

**Note:** This version requires analyzer 8.1.1+ and is not compatible with older packages that depend on analyzer 7.x or earlier (such as older versions of reflectable). Ensure your other code generation dependencies support analyzer 8.x+ before upgrading.

## Attribution

This package is a community-maintained fork of the original [`nameof`](https://github.com/flankb/nameof) package by [flankb](https://github.com/flankb), updated for modern Dart compatibility.

### Original Package Credits

- **Original Author**: [flankb](https://github.com/flankb)
- **Original Repository**: [github.com/flankb/nameof](https://github.com/flankb/nameof)
- **Original Package**: [nameof](https://pub.dev/packages/nameof) and [nameof_annotation](https://pub.dev/packages/nameof_annotation)

### Why This Fork?

The original `nameof` package is no longer actively maintained and has compatibility issues with modern Dart analyzer versions (8.x+). This fork:

- **Maintains the original API** - Zero breaking changes for existing users
- **Updates dependencies** - Compatible with latest Dart analyzer and build system
- **Fixes critical bugs** - Resolves issues with annotation detection and code generation
- **Maintains clean architecture** - Uses original annotation package, focuses on generator improvements
- 
We're grateful to the original author for creating this useful package and making it available to the Dart community. This fork aims to continue that legacy with modern compatibility and active maintenance.

## Development

### Setting up the development environment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/erwint/nameof_gen.git
   cd nameof_gen
   ```

2. **Install dependencies:**
   ```bash
   dart pub get
   ```

3. **Run code generation for examples:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Testing

The package includes comprehensive tests to ensure reliability:

1. **Run unit tests:**
   ```bash
   dart test
   ```

2. **Run source generation tests:**
   ```bash
   dart test test/source_gen_test.dart
   ```

3. **Test with the example project:**
   ```bash
   cd example
   dart pub get
   dart run build_runner build
   dart run bin/main.dart
   ```

### Modifying the generator

The core generator logic is in `lib/src/`:

- **`generator.dart`** - Main entry point, handles annotation processing
- **`visitor.dart`** - AST visitor that collects class member information  
- **`code_processor.dart`** - Generates the output Dart code
- **`util/element_extensions.dart`** - Helper methods for annotation detection

#### Adding new features:

1. Modify the visitor to collect new information
2. Update the code processor to generate appropriate code
3. Add tests in `test/source_gen_src.dart` with `@ShouldGenerate` expectations
4. Run tests to verify the output matches expectations

#### Debugging generation issues:

1. Use `dart run build_runner build -v` for verbose output
2. Check generated `.nameof.dart` files for debugging
3. Add debug prints to the generator code if needed
4. Use the example project for quick iteration

### Architecture

The package follows a clean architecture:

```
lib/
├── nameof_gen.dart          # Main library export
└── src/
    ├── builder.dart         # Build system integration
    ├── generator.dart       # Core generator logic
    ├── visitor.dart         # AST traversal and data collection
    ├── code_processor.dart  # Code generation
    ├── model/              # Data models
    │   ├── element_info.dart
    │   ├── property_info.dart
    │   └── options.dart
    └── util/               # Utilities
        ├── element_extensions.dart
        ├── enum_extensions.dart  
        └── string_extensions.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development workflow:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests as needed
5. Run `dart test` to ensure all tests pass
6. Run `dart analyze` to check for any issues
7. Submit a pull request

If you're the original author and would like to collaborate or discuss this fork, please don't hesitate to reach out.

## License

MIT License - see LICENSE file for details.

This project maintains the same license as the original `nameof` package to respect the original author's licensing choice.

## Package Architecture

The package follows a clean architecture with proper separation of concerns:

### Core Components

- **NameofGenerator** (`lib/src/generator.dart`) - Main generator class that extends `GeneratorForAnnotation<Nameof>`
- **NameofVisitor** (`lib/src/visitor.dart`) - AST visitor that collects class member information  
- **NameofCodeProcessor** (`lib/src/code_processor.dart`) - Processes collected data and generates final code

### Dependencies

- **Runtime dependencies**: Uses external `nameof_annotation` package for annotations
- **Build dependencies**: Uses modern `analyzer` (8.x+), `source_gen`, and `build` packages
- **Clean separation**: Build-time and runtime dependencies are properly separated

### Build System

- Uses `build_runner` for code generation
- Configuration in `build.yaml`
- Generates `.nameof.dart` part files containing name constants
- Auto-applies to dependents via `auto_apply: dependents` in build configuration

### Code Generation Details

- The generator creates part files, so classes using `@Nameof` must include the corresponding `.nameof.dart` part file
- Uses Dart's analyzer package (8.x+) for AST processing with `RecursiveElementVisitor2`
- Generates backward compatibility aliases (`constructorNew`) for smooth migration
- Maintains full API compatibility with original `nameof` package

## Changelog

### 0.3.0 - 2024-09-14

**Initial release** - Community-maintained fork of the original `nameof` package with modern Dart compatibility.

** Added:**
- Modern Dart analyzer support (8.x+) with full compatibility
- Backward compatibility aliases (`constructorNew`) with deprecation warnings
- Comprehensive documentation and migration guide

** Fixed:**
- Compilation issues with analyzer 8.x+ (visitor API changes)
- Constructor name generation (now properly generates `constructor = ''`)
- Annotation detection with new analyzer metadata API

** Breaking Changes:**
- Package name changed from `nameof` to `nameof_gen`
- Requires `nameof_annotation: ^0.2.1` as runtime dependency

** Migration:** See [Migration from `nameof`](#migration-from-nameof) section above.

---

**Note:** This is a community-maintained fork of the original [`nameof`](https://github.com/flankb/nameof) package by [flankb](https://github.com/flankb), updated for modern Dart compatibility. All credit for the original concept and implementation goes to the original author.
