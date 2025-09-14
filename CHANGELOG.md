# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2025-09-14

- Initial release of `nameof_gen` package

### Added
- Modern Dart analyzer support (7.7.0 - 8.1.x) with full compatibility
- Uses original `nameof_annotation` package for clean dependency separation
- Full backward compatibility with original `nameof` package
- Comprehensive documentation and migration guide
- Improved error handling and performance
- Flexible dependency constraints for compatibility with reflectable and other packages
- Support for all original features:
  - Class member name generation (fields, properties, methods, constructors)
  - Custom name overrides with `@NameofKey(name: 'customName')`
  - Member exclusion with `@nameofIgnore`
  - Coverage control with `Coverage.includeImplicit` / `Coverage.excludeImplicit`

### Changed
- **Breaking**: Package name changed from `nameof` to `nameof_gen`
- Import path remains `package:nameof_annotation/nameof_annotation.dart` (no change needed)
- Updated minimum Dart SDK to 2.16.0 for modern null-safety support
- Upgraded all dependencies to latest versions for security and performance

### Fixed
- Fixed compilation issues with analyzer 8.x+ (visitor API changes)
- Fixed annotation detection with new analyzer metadata API
- Fixed constructor name generation (now properly generates `constructor = ''` for default constructors)
- Fixed property vs field handling with `@NameofKey` annotations
- Fixed `@nameofIgnore` annotation not properly excluding members

### Migration from `nameof`

This package is designed as a drop-in replacement for the original `nameof` package:

#### 1. Update pubspec.yaml:
```yaml
# REMOVE:
dev_dependencies:
  nameof: ^0.2.0

# ADD:
dependencies:
  nameof_annotation: ^0.2.1  # Keep (unchanged)
dev_dependencies:
  nameof_gen: ^0.3.0         # Add (generator only)
  build_runner: >=2.4.0      # Compatible with reflectable
```

**Note**: This package uses conservative analyzer constraints (7.7.0 - 8.1.x) to ensure compatibility with reflectable and other popular packages that may not yet support analyzer 8.x+.

#### 2. No import changes needed:
```dart
// UNCHANGED - continue using:
import 'package:nameof_annotation/nameof_annotation.dart';
```

#### 3. Regenerate code:
```bash
dart run build_runner clean
dart run build_runner build
```

All generated constants remain the same, ensuring zero code changes in your application logic.

---

**Attribution:** This is a community-maintained fork of the original [`nameof`](https://github.com/flankb/nameof) package by [flankb](https://github.com/flankb). All credit for the original concept and implementation goes to the original author. This fork was created to provide modern Dart compatibility and continued maintenance for the community.

## Historical Changelog (from original nameof package)

## 0.2.2

- Expand SDK version to '>=2.16.0 <4.0.0'

## 0.2.1

- Restore fixes

## 0.2.0

- Bump SDK version to 3.0.0, and update analyzer

## 0.1.4
- Fix nameof ignore for props

## 0.1.3
- Fix generate setter's name with wrong '=' char

## 0.1.2

- Fix analyzer version

## 0.1.1

- Update description

## 0.1.0

- Initial version.
