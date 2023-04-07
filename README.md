## Spot

<img src="https://user-images.githubusercontent.com/1096485/188243198-7abfc785-8ecd-40cb-bb28-5561610432a4.png" height="100px">

Fluent, chainable Widget finders and better assertions for Flutter widget tests

## Usage

```dart
// Spotters
final homePage = spot.byType(MaterialApp).childByType(Scaffold);
final appBar = homePage.childByType(AppBar);

// Assertions
appBar.childByIcon(
  Icons.settings,
  parents: [spot.byType(IconButton)],
).existsOnce();
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
Spot prints a big but helpful error message, containing the icon that is shown instead (`IconData(U+0E318)`).

```
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

## Goals

- Make chainable widget finders that are able to produce better error messages when their assertions fail
- `find.ancestor()` and `find.descendant()` are slow, `spot` aims to be faster by walking a subset of the widget tree

## Project state

The API is experimental and subject to change.

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
