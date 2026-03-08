import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

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
      InkBlock(:final height) => _InkPlaceholder(height: height),
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
// InkBlock placeholder (replaced in Fase 2 Parte 4)
// ---------------------------------------------------------------------------

class _InkPlaceholder extends StatelessWidget {
  const _InkPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'Canvas de tinta (Fase 2, Parte 4)',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
