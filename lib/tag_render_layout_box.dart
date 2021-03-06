import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './tag_editor_layout_delegate.dart';

/// Got inspiration from below, but did not want to override a bunch of things
/// https://gist.github.com/slightfoot/0ddf14dd0f77e5be4c6b8904d3a2df67
class TagRenderLayoutBox extends RenderCustomMultiChildLayoutBox {
  TagRenderLayoutBox({
    List<RenderBox>? children,
    required TagEditorLayoutDelegate delegate,
    this.afterFirstLayout,
  }) : super(children: children, delegate: delegate);

  final ValueChanged<Size>? afterFirstLayout;

  bool _didFinishedFirstLayout = false;

  @override
  void performLayout() {
    super.performLayout();
    //* Set the parent size here
    final tagEditorLayoutDelegate = delegate as TagEditorLayoutDelegate;
    size = tagEditorLayoutDelegate.parentSize;
    if (!_didFinishedFirstLayout) {
      _didFinishedFirstLayout = true;
      afterFirstLayout?.call(size);
    }
  }
}
