# Spot

[![pub](https://img.shields.io/pub/v/spot?include_prereleases)](https://pub.dev/packages/spot)

<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">

Spot is a toolkit for Flutter widget tests.
It simplifies queries and assertions against the widget tree (better finder API called `spot`). 
And visualizes the timeline of a test as HTML report with automatic screenshots.

🖼️ Automatic screenshots during widget tests (Timeline)
⛓️ Chainable widget selectors
💙 Useful error messages (with full tree dump)
🌱 Works with plain `testWidgets()`
💫 Compatible with `integration_test`

## Usage

Replace your existing finders with `spot`. 

Once you interact with `spot` (or `act`), the information can be captures by the Timeline.

```diff
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existing Widget test', (tester) async {
     await tester.pumpWidget(MyApp());
  
-    await tester.tap(find.byType(ElevatedButton));
+    await act.tap(spot<ElevatedButton>());

-    expect(find.text('monde'), findsOneWidget);
+    spotText('monde').existsOnce();

     // Automatically generates a timeline report on error
  });
}
```

When your test fails, spot generates the Timeline HTML report with all assertions (`spot`) and gestures (`act`), automatic screenshots ond more information.

```
Generating timeline report
View time line here: file:///var/folders/0j/p0s0zrv91tgd33zrxb98c0440000gn/T/ecsTKx/existing-widget.html
```

You can open the local Timeline report in your browser.

![Timeline](https://github.com/user-attachments/assets/48a1a754-f56a-4c61-a4ef-b6e564ee1282)


## Manual Screenshots

Within your existing widget tests without spot, use `await takeScreenshot()` to see what is happening on the virtual screen.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Take screenshots', (tester) async {
    tester.pumpWidget(MyApp());
    
    // Take a screenshot of the entire screen
    await takeScreenshot();
    // console:
    // Screenshot file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/spot/screenshot_test:10-s83dv.png
    //   taken at main.<fn> file:///Users/pascalwelsch/Projects/passsy/spot/test/spot/screenshot_test.dart:10:10
    
    // Take a screenshot of a single widget
    await spot<AppBar>().takeScreenshot();
    // console:
    // Screenshot file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/spot/screenshot_test:16-w8UPv.png
    //   taken at main.<fn> file:///Users/pascalwelsch/Projects/passsy/spot/test/spot/screenshot_test.dart:16:24
  });
}
```

### Chain selectors

You know exactly where your widgets are.
Like a button in the AppBar or a Text in a Dialog.
Spot allows you to chain matchers, narrowing down the search space.

Chaining allows spot to create better error messages for you.
Spot follows the chain of your selectors and can tell you exactly where the widget is missing.
Like: `Could not find "IconButton" in "AppBar", but found these widgets instead: <AppBar-widget-tree>.`

```dart
spot<AppBar>().spot<IconButton>();
spot<IconButton>(parents: [spot<AppBar>()]);
```

Both syntax are identical. The first is shorter for when you only need a single parent.
The second allows checking for multiple parents, which is only required for rare use cases.

### Selectors

Spot has two features, creating **selectors** and asserting on them with **matchers**.

A selector is a query to find a set of widgets.
Like a SQL query, or a CSS selector.
It is only a description of what to search for, without actually doing the search.

Selectors can be rather complex, it is therefore recommended to **reuse** them.
You can even save them top-level and reuse them across multiple tests.

```dart
spot<ElevatedButton>();

final WidgetSelector<TextField> textFields = 
    spot<LoginScreen>().spot<LoginForm>().spot<TextField>();

final WidgetSelector<TextField> usernameTextField =
    spot<TextField>(
      parents: [
        spot<TextWithLabel>(
          children: [
            spotText('Username'),
          ],
        ),
      ],
    );
```

A `WidgetSelector` may return 0, 1 or N widgets.
Depending on how many widgets you expect to find, you should use the corresponding matchers.


### Better errors

By chaining widget selectors, spot can provide better errors by searching the parent scope first for potential candidates.

Here, the settings icon couldn't not be found in the `AppBar`.
Classic widget tests would show the following error using `findsOneWidget`.

```
expect(find.byIcon(Icons.settings), findsOneWidget);

>>> Expected: exactly one matching node in the widget tree
>>>   Actual: _WidgetIconFinder:<zero widgets with icon "IconData(U+0E57F)" (ignoring offstage widgets)>
>>>    Which: means none were found but one was expected
```

The error message above is not really helpful, because the actual error is not that there's no icon, but the `Icons.home` instead of `Icons.settings`.

The spot error message is much more helpful, showing two potential candidates in the `AppBar`.
```
Could not find AppBar ᗕ Icon Widget with icon: "IconData(U+0E57F)" in widget tree, expected exactly
1
A less specific search (Icon with parent AppBar) discovered 2 matches!

View time line here: file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/hDEgVS/timeline-narrow-down-search-down-the-tree.html
```

Spot was able to find two Icon Widgets in the AppBar (with the wrong icon). They are presented in the Timeline report, highlighted in the screenshot.

![Home Icon is the error](https://github.com/user-attachments/assets/9929d827-e8d0-4d01-aeeb-68eb6912d248)

#### Complex Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Widget test with spot', (tester) async {
    // Create widget selectors for elements in the widget tree
    final scaffold = spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();

    // Assert for values of widgets
    appBar.spotText('Dash').hasFontSize(14).hasFontColor(Colors.black87);

    // Find widgets based on child widgets
    appBar
        .spot<IconButton>(children: [spotIcon(Icons.home)])
        .existsOnce()
        .hasTooltip('home');

    // Find widgets based on multiple parent widgets
    spot<Icon>(parents: [appBar, spot<IconButton>()])
        .existsExactlyNTimes(2)
        .all((icon) {
      icon.hasColorWhere((color) => color.equals(Colors.black));
    });

    // Interact with widgets using `act`
    final button = spot<FloatingActionButton>();
    await act.tap(button);

    final text = spot<TextField>();
    await act.enterText(text, 'Hello World');
    
    // at the end of a failed test, spot will generate a Timeline HTML file
  });
}

```

