# Material Tag Editor

## Breaking Changes for 0.0.6

- Correct the spelling of `TagEditor`'s named parameter, `delimeters` to `delimiters`

A simple tag editor for inputing tags.

![image](https://user-images.githubusercontent.com/18391546/82047483-dc8f0f00-96ed-11ea-8a91-7eaa64e2358b.gif)

## Usage

Add the package to pubspec.yaml

```dart
dependencies:
  material_tag_editor: x.x.x
```

Import it

```dart
import 'package:material_tag_editor/tag_editor.dart';
```

Use the widget

```dart
TagEditor(
  length: values.length,
  delimiters: [',', ' '],
  hasAddButton: true,
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
)
```

It is possible to build the tag from your own widget, but it is recommended that Material Chip is used

```dart
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
```
