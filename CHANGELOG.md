# Changelog

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