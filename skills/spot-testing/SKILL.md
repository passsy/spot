---
name: spot-testing
description: Write and debug Flutter widget tests using package:spot selectors, assertions, interactions, screenshots, and timeline reports. Use when a project uses Spot or the user asks to adopt it for widget tests.
---

# Widget testing with Spot

Use `package:spot/spot.dart` alongside `package:flutter_test/flutter_test.dart` in ordinary `testWidgets` tests.
Spot is a development dependency; it does not require a custom test runner.
Keep the project's existing test setup and migrate only the tests relevant to the request.

## Select and assert

- Use `spot<W>()` for an exact widget type, `spotText('Save')` for text, `spotIcon(Icons.add)` for an icon, and `spotKey(key)` for a key.
- Narrow duplicate matches by their meaningful parent or child: `spot<AppBar>().spot<IconButton>()` or `spot<ElevatedButton>(children: [spotText('Save')])`.
  Do not hide unintended duplicates with `.first()`.
- A selector describes a query; constructing it alone does not assert anything.
  Finish with `existsOnce()`, `doesNotExist()`, or `existsExactlyNTimes(n)` according to the expected count.
- Once the intended widget is identified, assert its properties with `has...` matchers instead of adding more `with...` filters.
  For example, `spot<Tooltip>().existsOnce().hasMessage('Save')` reports the actual message when it differs.
- Selectors can be reused across frames; a `snapshot()` is a result from one point in time.
  Query again after a state change instead of reusing a snapshot as current state.
- Selectors search onstage widgets by default.
  Use `spotOffstage()` or `spotAllWidgets()` only when the test intentionally checks offstage or combined content.
- For custom text matching, use the checks callback: `spotTextWhere((text) => text.startsWith('Saved'))`.
  This callback receives a `Subject<String>`, not a string predicate returning a boolean.

## Interact and advance frames

Await `act.tap(selector)` and `act.enterText(selector, text)`.
These interactions pump frames, but do not wait for every animation or asynchronous operation to finish.
Use the existing test's controlled pumps to reach the state being asserted; use `pumpAndSettle()` only when the UI is expected to settle.

`act.tap` checks that the target can receive the tap.
When it fails, inspect the selector, layout, overlays, and current frame before changing the interaction.
`act.inspectTap(selector)` provides diagnostics without sending pointer events or pumping a frame.
Read the inspection before another pump, or inspect again afterward.

## Complete example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('save updates the status', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                Text(saved ? 'Saved' : 'Unsaved'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saved = true;
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    spotText('Unsaved').existsOnce();
    final save = spot<ElevatedButton>(children: [spotText('Save')]);
    await act.tap(save);
    spotText('Saved').existsOnce();
    spotText('Unsaved').doesNotExist();
  });
}
```

## Screenshots and timeline reports

Spot records assertions and interactions for its timeline and generates an HTML report on test failure by default.
Use the report path printed by the test run when debugging.
To generate a report for a passing test, set `timeline.mode = TimelineMode.always` inside that test, or run:

```bash
flutter test --dart-define=SPOT_TIMELINE_MODE=always test/example_test.dart
```

Await `loadAppFonts()` inside the widget test before pumping the UI when readable screenshot text matters.
Capture the state of interest before later pumps or teardown with `await takeScreenshot()` or `await takeScreenshot(selector: spot<Scaffold>())`.
A report is built from recorded events, not a screenshot of every pumped frame; add assertions at meaningful intermediate states.
The timeline is for widget tests and is not supported with `integration_test`.

For APIs beyond these patterns, consult the installed version's public API or its package documentation instead of guessing matcher names.
