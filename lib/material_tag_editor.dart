library material_tag_editor;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './tag_editor_layout_delegate.dart';
import './tag_layout.dart';

/// A Wiget for editing tag similar to Google's Gmail
/// email address input widget in iOS app
/// TODO: Support remove while typing
class TagEditor extends StatefulWidget {
  const TagEditor({
    @required this.length,
    @required this.tagBuilder,
    this.inputDecoration = const InputDecoration(),
    this.hasAddButton = true,
    @required this.onTagChanged,
    this.delimeters = const [],
    this.icon,
    this.enabled = true,
  });

  final int length;
  final Chip Function(BuildContext, int) tagBuilder;
  final InputDecoration inputDecoration;
  final bool hasAddButton;
  final ValueChanged<String> onTagChanged;
  final List<String> delimeters;
  final IconData icon;
  final bool enabled;

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  /// A controller to keep value of the [TextField]
  final _textFieldController = TextEditingController();

  /// A state variable for checking if new text is enter
  var _previousText = '';

  /// A state for checking if the [TextFiled] has focus
  var _isFocused = false;

  /// Focus node for checking if the [TextField] is focused
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTagChanged(String string) {
    if (string.isNotEmpty) {
      widget.onTagChanged(string);
      _textFieldController.text = '';
    }
  }

  void _onTextFieldChange(String string) {
    // TODO: This function looks ugly fix this
    final previousText = _previousText;
    _previousText = string;
    if (string.isEmpty || widget.delimeters.isEmpty) {
      return;
    }

    if (string.length > previousText.length) {
      // Add case
      final newChar = string[string.length - 1];
      if (widget.delimeters.contains(newChar)) {
        final targetString = string.substring(0, string.length - 1);
        if (targetString.isNotEmpty) {
          _onTagChanged(targetString);
        }
      }
    }
  }

  /// Shamelessly copied from [InputDecorator]
  Color _getDefaultIconColor(ThemeData themeData) {
    if (!widget.enabled) {
      return themeData.disabledColor;
    }

    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
      default:
        return themeData.iconTheme.color;
    }
  }

  /// Shamelessly copied from [InputDecorator]
  Color _getActiveColor(ThemeData themeData) {
    if (_focusNode.hasFocus) {
      switch (themeData.brightness) {
        case Brightness.dark:
          return themeData.accentColor;
        case Brightness.light:
          return themeData.primaryColor;
      }
    }
    return themeData.hintColor;
  }

  Color _getIconColor(ThemeData themeData) {
    final themeData = Theme.of(context);
    final activeColor = _getActiveColor(themeData);
    return _isFocused ? activeColor : _getDefaultIconColor(themeData);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.hasAddButton
        ? widget.inputDecoration.copyWith(
            suffixIcon: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(Icons.add),
            onPressed: () {
              _onTagChanged(_textFieldController.text);
            },
          ))
        : widget.inputDecoration;

    final tagEditorArea = Container(
      child: TagLayout(
        delegate: TagEditorLayoutDelegate(length: widget.length),
        children: List<Widget>.generate(
              widget.length,
              (index) => LayoutId(
                id: TagEditorLayoutDelegate.getTagId(index),
                child: widget.tagBuilder(context, index),
              ),
            ) +
            <Widget>[
              LayoutId(
                id: TagEditorLayoutDelegate.textFieldId,
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textFieldController,
                  autocorrect: false,
                  decoration: decoration,
                  onChanged: (text) {
                    _onTextFieldChange(text);
                  },
                ),
              )
            ],
      ),
    );

    return widget.icon == null
        ? tagEditorArea
        : Container(
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: _getIconColor(Theme.of(context)),
                      size: 18.0,
                    ),
                    child: Icon(widget.icon),
                  ),
                ),
                Expanded(child: tagEditorArea),
              ],
            ),
          );
  }
}
