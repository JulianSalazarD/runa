import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'block_chrome.dart';
import 'block_widget.dart';

enum _InsertBlockType { markdown, ink }

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _DeleteBlockIntent extends Intent {
  const _DeleteBlockIntent();
}

/// Shows a confirmation dialog before deleting a block that has content.
/// Deletes immediately (no dialog) when the block is empty.
Future<void> _confirmAndDeleteBlock(
  BuildContext context,
  Block block,
  EditorNotifier notifier,
) async {
  final hasContent = switch (block) {
    final MarkdownBlock b => b.content.isNotEmpty,
    final InkBlock b => b.strokes.isNotEmpty,
  };
  if (!hasContent) {
    notifier.removeBlock(block.id);
    return;
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar bloque'),
      content: const Text('¿Eliminar este bloque?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  if (confirmed == true) notifier.removeBlock(block.id);
}

/// The real document editor, replacing [DocumentEditorPlaceholder].
///
/// Initialises [EditorNotifier] from the already-loaded [opened] document
/// (no extra disk read) and renders the block list with [BlockChrome] +
/// [BlockWidget] wrappers.
class DocumentEditor extends ConsumerStatefulWidget {
  const DocumentEditor({super.key, required this.opened});

  final OpenedDocument opened;

  @override
  ConsumerState<DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends ConsumerState<DocumentEditor> {
  static const _uuid = Uuid();

  /// Focus node for the editor canvas. Holds focus when no TextField is active,
  /// allowing Delete/Backspace shortcuts to fire on the selected block.
  late final FocusNode _editorFocusNode;

  String get _docId => widget.opened.document.id;

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'EditorCanvas');
    _initEditor();
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DocumentEditor old) {
    super.didUpdateWidget(old);
    if (old.opened.document.id != _docId) {
      _initEditor();
    }
  }

  void _initEditor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(editorNotifierProvider(_docId).notifier)
          .initFromDocument(widget.opened.document, widget.opened.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorNotifierProvider(_docId));
    final notifier = ref.read(editorNotifierProvider(_docId).notifier);

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
        SingleActivator(LogicalKeyboardKey.delete): _DeleteBlockIntent(),
        SingleActivator(LogicalKeyboardKey.backspace): _DeleteBlockIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              notifier.saveDocument();
              return null;
            },
          ),
          _DeleteBlockIntent: CallbackAction<_DeleteBlockIntent>(
            onInvoke: (_) {
              final selectedId = editorState.selectedBlockId;
              if (selectedId == null) return null;
              final matches =
                  editorState.blocks.where((b) => b.id == selectedId);
              if (matches.isEmpty) return null;
              _confirmAndDeleteBlock(context, matches.first, notifier);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _editorFocusNode,
          autofocus: true,
          child: GestureDetector(
            // Tapping the canvas (outside any block) deselects and refocuses
            // the editor so Delete/Backspace shortcuts remain available.
            onTap: () {
              notifier.setSelectedBlock(null);
              _editorFocusNode.requestFocus();
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EditorToolbar(
                  path: widget.opened.path,
                  isDirty: editorState.isDirty,
                  onSave: notifier.saveDocument,
                  onAddBlock: () => notifier.addBlock(
                    Block.markdown(id: _uuid.v4(), content: ''),
                  ),
                ),
                Expanded(
                  child: _BlockList(
                    editorState: editorState,
                    notifier: notifier,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.path,
    required this.isDirty,
    required this.onSave,
    required this.onAddBlock,
  });

  final String path;
  final bool isDirty;
  final VoidCallback onSave;
  final VoidCallback onAddBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.basenameWithoutExtension(path),
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '●',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                semanticsLabel: 'Cambios sin guardar',
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo bloque al final',
            onPressed: onAddBlock,
          ),
          TextButton(
            onPressed: onSave,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Block list
// ---------------------------------------------------------------------------

class _BlockList extends StatelessWidget {
  const _BlockList({required this.editorState, required this.notifier});

  final EditorState editorState;
  final EditorNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final blocks = editorState.blocks;

    if (blocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Sin bloques. Pulsa "+" para añadir uno.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Each item in the ReorderableListView is a Column that contains:
    //   • BlockChrome (with drag handle wired to ReorderableDragStartListener)
    //   • _InsertGap  (insert a new block immediately after this one)
    //
    // onReorder adjusts newIndex for removal and delegates to moveBlock.
    void onReorder(int oldIndex, int newIndex) {
      if (newIndex > oldIndex) newIndex--;
      notifier.moveBlock(blocks[oldIndex].id, newIndex);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      buildDefaultDragHandles: false,
      onReorder: onReorder,
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isSelected = editorState.selectedBlockId == block.id;
        // Auto-focus newly inserted empty MarkdownBlocks (selected + empty).
        final autoFocus = isSelected &&
            block is MarkdownBlock &&
            block.content.isEmpty;
        return Column(
          key: ValueKey(block.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlockChrome(
              isSelected: isSelected,
              // Only enable drag when there is more than one block.
              dragIndex: blocks.length > 1 ? index : null,
              onTap: () => notifier.setSelectedBlock(block.id),
              onDelete: () =>
                  _confirmAndDeleteBlock(context, block, notifier),
              child: BlockWidget(
                block: block,
                onUpdate: notifier.updateBlock,
                autoFocus: autoFocus,
                onEnterAtEnd: () => notifier.addBlock(
                  Block.markdown(id: const Uuid().v4(), content: ''),
                  afterId: block.id,
                ),
              ),
            ),
            _InsertGap(
              onInsertMarkdown: () => notifier.addBlock(
                Block.markdown(id: const Uuid().v4(), content: ''),
                afterId: block.id,
              ),
              onInsertInk: () => notifier.addBlock(
                Block.ink(
                  id: const Uuid().v4(),
                  strokes: const [],
                  height: 200.0,
                ),
                afterId: block.id,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Insert gap (shown between blocks and after the last one)
// ---------------------------------------------------------------------------

class _InsertGap extends StatefulWidget {
  const _InsertGap({
    required this.onInsertMarkdown,
    required this.onInsertInk,
  });

  final VoidCallback onInsertMarkdown;
  final VoidCallback onInsertInk;

  @override
  State<_InsertGap> createState() => _InsertGapState();
}

class _InsertGapState extends State<_InsertGap> {
  bool _hovered = false;

  Future<void> _showMenu(BuildContext context, Offset globalPosition) async {
    final result = await showMenu<_InsertBlockType>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: const [
        PopupMenuItem(
          value: _InsertBlockType.markdown,
          child: Text('Texto (Markdown)'),
        ),
        PopupMenuItem(
          value: _InsertBlockType.ink,
          child: Text('Escritura a mano (Ink)'),
        ),
      ],
    );
    if (!mounted) return;
    if (result == _InsertBlockType.markdown) widget.onInsertMarkdown();
    if (result == _InsertBlockType.ink) widget.onInsertInk();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        height: 24,
        child: Center(
          child: AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Tooltip(
              message: 'Insertar bloque',
              child: GestureDetector(
                onTapDown: (d) => _showMenu(context, d.globalPosition),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
