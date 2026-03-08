import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

import 'ink_canvas_widget.dart';
import 'ink_toolbar_widget.dart';
import 'markdown_editor_widget.dart';
import 'markdown_preview_widget.dart';

/// Dispatches to the appropriate block renderer based on [block] type.
///
/// [onUpdate] is called when the user edits the block content. Callers
/// should forward this to [EditorNotifier.updateBlock].
class BlockWidget extends StatelessWidget {
  const BlockWidget({
    super.key,
    required this.block,
    this.onUpdate,
  });

  final Block block;
  final ValueChanged<Block>? onUpdate;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      final MarkdownBlock b => _MarkdownBlockView(block: b, onUpdate: onUpdate),
      final InkBlock b => _InkBlockView(block: b, onUpdate: onUpdate),
    };
  }
}

// ---------------------------------------------------------------------------
// Markdown block: edit / preview modes
// ---------------------------------------------------------------------------

class _MarkdownBlockView extends StatefulWidget {
  const _MarkdownBlockView({required this.block, this.onUpdate});

  final MarkdownBlock block;
  final ValueChanged<Block>? onUpdate;

  @override
  State<_MarkdownBlockView> createState() => _MarkdownBlockViewState();
}

class _MarkdownBlockViewState extends State<_MarkdownBlockView> {
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    // Empty blocks (new) start in edit mode; blocks with content in preview.
    _isEditing = widget.block.content.isEmpty;
  }

  void _toggle() => setState(() => _isEditing = !_isEditing);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditing)
          MarkdownEditorWidget(
            key: ValueKey('editor_${widget.block.id}'),
            initialContent: widget.block.content,
            onChanged: (content) =>
                widget.onUpdate?.call(widget.block.copyWith(content: content)),
          )
        else
          MarkdownPreviewWidget(content: widget.block.content),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _toggle,
            icon: Icon(
              _isEditing ? Icons.visibility_outlined : Icons.edit_outlined,
              size: 14,
            ),
            label: Text(
              _isEditing ? 'Vista previa' : 'Editar',
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// InkBlock: toolbar + canvas + resize handle
// ---------------------------------------------------------------------------

class _InkBlockView extends StatefulWidget {
  const _InkBlockView({required this.block, this.onUpdate});

  final InkBlock block;
  final ValueChanged<Block>? onUpdate;

  @override
  State<_InkBlockView> createState() => _InkBlockViewState();
}

class _InkBlockViewState extends State<_InkBlockView> {
  static const _minHeight = 80.0;

  StrokeTool _activeTool = StrokeTool.pen;
  String _activeColor = '#000000FF';
  double _activeWidth = 3.0;

  late double _height;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _height = widget.block.height;
  }

  @override
  void didUpdateWidget(_InkBlockView old) {
    super.didUpdateWidget(old);
    // Sync height only when not mid-drag to avoid jerky updates.
    if (!_isDragging && old.block.height != widget.block.height) {
      _height = widget.block.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkToolbarWidget(
          activeTool: _activeTool,
          activeColor: _activeColor,
          activeWidth: _activeWidth,
          onToolChanged: (t) => setState(() => _activeTool = t),
          onColorChanged: (c) => setState(() => _activeColor = c),
          onWidthChanged: (w) => setState(() => _activeWidth = w),
        ),
        InkCanvasWidget(
          block: widget.block,
          height: _height,
          activeTool: _activeTool,
          activeColor: _activeColor,
          activeWidth: _activeWidth,
          onUpdate: (updated) => widget.onUpdate?.call(updated),
        ),
        _ResizeHandle(
          onDragStart: (_) => setState(() => _isDragging = true),
          onDragUpdate: (d) => setState(() {
            _height =
                (_height + d.delta.dy).clamp(_minHeight, double.infinity);
          }),
          onDragEnd: (_) {
            _isDragging = false;
            widget.onUpdate?.call(widget.block.copyWith(height: _height));
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ResizeHandle
// ---------------------------------------------------------------------------

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        child: SizedBox(
          height: 10,
          child: Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
