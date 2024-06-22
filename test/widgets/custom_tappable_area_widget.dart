import 'package:flutter/material.dart';

class CustomTappableAreaWidget extends StatelessWidget {
  const CustomTappableAreaWidget({
    super.key,
    required this.tapOffset,
    required this.onTap,
    this.areaSize = 50.0,
  });

  final Offset tapOffset;
  final double areaSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const IgnorePointer(
          child: ColoredBox(
            color: Colors.transparent,
          ),
        ),
        Positioned(
          left: tapOffset.dx - areaSize / 2,
          top: tapOffset.dy - areaSize / 2,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: areaSize,
              height: areaSize,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
