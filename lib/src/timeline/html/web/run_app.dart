import 'package:jaspr/browser.dart';
import 'package:spot/src/timeline/html/web/app.dart';
import 'package:web/web.dart';

void main() async {
  await window.onLoad.first;
  runApp(const App());
}
