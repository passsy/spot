# Changelog

## 0.10.0-beta.3

This release contains breaking changes to the "internal" `WidgetSelector` API.
Unless you are using the `WidgetSelector` directly, you should not be affected by this.

The end-user `spot` API is not affected.

- **Breaking** `WidgetSelector` now has `List<ElementFilter> stages`, replacing the previous `props`, `parents`, `children` and `elementFilters`.
- **Breaking** `WidgetSelector` constructor and `copyWith` signature changed, reflecting the new properties. `createElementFilters()`, `createCandidateGenerator()` and `toStringWithoutParents()` have been removed.
- **Breaking** `PropFilter` has been renamed to `PredicateFilter`
- **Breaking** `PredicateWithDescription` has been removed
- **Breaking** `CandidateGenerator` has been removed
- `WidgetSelector.toString()` has been improved, has now separators for stages and adds braces. Example: `Center with child SizedBox ❯ with parent (Scaffold ᗕ Row)`
- Fix `.atIndex(n)` to be executed at the right time, not after all other filters.


## 0.10.0-beta.2

- New `getDiagnosticProp<T>('name')` for easy access to the values of a diagnostic property #40
- New `hasEffectiveTextStyle`, `withEffectiveTextStyleMatching()`, `withEffectiveTextStyle()` #36, #38
- Tons of documentation and examples #37, #39
- Restructure of internal files


## 0.10.0-beta.1

Eventually **Breaking**, but only the class names. The end user API stays the same.

- `spotSingle<W>()` is now deprecated. Use `spot<W>()` instead, or `spot<W>().atMost(1)` to indicate that only a single widget is expected.
- `WidgetSelector` replaces `SingleWidgetSelector` and `MultiWidgetSelector`
- `WidgetSelector` now has a `quantityConstraint` property (deprecates `expectedQuantity`) that allows setting the `min` and `max` number of expected widgets.
- New: `.atIndex(n)` allows to get the widget at a specific index (when multiple are found)
- Fix: `.first()` and `.last()` now work after calling `.copyWith()`
- **Breaking** Quantity assertions like `.doesNotExist()` or `.existsOnce()` now return `WidgetMatcher`/`MultiWidgetMatcher` instead of `WidgetSnapshot`. To get the `WidgetSnapshot` use `snapshot()` instead.
- `spotText('a')` can now return multiple widgets
- **Breaking** remove `WidgetSelector.cast` because it lost information and was untested


## 0.7.0

- New prop API with `hasWidgetProp()` makes it easy to filter and assert properties of Widgets.
  This replaces the old `hasProp()` method which was based on way to complicated package:checks context. 
  ```dart
  // Old ⛈️
  spotSingle<Checkbox>().existsOnce().hasProp(
      selector: (e) => e.context.nest(
        () => ['Checkbox', 'value'],
        (e) => Extracted.value((e.widget as Checkbox).value),
      ),
      match: (it) => it.equals(true),
    );
  ```
  ```dart
  // New ✨
  spotSingle<Checkbox>().existsOnce().hasWidgetProp(
      prop: widgetProp('value', (widget) => widget.value),
      match: (value) => value.isTrue(),
    );
  ```

  The prop API is also available for `Element` and `RenderObject`. 
  <summary>
    <details>
  
  ```
  ├── Interface "NamedWidgetProp" added 
  ├── Interface "NamedElementProp" added 
  ├── Interface "NamedRenderObjectProp" added 
  ├── Function "widgetProp" added 
  ├── Function "elementProp" added 
  ├── Function "renderObjectProp" added 
  ├─┬ Class SelectorQueries
  │ ├── Method "whereWidgetProp" added 
  │ ├── Method "whereElementProp" added 
  │ └── Method "whereRenderObjectProp" added 
  └─┬ Class WidgetMatcherExtensions
  ├── Method "getWidgetProp" added 
  ├── Method "hasWidgetProp" added 
  ├── Method "getElementProp" added 
  ├── Method "hasElementProp" added 
  ├── Method "getRenderObjectProp" added 
  └── Method "hasRenderObjectProp" added 
  ```
    </details>
  </summary>
  
- Never miss asserting your `WidgetSelector`.
  All methods returning a `WidgetSelector` are now annotated with `@useResult`.
  This will cause a lint warning when you only define a `WidgetSelector` without asserting it.
  ```dart
  spot<FloatingActionButton>().withChild(spotIcon(Icons.add)); // warning, no assertion
  
  final plusFab = spot<FloatingActionButton>().withChild(spotIcon(Icons.add)); // ok, assigned
  spot<FloatingActionButton>().withChild(spotIcon(Icons.add)).existsOnce(); // ok, asserted
  ```
  
- It is now easy to directly access the Widget of a `SingleWidgetSelector` with `snapshotWidget()`. 
  It also works for the associated `Element` and `RenderObject`. Use `snapshotElement()` and `snapshotRenderObject()`.

  ```diff
  -final checkbox = spotSingle<Checkbox>().snapshot().widget;
  +final checkbox = spotSingle<Checkbox>().snapshotWidget();
  print(checkbox.checkColor);
  ```

## 0.6.0
- Add matchers `.existsAtMostOnce()` and `.existsAtMostNTimes(x)` #19
- Add selector `.withParent(parent)`/`.withParents([...])` #21
- Add selector `.withChild(child)`/`.withChildren([...])` #21
- Child selectors now only match children #22
- You can call `act.tap()` now with any `WidgetSelector` that returns a single widget #23

## 0.5.0
- **Breaking** `act.tap` is now async, use `await act.tap()` #17
- New: `spotText('foo')` finds any text on screen using "contains". The new `AnyText` widget combines `Text`, `SelectableText`, `RichText` and `EditableText` #18
- New: `spotTextWhere((text) => )` allows to match text with custom logic #18
- Deprecated: `spotSingleText` and `spotTexts` are deprecated in favor of `spotText` and the basic `spot<Text>()`, `spot<SelectableText>()`, ... #18
- Fix: `hasProp` matcher can now check for null values with `(it) => it.isNull()` #18
- Improvement: `withDiagnosticProp` now falls back to the default value of a `DiagnosticNode` #18

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