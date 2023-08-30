# Changelog

## 0.4.1
- Added screenshot methods #14
  ```dart
  /// Takes a screenshot of the entire window
  await takeScreenshot();
  
  /// Takes a screenshot of a single Screen/Widget
  final homePage = spotSingle<HomePage>();
  await takeScreenshot(selector: homePage);
  
  /// Use it as extension
  await spotSingle<HomePage>().takeScreenshot();
  ```
- Export all types from `checks.dart` which are required to use `hasProp`
- Update for Flutter 3.13

## 0.4.0
- Added `act.tap(button)` to tap widgets #9
- Raise min Flutter version to 3.10.0
- Switch to the official [`checks`](https://pub.dev/packages/checks) package #12
- Rename `SingleWidgetSnapshot.discoveredElements` -> `SingleWidgetSnapshot.discoveredElement` #11

## 0.3.2
- Export all types from `checks.dart` which are required to use `hasProp` 

## 0.3.1
- Fix compilation error with Flutter 3.0.0

## 0.3.0
- `spotTexts` now matches `EditableText` and `SelectableText` #5
- `spotTexts` now has generic type `<W>` instead of static `Text`. This changes the return type from  `MultiWidgetSelector<Text>` -> `MultiWidgetSelector<W>` #5
- Changed signature of `SingleWidgetSelector.withProp` and `MultiWidgetSelector.withProp`.
- New matchers for `EditableText`, `ListTile`, `SelectableText` 

## 0.2.2
- Support for Flutter 3.0.0 / Dart 2.17

## 0.2.1

- Fix `WidgetSelector` with parents that have parents #4
- Require all children selector to match, not just one #4

## 0.2.0

- Reworked spot API #3
- Allow defining `WidgetSelector` with children
- Allow defining `WidgetSelector` with parents
- Interop with `Finder` API
- Match properties of widgets (via `DiagnosticsNode`)
- Allow matching of nested properties (with checks API)
- Generate code for custom properties for Flutter widgets
- Allow generating code for properties of 3rd party widgets

## 0.1.0-preview.2

- Update package description
- Add issue_tracker link
- Add example folder

## 0.1.0-preview.1

- Extraction from [wiredash](https://github.com/wiredashio/wiredash-sdk) repository