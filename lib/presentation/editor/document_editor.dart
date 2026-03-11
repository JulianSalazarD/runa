import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';
import 'package:runa/application/services/pdf_exporter.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'block_chrome.dart';
import 'block_widget.dart';
import 'ink_toolbar_widget.dart';

enum _InsertBlockType { markdown, ink, image, pdf }

class _SaveIntent extends Intent {
  const _SaveIntent();
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
    // Image and PDF page blocks always reference an asset — treat as having content.
    ImageBlock() => true,
    PdfPageBlock() => true,
  };
  if (!hasContent) {
    await notifier.removeBlock(block.id);
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
  if (confirmed == true) await notifier.removeBlock(block.id);
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

  /// Ink tool state — shown in the top toolbar when an ink/image block is selected.
  StrokeTool _inkTool = StrokeTool.pen;
  String _inkColor = '#000000FF';
  double _inkWidth = 2.0;

  /// Text element state for the ink canvas text tool.
  double _textFontSize = 16.0;
  bool _textBold = false;
  bool _textItalic = false;

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

  // -------------------------------------------------------------------------
  // Asset import helpers
  // -------------------------------------------------------------------------

  Future<void> _importImage({String? afterBlockId}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'gif'],
    );
    if (!mounted || result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    try {
      await ref
          .read(editorNotifierProvider(_docId).notifier)
          .importImage(path, afterBlockId: afterBlockId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar imagen: $e')),
      );
    }
  }

  Future<void> _exportToPdf() async {
    final document = ref.read(editorNotifierProvider(_docId)).document;
    final docPath = widget.opened.path;

    final savePath = await FilePicker.platform.saveFile(
      fileName: '${p.basenameWithoutExtension(docPath)}.pdf',
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );
    if (!mounted || savePath == null) return;

    try {
      final exporter = PdfExporter();
      final bytes = await exporter.export(document, documentPath: docPath);
      await File(savePath).writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exportado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar PDF: $e')),
      );
    }
  }

  Future<void> _importPdf({String? afterBlockId}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (!mounted || result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    try {
      await ref
          .read(editorNotifierProvider(_docId).notifier)
          .importPdf(path, afterBlockId: afterBlockId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorNotifierProvider(_docId));
    final notifier = ref.read(editorNotifierProvider(_docId).notifier);

    final selectedBlock = editorState.selectedBlockId == null
        ? null
        : editorState.blocks
            .where((b) => b.id == editorState.selectedBlockId)
            .firstOrNull;
    final showInkToolbar =
        selectedBlock is InkBlock || selectedBlock is ImageBlock;
    final InkBlock? selectedInkBlock =
        selectedBlock is InkBlock ? selectedBlock : null;

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
        child: Focus(
          focusNode: _editorFocusNode,
          autofocus: true,
          // Delete/Backspace are handled here instead of Shortcuts so that the
          // key is NOT consumed when a TextField (Markdown editor) has focus.
          // Shortcuts.consumesKey is true by default and would swallow the key
          // even when the action does nothing, breaking text editing.
          onKeyEvent: (_, event) {
            if (!_editorFocusNode.hasPrimaryFocus) return KeyEventResult.ignored;
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey != LogicalKeyboardKey.delete &&
                event.logicalKey != LogicalKeyboardKey.backspace) {
              return KeyEventResult.ignored;
            }
            final selectedId = editorState.selectedBlockId;
            if (selectedId == null) return KeyEventResult.ignored;
            final matches = editorState.blocks.where((b) => b.id == selectedId);
            if (matches.isEmpty) return KeyEventResult.ignored;
            _confirmAndDeleteBlock(context, matches.first, notifier);
            return KeyEventResult.handled;
          },
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
                  isImporting: editorState.isImporting,
                  autosaveMessage: editorState.autosaveMessage,
                  onSave: notifier.saveDocument,
                  onAddMarkdown: () => notifier.addBlock(
                    Block.markdown(id: _uuid.v4(), content: ''),
                  ),
                  onAddInk: () => notifier.addBlock(
                    Block.ink(id: _uuid.v4(), strokes: const [], height: 200.0),
                  ),
                  onAddImage: _importImage,
                  onAddPdf: _importPdf,
                  onExportPdf: _exportToPdf,
                  onGoHome: () =>
                      ref.read(workspaceNotifierProvider.notifier).closeDirectory(),
                  showInkToolbar: showInkToolbar,
                  inkTool: _inkTool,
                  inkColor: _inkColor,
                  inkWidth: _inkWidth,
                  onInkToolChanged: (t) => setState(() => _inkTool = t),
                  onInkColorChanged: (c) => setState(() => _inkColor = c),
                  onInkWidthChanged: (w) => setState(() => _inkWidth = w),
                  textFontSize: _textFontSize,
                  textBold: _textBold,
                  textItalic: _textItalic,
                  onTextFontSizeChanged: (double s) =>
                      setState(() => _textFontSize = s),
                  onTextBoldChanged: (bool v) => setState(() => _textBold = v),
                  onTextItalicChanged: (bool v) =>
                      setState(() => _textItalic = v),
                  inkBackground: selectedInkBlock?.background,
                  inkBackgroundSpacing: selectedInkBlock?.backgroundSpacing,
                  inkBackgroundLineColor: selectedInkBlock?.backgroundLineColor,
                  onInkBackgroundChanged: selectedInkBlock == null
                      ? null
                      : (bg) => notifier
                          .updateBlock(selectedInkBlock.copyWith(background: bg)),
                  onInkBackgroundSpacingChanged: selectedInkBlock == null
                      ? null
                      : (s) => notifier.updateBlock(
                          selectedInkBlock.copyWith(backgroundSpacing: s)),
                  onInkBackgroundLineColorChanged: selectedInkBlock == null
                      ? null
                      : (c) => notifier.updateBlock(
                          selectedInkBlock.copyWith(backgroundLineColor: c)),
                  inkBackgroundCanvasColor: selectedInkBlock?.backgroundColor,
                  onInkBackgroundCanvasColorChanged: selectedInkBlock == null
                      ? null
                      : (String? c) => notifier.updateBlock(
                          selectedInkBlock.copyWith(backgroundColor: c)),
                ),
                Expanded(
                  child: _BlockList(
                    editorState: editorState,
                    notifier: notifier,
                    onImportImage: ({String? afterBlockId}) =>
                        _importImage(afterBlockId: afterBlockId),
                    onImportPdf: ({String? afterBlockId}) =>
                        _importPdf(afterBlockId: afterBlockId),
                    inkTool: _inkTool,
                    inkColor: _inkColor,
                    inkWidth: _inkWidth,
                    textFontSize: _textFontSize,
                    textBold: _textBold,
                    textItalic: _textItalic,
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
    required this.isImporting,
    required this.autosaveMessage,
    required this.onSave,
    required this.onAddMarkdown,
    required this.onAddInk,
    required this.onAddImage,
    required this.onAddPdf,
    required this.onExportPdf,
    required this.onGoHome,
    required this.showInkToolbar,
    required this.inkTool,
    required this.inkColor,
    required this.inkWidth,
    required this.onInkToolChanged,
    required this.onInkColorChanged,
    required this.onInkWidthChanged,
    this.inkBackground,
    this.inkBackgroundSpacing,
    this.inkBackgroundLineColor,
    this.inkBackgroundCanvasColor,
    this.onInkBackgroundChanged,
    this.onInkBackgroundSpacingChanged,
    this.onInkBackgroundLineColorChanged,
    this.onInkBackgroundCanvasColorChanged,
    required this.textFontSize,
    required this.textBold,
    required this.textItalic,
    required this.onTextFontSizeChanged,
    required this.onTextBoldChanged,
    required this.onTextItalicChanged,
  });

  final String path;
  final bool isDirty;
  final bool isImporting;
  final bool autosaveMessage;
  final VoidCallback onSave;
  final VoidCallback onAddMarkdown;
  final VoidCallback onAddInk;
  final VoidCallback onAddImage;
  final VoidCallback onAddPdf;
  final VoidCallback onExportPdf;
  final VoidCallback onGoHome;
  final bool showInkToolbar;
  final StrokeTool inkTool;
  final String inkColor;
  final double inkWidth;
  final ValueChanged<StrokeTool> onInkToolChanged;
  final ValueChanged<String> onInkColorChanged;
  final ValueChanged<double> onInkWidthChanged;
  final InkBackground? inkBackground;
  final double? inkBackgroundSpacing;
  final String? inkBackgroundLineColor;
  final String? inkBackgroundCanvasColor;
  final ValueChanged<InkBackground>? onInkBackgroundChanged;
  final ValueChanged<double>? onInkBackgroundSpacingChanged;
  final ValueChanged<String>? onInkBackgroundLineColorChanged;
  final ValueChanged<String?>? onInkBackgroundCanvasColorChanged;
  final double textFontSize;
  final bool textBold;
  final bool textItalic;
  final ValueChanged<double> onTextFontSizeChanged;
  final ValueChanged<bool> onTextBoldChanged;
  final ValueChanged<bool> onTextItalicChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Menú principal',
                onPressed: onGoHome,
                iconSize: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    p.basenameWithoutExtension(path),
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (autosaveMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'Guardado automáticamente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              else if (isDirty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '●',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary),
                    semanticsLabel: 'Cambios sin guardar',
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: 'Exportar a PDF',
                onPressed: onExportPdf,
                iconSize: 20,
              ),
              PopupMenuButton<_InsertBlockType>(
                icon: const Icon(Icons.add),
                tooltip: 'Nuevo bloque al final',
                onSelected: (type) {
                  switch (type) {
                    case _InsertBlockType.markdown:
                      onAddMarkdown();
                    case _InsertBlockType.ink:
                      onAddInk();
                    case _InsertBlockType.image:
                      onAddImage();
                    case _InsertBlockType.pdf:
                      onAddPdf();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _InsertBlockType.markdown,
                    child: Text('Texto (Markdown)'),
                  ),
                  PopupMenuItem(
                    value: _InsertBlockType.ink,
                    child: Text('Escritura a mano (Ink)'),
                  ),
                  PopupMenuItem(
                    value: _InsertBlockType.image,
                    child: Text('Imagen'),
                  ),
                  PopupMenuItem(
                    value: _InsertBlockType.pdf,
                    child: Text('PDF'),
                  ),
                ],
              ),
              TextButton(
                onPressed: onSave,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
        if (showInkToolbar)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: InkToolbarWidget(
              activeTool: inkTool,
              activeColor: inkColor,
              activeWidth: inkWidth,
              onToolChanged: onInkToolChanged,
              onColorChanged: onInkColorChanged,
              onWidthChanged: onInkWidthChanged,
              activeBackground: inkBackground,
              backgroundSpacing: inkBackgroundSpacing,
              backgroundLineColor: inkBackgroundLineColor,
              backgroundCanvasColor: inkBackgroundCanvasColor,
              onBackgroundChanged: onInkBackgroundChanged,
              onBackgroundSpacingChanged: onInkBackgroundSpacingChanged,
              onBackgroundLineColorChanged: onInkBackgroundLineColorChanged,
              onBackgroundCanvasColorChanged: onInkBackgroundCanvasColorChanged,
              textFontSize: textFontSize,
              textBold: textBold,
              textItalic: textItalic,
              onTextFontSizeChanged: onTextFontSizeChanged,
              onTextBoldChanged: onTextBoldChanged,
              onTextItalicChanged: onTextItalicChanged,
            ),
          ),
        if (isImporting) const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Block list
// ---------------------------------------------------------------------------

class _BlockList extends StatelessWidget {
  const _BlockList({
    required this.editorState,
    required this.notifier,
    required this.onImportImage,
    required this.onImportPdf,
    required this.inkTool,
    required this.inkColor,
    required this.inkWidth,
    required this.textFontSize,
    required this.textBold,
    required this.textItalic,
  });

  final EditorState editorState;
  final EditorNotifier notifier;
  final Future<void> Function({String? afterBlockId}) onImportImage;
  final Future<void> Function({String? afterBlockId}) onImportPdf;
  final StrokeTool inkTool;
  final String inkColor;
  final double inkWidth;
  final double textFontSize;
  final bool textBold;
  final bool textItalic;

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
                documentPath: editorState.path,
                isSelected: isSelected,
                onUpdate: notifier.updateBlock,
                autoFocus: autoFocus,
                onEnterAtEnd: () => notifier.addBlock(
                  Block.markdown(id: const Uuid().v4(), content: ''),
                  afterId: block.id,
                ),
                inkTool: inkTool,
                inkColor: inkColor,
                inkWidth: inkWidth,
                textFontSize: textFontSize,
                textBold: textBold,
                textItalic: textItalic,
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
              onInsertImage: () =>
                  onImportImage(afterBlockId: block.id),
              onInsertPdf: () =>
                  onImportPdf(afterBlockId: block.id),
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
    required this.onInsertImage,
    required this.onInsertPdf,
  });

  final VoidCallback onInsertMarkdown;
  final VoidCallback onInsertInk;
  final VoidCallback onInsertImage;
  final VoidCallback onInsertPdf;

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
        PopupMenuItem(
          value: _InsertBlockType.image,
          child: Text('Imagen'),
        ),
        PopupMenuItem(
          value: _InsertBlockType.pdf,
          child: Text('PDF'),
        ),
      ],
    );
    if (!mounted) return;
    switch (result) {
      case _InsertBlockType.markdown:
        widget.onInsertMarkdown();
      case _InsertBlockType.ink:
        widget.onInsertInk();
      case _InsertBlockType.image:
        widget.onInsertImage();
      case _InsertBlockType.pdf:
        widget.onInsertPdf();
      case null:
        break;
    }
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
