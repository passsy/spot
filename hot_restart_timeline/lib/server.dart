import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:hot_restart_timeline/hot_restart_timeline.dart';
import 'package:server_nano/server_nano.dart';

void startServer(Directory timelineHotReloadDir) {
  final server = Server();
  server.static(spotPackageRoot.directory('build/timeline/').path);
  server.get('/', (req, resp) {
    final timelines = timelineHotReloadDir
        .listSync(recursive: true)
        .where((file) => file.path.endsWith('.html'))
        .map((file) {
      final relative = file.path.split('build/timeline/').last;
      return '<li><a href="/$relative">$relative</a></li>\n';
    }).join('\n');
    resp.sendHtmlText(
      '<h1>Spot timelines</h1>\n\n'
      '<ul>\n$timelines</ul>',
    );
  });

  server.listen(port: 5907);
}
