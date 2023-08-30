# Spot

[![pub](https://img.shields.io/pub/v/spot?include_prereleases)](https://pub.dev/packages/spot)

<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">

Fluent, chainable Widget finders and better assertions for Flutter widget tests

⛓️ Chainable widget selectors
💙 Prints helpful error messages

## Usage

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
        .spot<IconButton>(children: [spotSingleIcon(Icons.home)])
        .existsOnce()
        .hasTooltip('home');

    // Find widgets based on multiple parent widgets
    spot<Icon>(parents: [appBar, spot<IconButton>()])
        .existsExactlyNTimes(2)
        .all((icon) {
      icon.hasColorWhere((color) => color.equals(Colors.black));
    });

    // Interact with widgets using `act`
    final button = spotSingle<FloatingActionButton>();
    act.tap(button);
  });
}

```

### Better errors

In case the settings icon doesn't exist you usually would get the following error using `findsOneWidget`

```
expect(find.byIcon(Icons.settings), findsOneWidget);

>>> Expected: exactly one matching node in the widget tree
>>>   Actual: _WidgetIconFinder:<zero widgets with icon "IconData(U+0E57F)" (ignoring offstage widgets)>
>>>    Which: means none were found but one was expected
```

The error message above is not really helpful, because the actual error is not that there's no icon, but the `Icons.home` instead of `Icons.settings`. 

spot prints the entire widget tree and shows that there is an `Icon`, but the wrong one (`IconData(U+0E318)`). 
That's much more helpful!

In the future, spot will only print the widget tree from the last node found node (`spot<AppBar>`).

```
spot<AppBar>().spotSingleIcon(Icons.settings).existsOnce();

Could not find 'icon "IconData(U+0E57F)"' as child of #2 type "IconButton"
There are 1 possible parents for 'icon "IconData(U+0E57F)"' matching #2 type "IconButton". But non matched. The widget trees starting at #2 type "IconButton" are:
Possible parent 0:
IconButton(Icon, padding: EdgeInsets.all(8.0), dependencies: [_InheritedTheme, IconTheme, _LocalizationsScope-[GlobalKey#bdafc]])
└Semantics(container: false, properties: SemanticsProperties, renderObject: RenderSemanticsAnnotations#9b22d relayoutBoundary=up13)
 └InkResponse
  └_InkResponseStateWidget(gestures: [tap], mouseCursor: SystemMouseCursor(click), BoxShape.circle, dependencies: [MediaQuery], state: _InkResponseState#181bf)
   └_ParentInkResponseProvider
    └Actions(dispatcher: null, actions: {ActivateIntent: CallbackAction<ActivateIntent>#fded7, ButtonActivateIntent: CallbackAction<ButtonActivateIntent>#5d1ad}, state: _ActionsState#f4947)
     └_ActionsMarker
      └Focus(dependencies: [_FocusMarker], state: _FocusState#3db93)
       └_FocusMarker
        └Semantics(container: false, properties: SemanticsProperties, renderObject: RenderSemanticsAnnotations#d907f relayoutBoundary=up14)
         └MouseRegion(listeners: [enter, exit], cursor: SystemMouseCursor(click), renderObject: RenderMouseRegion#49c96 relayoutBoundary=up15)
          └Semantics(container: false, properties: SemanticsProperties, renderObject: RenderSemanticsAnnotations#e83d5 relayoutBoundary=up16)
           └GestureDetector(startBehavior: start, dependencies: [MediaQuery])
            └RawGestureDetector(state: RawGestureDetectorState#2d012(gestures: [tap], excludeFromSemantics: true, behavior: opaque))
             └Listener(listeners: [down], behavior: opaque, renderObject: RenderPointerListener#cab1c relayoutBoundary=up17)
              └ConstrainedBox(BoxConstraints(48.0<=w<=Infinity, 48.0<=h<=Infinity), renderObject: RenderConstrainedBox#96a26 relayoutBoundary=up18)
               └Padding(padding: EdgeInsets.all(8.0), dependencies: [Directionality], renderObject: RenderPadding#c223d relayoutBoundary=up19)
                └SizedBox(width: 24.0, height: 24.0, renderObject: RenderConstrainedBox#d47d4 relayoutBoundary=up20)
                 └Align(alignment: Alignment.center, dependencies: [Directionality], renderObject: RenderPositionedBox#ac4b6)
                  └Builder(dependencies: [IconTheme])
                   └IconTheme(color: Color(0xffffffff), size: 24.0)
                    └Icon(IconData(U+0E318), dependencies: [Directionality, IconTheme])
                     └Semantics(container: false, properties: SemanticsProperties, renderObject: RenderSemanticsAnnotations#ec9ab relayoutBoundary=up1)
                      └ExcludeSemantics(excluding: true, renderObject: RenderExcludeSemantics#5b179 relayoutBoundary=up2)
                       └SizedBox(width: 24.0, height: 24.0, renderObject: RenderConstrainedBox#eefd6 relayoutBoundary=up3)
                        └Center(alignment: Alignment.center, dependencies: [Directionality], renderObject: RenderPositionedBox#4c194)
                         └RichText(textDirection: ltr, softWrap: wrapping at box width, overflow: visible, maxLines: unlimited, text: "", dependencies: [_LocalizationsScope-[GlobalKey#bdafc]], renderObject: RenderParagraph#35451 relayoutBoundary=up1)
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Could not find 'icon "IconData(U+0E57F)"' as child of [type "MaterialApp" > 'type "Scaffold"' >
'type "AppBar"' && type "IconButton"]
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
- ⬜️ More `act` features
- ⬜️ Print only widget tree of the parent scope when test fails
- ⬜️ Create screenshot when test fails
- ⬜️ Automatically create report with screenshots of all user interactions
- ⬜️ Create interactive HTML page with all widgets and matchers when test fails

## Project state

The public `spot<X>()` API at this point is well-thought-out and stable.
You can absolutely use it today in your tests.

The `act` API is experimental and might change. 

The error messages will see some major improvements in the future but the current ones are already more helpful than the ones from the `finder` API.

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
