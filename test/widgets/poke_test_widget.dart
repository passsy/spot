import 'package:flutter/material.dart';

import '../util/measure_size.dart';

/// Allows for simulating a widget's ability to receive tap events by covering
/// it entirely or partially. Coverage can be customized via
/// [PokeTestWidgetSetup]. Since the child's size is being calculated by
/// [MeasureSize], it's important to allow the widget to layout properly via
/// `await tester.pump()` before making any assertions.
class PokeTestWidget extends StatefulWidget {
  const PokeTestWidget({
    super.key,
    required this.child,
    required this.setup,
  });

  final PokeTestWidgetSetup setup;
  final Widget child;

  @override
  State<PokeTestWidget> createState() => _PokeTestWidgetState();
}

class _PokeTestWidgetState extends State<PokeTestWidget> {
  Size? childSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MeasureSize(
          onChange: (size) {
            setState(() {
              childSize = size;
            });
          },
          child: widget.child,
        ),
        if (childSize != null)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: childSize!.width,
              maxHeight: childSize!.height,
            ),
            child: Column(
              children: List.generate(widget.setup.rows, (row) {
                return Row(
                  children: List.generate(widget.setup.columns, (col) {
                    final bool isTappable =
                        widget.setup.pokableAtRowIndex == row &&
                            widget.setup.pokableAtColumnIndex == col;
                    return IgnorePointer(
                      ignoring: isTappable,
                      child: Container(
                        width: childSize!.width / widget.setup.columns,
                        height: childSize!.height / widget.setup.rows,
                        color: isTappable
                            ? Colors.transparent
                            : ((row + col).isEven
                                ? Colors.white
                                : Colors.black),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Setup for [PokeTestWidget].
/// Allows for defining a grid of squares that will cover `PokeTestWidget`'s
/// child. `pokeableAtRowIndex` and `pokeableAtColumnIndex` can be
/// used to define a single square that will allow taps to pass through.
class PokeTestWidgetSetup {
  final int rows;
  final int columns;
  final int? pokableAtRowIndex;
  final int? pokableAtColumnIndex;

  const PokeTestWidgetSetup({
    required this.rows,
    required this.columns,
    this.pokableAtColumnIndex,
    this.pokableAtRowIndex,
  });
}
