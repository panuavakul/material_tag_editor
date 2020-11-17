import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './tag_editor_layout_delegate.dart';
import './tag_layout.dart';

/// A [Widget] for editing tag similar to Google's Gmail
/// email address input widget in the iOS app.
/// TODO: Support remove while typing
class TagEditor extends StatefulWidget {
  const TagEditor({
    @required this.length,
    @required this.tagBuilder,
    @required this.onTagChanged,
    Key key,
    this.focusNode,
    this.hasAddButton = true,
    this.delimiters = const [],
    this.icon,
    this.enabled = true,
    // TextField's properties
    this.textStyle,
    this.inputDecoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.resetTextOnSubmitted = false,
    this.onSubmitted,
    this.keyboardAppearance,
  })  : assert(length != null),
        assert(tagBuilder != null),
        assert(onTagChanged != null),
        super(key: key);

  /// The number of tags currently shown.
  final int length;

  /// Builder for building the tags, this usually use Flutter's Material `Chip`.
  final Widget Function(BuildContext, int) tagBuilder;

  /// Show the add button to the right.
  final bool hasAddButton;

  /// The icon for the add button enabled with `hasAddButton`.
  final IconData icon;

  /// Callback for when the tag changed. Use this to get the new tag and add
  /// it to the state.
  final ValueChanged<String> onTagChanged;

  /// When the string value in this `delimiters` is found, a new tag will be
  /// created and `onTagChanged` is called.
  final List<String> delimiters;

  /// Reset the TextField when `onSubmitted` is called
  /// this is default to `false` because when the form is submitted
  /// usually the outstanding value is just used, but this option is here
  /// in case you want to reset it for any reasons (like converting the
  /// outstanding value to tag).
  final bool resetTextOnSubmitted;

  /// Called when the user are done editing the text in the [TextField]
  /// Use this to get the outstanding text that aren't converted to tag yet
  /// If no text is entered when this is called an empty string will be passed.
  final ValueChanged<String> onSubmitted;

  /// Focus node for checking if the [TextField] is focused.
  final FocusNode focusNode;

  /// [TextField]'s properties.
  ///
  /// Please refer to [TextField] documentation.
  final bool enabled;
  final TextStyle textStyle;
  final InputDecoration inputDecoration;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final bool readOnly;
  final Brightness keyboardAppearance;

  @override
  _TagsEditorState createState() => _TagsEditorState();
}

class _TagsEditorState extends State<TagEditor> {
  /// A controller to keep value of the [TextField].
  final _textFieldController = TextEditingController();

  /// A state variable for checking if new text is enter.
  var _previousText = '';

  /// A state for checking if the [TextFiled] has focus.
  var _isFocused = false;

  /// Focus node for checking if the [TextField] is focused.
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = (widget.focusNode ?? FocusNode())
      ..addListener(_onFocusChanged);
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
    // This function looks ugly fix this
    final previousText = _previousText;
    _previousText = string;
    if (string.isEmpty || widget.delimiters.isEmpty) {
      return;
    }

    if (string.length > previousText.length) {
      // Add case
      final newChar = string[string.length - 1];
      if (widget.delimiters.contains(newChar)) {
        final targetString = string.substring(0, string.length - 1);
        if (targetString.isNotEmpty) {
          _onTagChanged(targetString);
        }
      }
    }
  }

  void _onSubmitted(String string) {
    widget.onSubmitted(string);
    if (widget.resetTextOnSubmitted) {
      _textFieldController.text = '';
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
                  style: widget.textStyle,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  controller: _textFieldController,
                  keyboardType: widget.keyboardType,
                  keyboardAppearance: widget.keyboardAppearance,
                  textCapitalization: widget.textCapitalization,
                  textInputAction: widget.textInputAction,
                  autocorrect: widget.autocorrect,
                  textAlign: widget.textAlign,
                  textDirection: widget.textDirection,
                  readOnly: widget.readOnly,
                  autofocus: widget.autofocus,
                  enableSuggestions: widget.enableSuggestions,
                  maxLines: widget.maxLines,
                  decoration: decoration,
                  onChanged: _onTextFieldChange,
                  onSubmitted: _onSubmitted,
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
