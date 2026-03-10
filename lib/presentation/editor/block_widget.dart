import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:runa/domain/domain.dart';

import 'ink_annotation_layer.dart';
import 'ink_canvas_widget.dart';
import 'markdown/task_list_extension.dart';
import 'markdown_editor_widget.dart';
import 'markdown_preview_widget.dart';
import 'pdf_page_block_view.dart';

/// Dispatches to the appropriate block renderer based on [block] type.
///
/// [onUpdate] is called when the user edits the block content. Callers
/// should forward this to [EditorNotifier.updateBlock].
///
/// [onEnterAtEnd] is forwarded to [MarkdownEditorWidget]: pressing Enter
/// on an empty last line triggers this callback so the caller can insert
/// a new block below.
///
/// [autoFocus] requests immediate focus on the inner editor when the
/// widget is first built (useful for newly inserted blocks).
///
/// [documentPath] is needed by [ImageBlock] to resolve asset paths relative
/// to the `.runa` file location.
///
/// [isSelected] controls whether ink annotation layers accept pointer input.
class BlockWidget extends StatelessWidget {
  const BlockWidget({
    super.key,
    required this.block,
    this.documentPath = '',
    this.isSelected = false,
    this.onUpdate,
    this.onEnterAtEnd,
    this.autoFocus = false,
    this.inkTool = StrokeTool.pen,
    this.inkColor = '#000000FF',
    this.inkWidth = 2.0,
  });

  final Block block;

  /// Absolute path to the `.runa` file. Used to resolve relative asset paths.
  final String documentPath;

  /// When `true`, ink annotation layers accept pointer input.
  final bool isSelected;

  final ValueChanged<Block>? onUpdate;
  final VoidCallback? onEnterAtEnd;
  final bool autoFocus;

  /// Ink tool settings managed by the parent (shown in the top toolbar).
  final StrokeTool inkTool;
  final String inkColor;
  final double inkWidth;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      final MarkdownBlock b => _MarkdownBlockView(
          block: b,
          onUpdate: onUpdate,
          onEnterAtEnd: onEnterAtEnd,
          autoFocus: autoFocus,
        ),
      final InkBlock b => _InkBlockView(
          block: b,
          onUpdate: onUpdate,
          activeTool: inkTool,
          activeColor: inkColor,
          activeWidth: inkWidth,
        ),
      final ImageBlock b => _ImageBlockView(
          block: b,
          documentPath: documentPath,
          isSelected: isSelected,
          onUpdate: onUpdate,
          activeTool: inkTool,
          activeColor: inkColor,
          activeWidth: inkWidth,
        ),
      final PdfPageBlock b => PdfPageBlockView(
          block: b,
          documentPath: documentPath,
          isSelected: isSelected,
          onUpdate: onUpdate,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Markdown block: edit / preview modes
// ---------------------------------------------------------------------------

class _MarkdownBlockView extends StatefulWidget {
  const _MarkdownBlockView({
    required this.block,
    this.onUpdate,
    this.onEnterAtEnd,
    this.autoFocus = false,
  });

  final MarkdownBlock block;
  final ValueChanged<Block>? onUpdate;
  final VoidCallback? onEnterAtEnd;
  final bool autoFocus;

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

  static String _wordCountText(String text) {
    final trimmed = text.trim();
    final words =
        trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
    return '$words ${words == 1 ? 'palabra' : 'palabras'} · ${text.length} caracteres';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isEditing) ...[
          MarkdownEditorWidget(
            key: ValueKey('editor_${widget.block.id}'),
            initialContent: widget.block.content,
            onChanged: (content) =>
                widget.onUpdate?.call(widget.block.copyWith(content: content)),
            autoFocus: widget.autoFocus,
            onEnterAtEnd: widget.onEnterAtEnd,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              _wordCountText(widget.block.content),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ] else
          MarkdownPreviewWidget(
            content: widget.block.content,
            onCheckboxToggled: widget.onUpdate == null
                ? null
                : (idx, checked) {
                    final newContent = toggleCheckboxAt(
                      widget.block.content,
                      idx,
                      checked,
                    );
                    widget.onUpdate!(widget.block.copyWith(content: newContent));
                  },
          ),
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
  const _InkBlockView({
    required this.block,
    this.onUpdate,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
  });

  final InkBlock block;
  final ValueChanged<Block>? onUpdate;
  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;

  @override
  State<_InkBlockView> createState() => _InkBlockViewState();
}

class _InkBlockViewState extends State<_InkBlockView> {
  static const _minHeight = 80.0;

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
        InkCanvasWidget(
          block: widget.block,
          height: _height,
          activeTool: widget.activeTool,
          activeColor: widget.activeColor,
          activeWidth: widget.activeWidth,
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
// ImageBlock: image + ink annotation layer
// ---------------------------------------------------------------------------

class _ImageBlockView extends StatelessWidget {
  const _ImageBlockView({
    required this.block,
    required this.documentPath,
    required this.isSelected,
    this.onUpdate,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
  });

  final ImageBlock block;

  /// Absolute path to the `.runa` file. Used to resolve the relative asset
  /// path stored in [block.path].
  final String documentPath;

  /// When `true`, the [InkAnnotationLayer] accepts pointer input.
  final bool isSelected;

  final ValueChanged<Block>? onUpdate;
  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;

  @override
  Widget build(BuildContext context) {
    final absolutePath =
        p.join(p.dirname(documentPath), block.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: block.strokes.isEmpty
                ? null
                : () => onUpdate?.call(block.copyWith(strokes: const [])),
            icon: const Icon(Icons.clear, size: 14),
            label: const Text(
              'Limpiar anotaciones',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: block.naturalWidth / block.naturalHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(absolutePath),
                fit: BoxFit.fill,
                errorBuilder: (ctx, error, _) =>
                    _ImageErrorPlaceholder(path: block.path),
              ),
              InkAnnotationLayer(
                strokes: block.strokes,
                onStrokesChanged: (strokes) =>
                    onUpdate?.call(block.copyWith(strokes: strokes)),
                activeTool: activeTool,
                activeColor: activeColor,
                activeWidth: activeWidth,
                readOnly: !isSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 32, color: colorScheme.outline),
          const SizedBox(height: 4),
          Text(
            path,
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
