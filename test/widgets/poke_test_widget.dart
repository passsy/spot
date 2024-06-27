import 'package:flutter/material.dart';

/// A widget designed to simulate hit test limitations on `widgetToCover`
/// by covering it either entirely or partially with a grid.
///
/// This widget allows configuration of interactive areas within the grid:
///
/// - By specifying `pokableAtRowIndex` or `pokableAtColumnIndex`, entire rows or
/// columns can be made tappable. Specifying both indices will make only the
/// specific cell at that row and column index tappable, allowing
/// taps to pass through to `widgetToCover` underneath. If neither is specified,
/// all cells will block tap events by default.
///
/// - Specifying `rows` and `columns` will determine their respective amount and
/// therefore the dimensions of each cell.
class PokeTestWidget extends StatefulWidget {
  const PokeTestWidget({
    super.key,
    required this.widgetToCover,
    required this.rows,
    required this.columns,
    this.pokableAtColumnIndex,
    this.pokableAtRowIndex,
  });

  /// The widget that the grid will cover.
  final Widget widgetToCover;

  /// The number of rows in the grid overlay.
  final int rows;

  /// The number of columns in the grid overlay.
  final int columns;

  /// The index of the row that should be tappable.
  final int? pokableAtRowIndex;

  /// The index of the column that should be tappable.
  final int? pokableAtColumnIndex;

  @override
  State<PokeTestWidget> createState() => _PokeTestWidgetState();
}

class _PokeTestWidgetState extends State<PokeTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          widget.widgetToCover,
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: List.generate(widget.rows, (row) {
                    return Row(
                      children: List.generate(widget.columns, (col) {
                        final isPokable = () {
                          if (widget.pokableAtRowIndex == null) {
                            return widget.pokableAtColumnIndex == col;
                          }
                          if (widget.pokableAtColumnIndex == null) {
                            return widget.pokableAtRowIndex == row;
                          }
                          return widget.pokableAtRowIndex == row &&
                              widget.pokableAtColumnIndex == col;
                        }();
                        return IgnorePointer(
                          ignoring: isPokable,
                          child: Container(
                            width: constraints.maxWidth / widget.columns,
                            height: constraints.maxHeight / widget.rows,
                            color: isPokable
                                ? Colors.transparent
                                : ((row + col).isEven
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        );
                      }),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
