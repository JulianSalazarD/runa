import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'block_chrome.dart';
import 'block_widget.dart';

class _SaveIntent extends Intent {
  const _SaveIntent();
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

  String get _docId => widget.opened.document.id;

  @override
  void initState() {
    super.initState();
    _initEditor();
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
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              notifier.saveDocument();
              return null;
            },
          ),
        },
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

    // Interleave blocks with insert gaps.
    // Index layout for N blocks → 2N items:
    //   even i: block[i÷2]
    //   odd  i: gap after block[i÷2] (inserts afterId = block[i÷2].id)
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: blocks.length * 2,
      itemBuilder: (context, index) {
        final blockIndex = index ~/ 2;
        if (index.isOdd) {
          return _InsertGap(
            onInsert: () => notifier.addBlock(
              Block.markdown(id: const Uuid().v4(), content: ''),
              afterId: blocks[blockIndex].id,
            ),
          );
        }
        final block = blocks[blockIndex];
        return BlockChrome(
          key: ValueKey(block.id),
          isSelected: editorState.selectedBlockId == block.id,
          onTap: () => notifier.setSelectedBlock(block.id),
          onDelete: () => notifier.removeBlock(block.id),
          child: BlockWidget(
            block: block,
            onUpdate: notifier.updateBlock,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Insert gap (shown between blocks and after the last one)
// ---------------------------------------------------------------------------

class _InsertGap extends StatefulWidget {
  const _InsertGap({required this.onInsert});

  final VoidCallback onInsert;

  @override
  State<_InsertGap> createState() => _InsertGapState();
}

class _InsertGapState extends State<_InsertGap> {
  bool _hovered = false;

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
            child: InkWell(
              onTap: widget.onInsert,
              borderRadius: BorderRadius.circular(12),
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
    );
  }
}
