import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../widgets/custom_tappable_area_widget.dart';

void main() {
  testWidgets('Partially covered, finds tappable area', (tester) async {
    bool gotTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: CustomTappableAreaWidget(
            tappablePosition: const MapEntry(15, 15),
            onTap: (tapped) {
              gotTapped = tapped;
            },
          ),
        ),
      ),
    );
    final WidgetSelector<WidgetToPoke> button = spot<WidgetToPoke>()
      ..existsOnce();
    await act.tap(button);
    expect(gotTapped, isTrue);
  });
}
