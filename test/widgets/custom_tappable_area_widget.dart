import 'package:flutter/material.dart';

class CustomTappableAreaWidget extends StatelessWidget {
  const CustomTappableAreaWidget({
    super.key,
    MapEntry<int, int>? tappablePosition,
    required this.onTap,
    Size? boardSize,
    MapEntry<int, int>? cubeCount,
  })  : _boardSize = boardSize ?? const Size(400, 400),
        _tappablePosition = tappablePosition ?? const MapEntry(1, 1),
        _cubeCount = cubeCount ?? const MapEntry<int, int>(16, 16);

  final Size _boardSize;

  final MapEntry<int, int> _cubeCount;
  final MapEntry<int, int>? _tappablePosition;
  final void Function(bool) onTap;

  double get _totalWidth => _boardSize.width;
  double get _totalHeight => _boardSize.height;
  double get _cubeWidth => _totalWidth / _cubeCount.key;
  double get _cubeHeight => _totalWidth / _cubeCount.value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _totalWidth,
        maxHeight: _totalHeight,
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              onTap.call(true);
            },
            child: WidgetToPoke(
              width: _totalWidth,
              height: _totalHeight,
            ),
          ),
          Column(
            children: List.generate(_cubeCount.value, (row) {
              return Row(
                children: List.generate(_cubeCount.key, (col) {
                  final bool isTappable = _tappablePosition?.key == row &&
                      _tappablePosition?.value == col;
                  return IgnorePointer(
                    ignoring: isTappable,
                    child: Container(
                      width: _cubeWidth,
                      height: _cubeHeight,
                      color: isTappable
                          ? Colors.transparent
                          : ((row + col).isEven ? Colors.white : Colors.black),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class WidgetToPoke extends StatelessWidget {
  const WidgetToPoke({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.green,
    );
  }
}
