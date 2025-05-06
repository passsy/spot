# Spot

[![pub](https://img.shields.io/pub/v/spot?include_prereleases)](https://pub.dev/packages/spot)

![DALL·E generated spot repo header image](https://github.com/user-attachments/assets/490103a5-4ac6-41f9-9b4f-4333e3e5ff66)

Spot is a toolkit for Flutter widget tests.<br/>
It simplifies queries and assertions against the widget tree (better finder API called `spot`) and
visualizes the steps of a widget test as HTML report with automatic screenshots, the `Timeline`.

🖼️ Automatic screenshots during widget tests (Timeline)<br/>
⛓️ Chainable widget selectors<br/>
💙 Useful error messages (with full tree dump)<br/>
🌱 Opt-in, works with plain `testWidgets()`<br/>
💫 Compatibility with `integration_test` (except for the Timeline)<br/>

- [Get started](#get-started)
- [Timeline](#timeline)
    - [Overview](#overview)
    - [Add custom events to the Timeline](#add-custom-events-to-the-timeline)
    - [Change Timeline mode](#change-timeline-mode)
    - [Timeline in console on CI](#timeline-in-console-on-ci)
- [Screenshots](#screenshots)
    - [Manual Screenshots](#manual-screenshots)
    - [Load Fonts](#load-fonts)
- [spot - Widget selectors](#widget-selectors-spot)
    - [Chain selectors](#chain-selectors)
    - [Selectors](#selectors)
    - [Better errors](#better-errors)
    - [Matchers](#matchers)
    - [Selectors vs. Matchers](#selectors-vs-matchers)
    - [Find offstage widgets](#find-offstage-widgets)
- [act - tap, drag, type](#act-tap-drag-type-click)
  - [tap](#tap)
  - [tapAt](#tapAt)
  - [enterText](#entertext)
  - [dragUntilVisible](#draguntilvisible)
  - [more act functions](#more-act-functions)
- [Roadmap](#roadmap)
- [Project state](#project-state)
- [License](#license)

## Get started

```bash
flutter pub add dev:spot
```

1\. Replace widget assertions (`find`) with `spot`.<br/>
2\. Replace interactions like `tester.tap()` with `act.tap()` to interact with widgets.

With every call with `spot` or `act`, spot captures the current frame and adds it to the Timeline HTML report.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existing Widget test', (tester) async {
     await tester.pumpWidget(MyApp());
  
     // await tester.tap(find.byType(ElevatedButton));
     await act.tap(spot<ElevatedButton>());

     // expect(find.text('monde'), findsOneWidget); // 🇫🇷
     spot<Scaffold>().spotText('monde').existsOnce(); // 🇫🇷

     // Automatically generates a timeline report on error
  });
}
```

When your test fails, spot generates the Timeline HTML report with all assertions (`spot`) and gestures (`act`), automatic screenshots and more information.

```bash
Generating timeline report
View timeline here: file:///var/folders/0j/p0s0zrv91tgd33zrxb98c0440000gn/T/ecsTKx/existing-widget.html
```

You can open the local Timeline report in your browser.

![Timeline](https://github.com/user-attachments/assets/48a1a754-f56a-4c61-a4ef-b6e564ee1282)

## Timeline

### Overview

The Timeline is a visual representation of the widget test run, rendered as an HTML report.
It shows all interactions with the spot package, like `spot` and `act`.
The focus on screenshots with annotations makes it easy to follow what happened during the test run.
At any point in the timeline, it is possible to jump back into the test code.

The Timeline is constructed during a widget test with the first interaction with `spot`.
The more frames of a test are asserted with spot, the more detailed the Timeline becomes.

By default, the Timeline is automatically generated when a test fails.
The path to the HTML file is printed to the console.

Successful tests skip the Timeline generation (and extra work).

Widget tests without any call to `spot` do **not** generate a Timeline.

### Add custom events to the Timeline

You can add custom events to the Timeline to better understand what is happening in your test.
The timeline API is completely open and allows adding any event you want.

```dart
timeline.addEvent(
  eventType: 'Received fake server response',
  details: 'HTTP 200\n{"message": "Hello World"}',
  color: Colors.orange,
  screenshot: timeline.takeScreenshotSync(),
);
```

![Custom Timeline event](https://github.com/user-attachments/assets/fed7b032-76c0-44ab-b8b3-f33b81f420da)

### Change Timeline mode

Spot automatically generates a Timeline HTML report when a test fails.
Change this behavior by adjusting the `TimelineMode`, e.g. during development, to always generate the timeline or skip it for parts of a test.

`TimelineMode` defines the following values:

- `off`: No events will be recorded
- `reportOnError` _(default)_: Only generate a Timeline report when a test fails
- `always`: Always generate the Timeline report at the end of the test
- `live`: Print all Timeline events to console as they happen

There are three ways to change the `TimelineMode`:

#### Single test

```dart

void main() {
  testWidgets('my widget test', (tester) async {
    timeline.mode = TimelineMode.always;
    /* ... */
  });

  testWidgets('complex test', (tester) async {
    timeline.mode = TimelineMode.off;
    /* a long setup which should not be recorded */
    timeline.mode = TimelineMode.reportOnError;
    
    // relevant test code
  });
}
```

#### Entire file

Changing the `globalTimelineMode` only a default at the beginning of each test.
It can be changed by each test individually.

```dart
void main() {
  globalTimelineMode = TimelineMode.off;
  
  testWidgets('my widget test', (tester) async {/* ... */});

  testWidgets('another test', (tester) async {
    // overwrites the global mode
    timeline.mode = TimelineMode.always;
    // consle: View timeline here: file:///var/folders/0j/p0s0zrv91t...
  });
}
```

#### Global

```bash
flutter test --dart-define=SPOT_TIMELINE_MODE=always
```

### Timeline in console on CI

On CI servers, it might be hard to access the HTML reports.
The only output is often the console output.
Unless the reports are explicitly archived after a run, they are usually inaccessible.

Spot automatically [detects CI](https://pub.dev/packages/ci) systems and dumps the Timeline to the console when a test fails.
That might be ugly to read, but all information is better than none.

To disable this behavior, set `SPOT_TIMELINE_MODE=off` as an environment variable.

```yaml
# Github Actions
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Run tests
        run: flutter test --dart-define=SPOT_TIMELINE_MODE=off
```

## Screenshots

### Manual Screenshots

The Timeline automatically captures screenshots. But those are always for the entire screen and are not available during the test itself.

Use `await takeScreenshot()` to get the current pixels on the virtual screen.

`takeScreenshot` also takes a `selector` parameter to screenshot a single widget. This is useful to check the actual rasterized image (pixels) of a widget.

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
    await takeScreenshot(selector: spot<AppBar>());
    // console:
    // Screenshot file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/spot/screenshot_test:16-w8UPv.png
    //   taken at main.<fn> file:///Users/pascalwelsch/Projects/passsy/spot/test/spot/screenshot_test.dart:16:24
  });
}
```

### Load Fonts

The Timeline shows a rich report of the significant events during the test with screenshots.
To better understand what's shown on the screenshots, it's important to load the fonts from your app, otherwise Flutter renders the text with the unreadable `Ahem` default font.

Use `await loadAppFonts()` to load the fonts defined in the `pubspec.yaml`.

```dart
void main() {
  testWidgets('my widget test', (tester) async {
    await loadAppFonts();
    /* ... */
  });
}
```

Additionally, `loadAppFonts()` loads the `Roboto` font, which is the default font in Flutter tests.

| before | after |
|--------|-------|
| ![golden_testImage](https://github.com/user-attachments/assets/385e7760-c3ee-42d7-a3bd-6c5b906b7452) | ![golden_masterImage](https://github.com/user-attachments/assets/8261f27e-5a38-43c2-bff9-cfe01496215c) |

## Widget selectors `spot`

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
This can save a lot of time when debugging failing widget tests.

Here, the settings icon could not be found in the `AppBar`.
Classic widget tests would show the following error using `findsOneWidget`.

```text
expect(find.byIcon(Icons.settings), findsOneWidget);

>>> Expected: exactly one matching node in the widget tree
>>>   Actual: _WidgetIconFinder:<zero widgets with icon "IconData(U+0E57F)" (ignoring offstage widgets)>
>>>    Which: means none were found but one was expected
```

The error message above is not really helpful, because the actual error is not that there's no icon, but the `Icons.home` instead of `Icons.settings`.

The spot error message is much more helpful, showing two potential candidates in the `AppBar`.

```text
Could not find AppBar ᗕ Icon Widget with icon: "IconData(U+0E57F)" in widget tree, expected exactly
1
A less specific search (Icon with parent AppBar) discovered 2 matches!

View timeline here: file:///var/folders/0j/p0s0zrv91tgd33zrxb88c0440000gn/T/hDEgVS/timeline-narrow-down-search-down-the-tree.html
```

Spot was able to find two Icon Widgets in the AppBar (with the wrong icon). They are presented in the Timeline report, highlighted in the screenshot.

![Home Icon is the error](https://github.com/user-attachments/assets/9929d827-e8d0-4d01-aeeb-68eb6912d248)

A picture is worth a thousand lines of code.

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
You don't have to use `expect()`, instead you can use the `has*`/`is*` matchers directly.

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

### Selectors vs. Matchers

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
    
    spotOffstage().spot<Text>().existsAtMostNTimes(3);
    spotOffstage().spotText('c').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.onstage).spotText('c').doesNotExist();
    
    spotAllWidgets().spotText('a').existsOnce();
    spotAllWidgets().spotText('c').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.combined).spotText('a').existsOnce();
    spotOffstage().overrideWidgetPresence(WidgetPresence.combined).spotText('c').existsOnce();
  });
}
```

## act - tap, drag, type, click

To interact with widgets, use the `act` API.
The collection of functions mimics user interactions with the UI.
It tries to reach feature parity with the `WidgetTester` API, while drastically improving common pitfalls and error messages.

### tap

Triggers a tap event (down + up) on the found widget.

```dart
// flutter_test
// await tester.tap(find.byType(ElevatedButton));

// spot
await act.tap(spot<ElevatedButton>());
```

Tapping a widget looks almost identical to the `WidgetTester` API but with a few improvements.

- Checks that the widget is within the window bounds
- When partially visible, automatically taps the visible part (and prints a warning when <80% tappable)
- When fully covered, shows which widgets overlay it
- Adds screenshot with crosshair annotation to the Timeline
- pumps automatically after the tap
- When multiple widgets are found, it prints a useful error message

### tapAt

```dart
await act.tapAt(const Offset(100, 100));
```

Taps the screen (down + up) at `position` on the global coordinate system and pumps a frame.

- Checks that `position` is within the window viewport
- Lists all widgets reacting to the hitTest in the timeline
- pumps automatically after the tap

### enterText

```dart
await act.enterText(spot<EmailAddress>(), 'dash@wiredash.com');
```

The `act.enterText()` automatically searches for the first `EditableText` widget within the provide selector (`spot<EmailAddress>()`).
It then enters the text in one go (like pasting it) and pumps the widget tree.

### dragUntilVisible

```dart
await act.dragUntilVisible(
  dragStart: spot<LongListScreen>().spot<Scrollable>(),
  dragTarget: spotText('Item 32'),
  moveStep: const Offset(0, -100),
);
```

The `act.dragUntilVisible()` continuously drags from the center of `dragStart` until it reaches `dragTarget`.

The direction is determined by the `moveStep` parameter.
Scrolling towards the end (bottom) of a list is archived with a negative `dy` (`Offset(0, -100)`).
scrolling towards the beginning (top) requires a positive `dy` (`Offset(0, 100)`).

Scroll faster by increasing the `moveStep` value. Make sure to keep it below the height of the viewport or the `dragTarget` might be missed.
Check the Timeline for screenshots of the dragged area. It will help to determine good values for `moveStep`, minimizing the number of drags.

Increase `maxIteration` (default `30`) for very long lists if the item is not found within that many drags.

### more act functions

Please [create an issues](https://github.com/passsy/spot/issues/new) when you miss a function or have a suggestion for a new one. Any contribution in this direction is welcome.

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

```text
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
