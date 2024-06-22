import 'package:flutter/material.dart';

import '../util/measure_size.dart';

class PokeTestWidget extends StatefulWidget {
  const PokeTestWidget({
    super.key,
    required this.child,
    required this.setup,
  });

  final PokeTestSetup setup;
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

class PokeTestSetup {
  final int rows;
  final int columns;
  final int pokableAtRowIndex;
  final int pokableAtColumnIndex;

  const PokeTestSetup({
    required this.rows,
    required this.columns,
    required this.pokableAtColumnIndex,
    required this.pokableAtRowIndex,
  });
}
