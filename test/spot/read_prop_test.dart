import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/props.dart';

void main() {
  group('WidgetSelector', () {
    testWidgets('getWidgetProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final color = spot<_MyContainer>()
          .getWidgetProp(widgetProp('color', (widget) => widget.color));
      expect(color, Colors.white54);
    });

    testWidgets('getWidgetProp AnyText', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: Text('hello'))));
      final text = spotText('hello')
          .getWidgetProp(widgetProp('data', (widget) => widget.text));
      expect(text, 'hello');
    });

    testWidgets('getElementProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final innerValue = spot<_MyContainer>().getElementProp(
        elementProp('innerValue', (el) {
          return ((el as StatefulElement).state as _MyContainerState)
              .innerValue;
        }),
      );
      expect(innerValue, 'stateValue');
    });

    testWidgets('getStateProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final innerValue = spot<_MyContainer>().getStateProp(
        stateProp<String, _MyContainerState>('innerValue', (s) => s.innerValue),
      );
      expect(innerValue, 'stateValue');

      // alternate syntax
      spot<_MyContainer>().getStateProp(
        stateProp('innerValue', (_MyContainerState s) => s.innerValue),
      );
    });

    testWidgets('getRenderObjectProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final size = spot<_MyContainer>().getRenderObjectProp(
        renderObjectProp<Size, RenderBox>('size', (r) => r.size),
      );
      expect(size, const Size(800.0, 600.0));
    });
  });

  group('WidgetMatcher', () {
    testWidgets('getWidgetProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final color = spot<_MyContainer>()
          .existsOnce()
          .getWidgetProp(widgetProp('color', (widget) => widget.color));
      expect(color, Colors.white54);
    });

    testWidgets('getWidgetProp AnyText', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: Text('hello'))));
      final text = spotText('hello')
          .existsOnce()
          .getWidgetProp(widgetProp('data', (widget) => widget.text));
      expect(text, 'hello');
    });

    testWidgets('getElementProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final innerValue = spot<_MyContainer>().existsOnce().getElementProp(
            elementProp('innerValue', (el) {
              return ((el as StatefulElement).state as _MyContainerState)
                  .innerValue;
            }),
          );
      expect(innerValue, 'stateValue');
    });

    testWidgets('getStateProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final innerValue = spot<_MyContainer>().existsOnce().getStateProp(
            stateProp<String, _MyContainerState>(
              'innerValue',
              (s) => s.innerValue,
            ),
          );

      expect(innerValue, 'stateValue');

      // alternate syntax
      spot<_MyContainer>().existsOnce().getStateProp(
            stateProp('innerValue', (_MyContainerState s) => s.innerValue),
          );
    });

    testWidgets('getRenderObjectProp', (tester) async {
      await tester.pumpWidget(const _MyContainer(color: Colors.white54));
      final size = spot<_MyContainer>().existsOnce().getRenderObjectProp(
            renderObjectProp<Size, RenderBox>('size', (r) => r.size),
          );
      expect(size, const Size(800.0, 600.0));
    });
  });
}

class _MyContainer extends StatefulWidget {
  const _MyContainer({required this.color});

  final Color color;

  @override
  State<_MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<_MyContainer> {
  final innerValue = 'stateValue';
  @override
  Widget build(BuildContext context) {
    return Placeholder(color: widget.color);
  }
}
