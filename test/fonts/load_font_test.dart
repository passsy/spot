import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('load non-font file does not throw', skip: kIsWeb,
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync();
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final notAFont = File('${tempDir.path}/someFile.txt');
    notAFont.writeAsStringSync('some data');

    final List<dynamic> messages = [];
    // ignore: deprecated_member_use
    PlatformDispatcher.instance.onPlatformMessage = (
      String name,
      ByteData? data,
      PlatformMessageResponseCallback? callback,
    ) {
      final decoded = SystemChannels.system.codec.decodeMessage(data);
      final type = (decoded! as Map)['type'];
      messages.add(type);
      callback?.call(null);
    };
    addTearDown(() {
      // ignore: deprecated_member_use
      PlatformDispatcher.instance.onPlatformMessage = null;
    });

    expect(messages, isEmpty);
    await loadFont('someFont', [notAFont.path]);
    expect(messages, ['fontsChange']); // success regardless of file content
  });
}
