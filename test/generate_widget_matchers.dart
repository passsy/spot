// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  _generateWidget<Text>(
    builder: () => Text(''),
    propNameOverrides: {
      'data': 'text',
    },
  );
  _generateWidget<EditableText>(
    builder: () => EditableText(
      controller: TextEditingController(),
      focusNode: FocusNode(),
      style: TextStyle(),
      cursorColor: Colors.black,
      backgroundCursorColor: Colors.black,
    ),
  );
  _generateWidget<Container>(
    builder: () => Container(),
    propNameOverrides: {
      'fg': 'foreground',
      'bg': 'background',
    },
  );
  _generateWidget<Row>(builder: () => Row());
  _generateWidget<Wrap>(
    builder: () => Wrap(),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<SizedBox>(
    builder: () => _child,
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<Align>(
    builder: () => Align(),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<SafeArea>(builder: () => SafeArea(child: _child));
  _generateWidget<Opacity>(
    builder: () => Opacity(opacity: 0),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<Column>(
    builder: () => Column(),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<Row>(
    builder: () => Row(),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<Icon>(builder: () => Icon(Icons.add));
  _generateWidget<ConstrainedBox>(
    builder: () => ConstrainedBox(constraints: BoxConstraints.tightFor()),
    imports: " import 'package:flutter/rendering.dart';\n"
        "import 'package:flutter/widgets.dart';",
  );
  _generateWidget<WidgetsApp>(builder: () => _partOfMaterialApp);
  _generateWidget<Navigator>(builder: () => _partOfMaterialApp);
  _generateWidget<Image>(
    builder: () => Image.file(File('')),
    propNameOverrides: {
      'this.excludeFromSemantics': 'excludeFromSemantics',
      'thisExcludeFromSemantics': 'excludeFromSemantics',
    },
  );
  _generateWidget<Form>(builder: () => Form(child: _child));
  _generateWidget<FormField<String>>(
    builder: () => FormField<String>(builder: (_) => _child),
  );
  _generateWidget<Semantics>(
    builder: () => Semantics(),
    imports: "import 'package:flutter/widgets.dart';\n"
        "import 'package:flutter/rendering.dart';\n",
  );

  // Material
  _generateWidget<SelectableText>(
    builder: () => SelectableText(''),
    imports: "import 'package:flutter/material.dart';",
    propNameOverrides: {
      'data': 'text',
    },
  );
  _generateWidget<MaterialApp>(
    builder: () => _partOfMaterialApp,
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<AppBar>(
    builder: () => AppBar(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Scaffold>(
    builder: () => Scaffold(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<ElevatedButton>(
    builder: () => ElevatedButton(onPressed: () {}, child: _child),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<OutlinedButton>(
    builder: () => OutlinedButton(onPressed: () {}, child: _child),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<IconButton>(
    builder: () => IconButton(onPressed: () {}, icon: Icon(Icons.add)),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<TextButton>(
    builder: () => TextButton(onPressed: () {}, child: _child),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Checkbox>(
    builder: () => Checkbox(value: true, onChanged: (_) {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Switch>(
    builder: () => Switch(value: true, onChanged: (_) {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Radio<String>>(
    builder: () =>
        Radio<String>(value: 'a', groupValue: 'a', onChanged: (_) {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Slider>(
    builder: () => Slider(value: 0, onChanged: (_) {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<TextField>(
    builder: () => TextField(),
    imports: "import 'package:flutter/material.dart';\n"
        "import 'package:flutter/services.dart';",
  );
  _generateWidget<FloatingActionButton>(
    builder: () => FloatingActionButton(onPressed: () {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<BottomNavigationBar>(
    builder: () => BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
      ],
    ),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Drawer>(
    builder: () => Drawer(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<DropdownButton<String>>(
    builder: () => DropdownButton<String>(items: [], onChanged: (_) {}),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<PopupMenuButton<String>>(
    builder: () => PopupMenuButton<String>(itemBuilder: (_) => []),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<BottomSheet>(
    builder: () => BottomSheet(onClosing: () {}, builder: (_) => _child),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<SimpleDialog>(
    builder: () => SimpleDialog(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Chip>(
    builder: () => Chip(label: _child),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<CircularProgressIndicator>(
    builder: () => CircularProgressIndicator(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<LinearProgressIndicator>(
    builder: () => LinearProgressIndicator(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Tooltip>(
    builder: () => Tooltip(message: ''),
    imports: "import 'package:flutter/material.dart';",
    propNameOverrides: {
      'vertical offset': 'verticalOffset',
      'wait duration': 'waitDuration',
      'show duration': 'showDuration',
    },
  );
  _generateWidget<DataTable>(
    builder: () => DataTable(
      columns: [
        DataColumn(label: _child),
      ],
      rows: [],
    ),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<GridView>(
    builder: () => GridView.count(crossAxisCount: 1),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<Divider>(
    builder: () => Divider(),
    imports: "import 'package:flutter/material.dart';",
  );
  _generateWidget<ListTile>(
    builder: () => ListTile(),
    imports: "import 'package:flutter/material.dart';",
  );

  // UnionTypes
  _generateWidget<AnyText>(
    builder: () => AnyText.fromRichText(
      RichText(
        text: const TextSpan(text: 'Hello', style: TextStyle()),
      ),
    ),
    filter: (node) {
      if (node.name == 'renderObject') return false;
      return true;
    },
  );

  test('format at the end', () {
    final generatedFiles = Directory('lib/src/widgets').listSync();
    Process.runSync('dart', [
      'format',
      ...generatedFiles.map((e) => e.path),
    ]);
  });
}

void _generateWidget<W extends Widget>({
  required Widget Function() builder,
  Map<String, String> propNameOverrides = const {},
  String? imports,
  bool Function(DiagnosticsNode node)? filter,
}) {
  String name = W.toString();
  if (name.contains('<')) {
    name = name.substring(0, name.indexOf('<'));
  }
  return testWidgets(name, (tester) async {
    tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Center(
            child: builder(),
          ),
        ),
      ),
    );
    spot<W>().writeMatchersToFile(
      path: 'lib/src/widgets/${name.toLowerCase()}.g.dart',
      propNameOverrides: propNameOverrides,
      imports: imports,
      filter: filter,
    );
  });
}

const _partOfMaterialApp = SizedBox();
const _child = SizedBox();