### Matchers

After creating a selector, you want to assert the widgets it found.
The `snapshot()` method creates a `WidgetSnapshot` of the widget tree at that point in time and finds all widgets that match the selector.

#### Quantity matchers

The easiest matchers are the quantity matchers. They allow checking how many widgets were found.

- `existsOnce()` asserts that exactly one widget was found
- `doesNotExist()` asserts that no widget was found
- `existsExactlyNTimes(n)` asserts that exactly `n` widgets were found
- `existsAtLeastOnce()` asserts that at least one widget was found
- `existsAtMostOnce()` asserts that at most one widget was found

```dart

final selector = spot<ElevatedButton>();

// calls snapshot() internally
final matchOne = selector.existsOnce(); 
final matchMultiple = selector.existsExactlyNTimes(5);

selector.doesNotExist(); // end, nothing to match on 
```

#### Property matchers

The property matchers allow asserting on the properties of the widgets.
You don't have to use `execpt()`, instead you can use the `has*`/`is*` matchers directly.

```dart
spot<Tooltip>()
    .existsOnce() // takes snapshot and asserts quantity
    // start your chain of matchers
    .hasMessage('Favorite')
    .hasShowDurationWhere(
      (it) => it.isGreaterOrEqual(Duration(seconds: 1000)),
    )
    .hasTriggerMode(TooltipTriggerMode.longPress);
```

To match multiple widgets use `all()` or `any()`

```dart
spot<AppBar>().spot<Tooltip>().existsAtLeastOnce()
    .all((tooltip) => tooltip
      .hasShowDurationWhere((it) => it.isGreaterOrEqual(Duration(seconds: 1000)))
      .hasTriggerMode(TooltipTriggerMode.longPress)
    );
```

### Selectors vs Matchers

It is recommended to use matchers instead of selectors once you have narrowed down the search space to the widget you want to assert on.
This makes the error messages much clearer.
Instead of `widget not found` you'll get `Found ToolTip with message 'Settings' but expected 'Favorite'` as error message.

```dart
// DON'T
spot<Tooltip>()
    .withMessage('Favorite') // selector
    .withTriggerMode(TooltipTriggerMode.longPress) // selector
    .existsOnce();

// DO
spot<Tooltip>()
    .existsOnce()
    .hasMessage('Favorite') // matcher
    .hasTriggerMode(TooltipTriggerMode.longPress); // matcher
```

### Find offstage widgets

By default, `spot()` only finds widgets that are "onstage", not hidden with the [`Offstage`](https://api.flutter.dev/flutter/widgets/Offstage-class.html) widget.

To find offstage widgets, start your widget selector with `spotOffstage()`.
Search for both - the on- and offstage widgets - with `spotAllWidgets()`.

For existing selectors, use `overrideWidgetPresence(WidgetPresence presence)` to modify the presence to `offstage`, `onstage` or `combined`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Spot offstage and combined widgets', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Text('a'),
            Text('b'),
            Offstage(child: Text('c')),
          ],
        ),
      ),
    );
    
    spot<Text>().withText('a').existsOnce();
    spot<Text>().withText('c').doesNotExist();
    spot<Text>().withText('c').overrideWidgetPresence(WidgetPresence.offstage).existsOnce();
    
    spotOffstage().spot<Text>().atMost(3);
    spotOffstage().spotText('c').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.onstage).spotText('c').doesNotExist();
    
    spotAllWidgets().spotText('a').existsOnce();
    spotAllWidgets().spotText('c').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.combined).spotText('a').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.combined).spotText('c').existsOnce();
  });
}
```

## Roadmap

- ✅ Make chainable `WidgetSelector`s
- ✅ Print full widget tree when assertions fail
- ✅ Allow defining `WidgetSelector` with children
- ✅ Allow defining `WidgetSelector` with parents
- ✅ Interop with `Finder` API
- ✅ Match properties of widgets (via `DiagnosticsNode`)
- ✅ Allow matching of nested properties (with checks API)
- ✅ Generate code for custom properties for Flutter widgets
- ✅ Allow generating code for properties of 3rd party widgets
- ✅ Interact with widgets (`act`)
- ✅ Allow manually printing a screenshot at certain points
- ✅ Negate child matchers
- ✅ Simplify `WidgetSelector` API
- ✅ Create screenshot when test fails
- ✅️ Create interactive HTML page with all widgets and matchers when test fails
- ✅ Automatically create report with screenshots of all user interactions
- ✅ `loadAppFonts()`
- ⬜️ More `act` features, feature parity with `WidgetTester` 
- ⬜️ Combine multiple WidgetSelectors with `and`
- ⬜️ Become the de facto Widget selector API for [patrol](https://pub.dev/packages/patrol)
- ⬜️ Single pixel color testing
- ⬜️ `pumpSmart()`

## Project state

100% production ready.

- The `WidgetSelector` API is stable
- The existing `act` API is limited, but what exists is great.
- The Timeline is in its early stages but will be improved over time.

## License

```
Copyright 2022 Pascal Welsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
