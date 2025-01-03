import 'dart:io';

import 'package:hot_restart_timeline/hot_restart_timeline.dart'
    as hot_restart_timeline;

Future<void> main(List<String> arguments) async {
  ProcessSignal.sigint.watch().listen((event) {
    exit(0);
  });
  await hot_restart_timeline.main();
}
