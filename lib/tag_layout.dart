import 'package:flutter/material.dart';
import './tag_editor_layout_delegate.dart';
import './tag_render_layout_box.dart';

/// This is just a normal [CustomMultiChildLayout] with
/// overrided [createRenderObject] to use custom [RenderCustomMultiChildLayoutBox]
class TagLayout extends CustomMultiChildLayout {
  TagLayout({
    Key? key,
    required TagEditorLayoutDelegate delegate,
    List<Widget> children = const <Widget>[],
    this.afterFirstLayout,
  }) : super(key: key, children: children, delegate: delegate);

  final ValueChanged<Size>? afterFirstLayout;

  @override
  TagRenderLayoutBox createRenderObject(BuildContext context) {
    return TagRenderLayoutBox(
      delegate: delegate as TagEditorLayoutDelegate,
      afterFirstLayout: afterFirstLayout,
    );
  }
}
