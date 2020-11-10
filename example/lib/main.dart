import 'package:flutter/material.dart';

import 'package:material_tag_editor/tag_editor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Tag Editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Material Tag Editor Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> values = [];

  onDelete(index) {
    setState(() {
      values.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TagEditor(
                length: values.length,
                delimeters: [',', ' '],
                hasAddButton: true,
                resetTextOnSubmitted: true,
                textStyle: TextStyle(color: Colors.grey),
                onSubmitted: (outstandingValue) {
                  setState(() {
                    values.add(outstandingValue);
                  });
                },
                inputDecoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Hint Text...',
                ),
                onTagChanged: (newValue) {
                  setState(() {
                    values.add(newValue);
                  });
                },
                tagBuilder: (context, index) => _Chip(
                  index: index,
                  label: values[index],
                  onDeleted: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    @required this.label,
    @required this.onDeleted,
    @required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
