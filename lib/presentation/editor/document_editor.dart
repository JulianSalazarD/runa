import 'dart:async' show unawaited;
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:runa/application/application.dart';
import 'package:runa/application/services/pdf_exporter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'block_chrome.dart';
import 'block_widget.dart';
import 'ink_toolbar_widget.dart';
import 'selection_mode.dart';
import '../home/sidebar/name_input_dialog.dart';
import '../utils/linux_file_picker.dart';

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
  late String _inkColor;
  late double _inkWidth;

  /// Text element state for the ink canvas text tool.
  double _textFontSize = 16.0;
  bool _textBold = false;
  bool _textItalic = false;

  /// Active geometric shape tool. Null = no shape tool active.
  ShapeType? _inkShapeType;

  /// Active selection sub-mode. Null = selection tool not active.
  SelectionMode? _selectionMode;

  String get _docId => widget.opened.document.id;

  /// Converts a [Color] to the `#RRGGBBAA` hex format used by ink strokes.
  static String _colorToHex(Color color) {
    final v = color.toARGB32(); // 0xAARRGGBB
    final a = (v >> 24) & 0xFF;
    final r = (v >> 16) & 0xFF;
    final g = (v >> 8) & 0xFF;
    final b = v & 0xFF;
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'
        '${a.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'EditorCanvas');
    final settings = ref.read(settingsProvider);
    _inkColor = _colorToHex(settings.defaultInkColor);
    _inkWidth = settings.defaultInkStrokeWidth;
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
          .read(editorProvider(_docId).notifier)
          .initFromDocument(widget.opened.document, widget.opened.path);
    });
  }

  Future<void> _renameDocument() async {
    final oldPath = widget.opened.path;
    final currentName = p.basenameWithoutExtension(oldPath);
    final dir = p.dirname(oldPath);

    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(dir);
    final existingNames = entries
        .where((e) => !e.isDirectory)
        .map((e) => p.basenameWithoutExtension(e.path))
        .where((n) => n != currentName)
        .toSet();

    if (!mounted) return;
    final name = await showNameInputDialog(
      context,
      title: 'Renombrar',
      hint: currentName,
      initial: currentName,
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty || name == currentName) return;

    final newPath = p.join(dir, '$name.runa');
    await ref
        .read(workspaceProvider.notifier)
        .renameDocument(oldPath, newPath);
  }

  // -------------------------------------------------------------------------
  // Asset import helpers
  // -------------------------------------------------------------------------

  Future<void> _importImage({String? afterBlockId}) async {
    List<String>? paths;
    try {
      paths = await LinuxFilePicker.pickFiles(
        extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif'],
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (!mounted || paths == null) return;
    final path = paths.first;
    try {
      await ref
          .read(editorProvider(_docId).notifier)
          .importImage(path, afterBlockId: afterBlockId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar imagen: $e')),
      );
    }
  }

  Future<void> _exportToPdf() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _exportToPdfMobile();
    } else {
      await _exportToPdfDesktop();
    }
  }

  Future<void> _exportToPdfMobile() async {
    final document = ref.read(editorProvider(_docId)).document;
    final docPath = widget.opened.path;
    final defaultName = '${p.basenameWithoutExtension(docPath)}.pdf';

    final progress = ValueNotifier<(int, int)>((0, 0));

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildProgressDialog(progress),
    ));

    late final Uint8List bytes;
    try {
      final exporter = PdfExporter();
      bytes = await exporter.export(
        document,
        documentPath: docPath,
        onProgress: (current, total) {
          progress.value = (current, total);
        },
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      progress.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar PDF: $e')),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
    progress.dispose();

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$defaultName');
    await tempFile.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(tempFile.path, mimeType: 'application/pdf')],
      subject: defaultName,
    );
  }

  Future<void> _exportToPdfDesktop() async {
    final document = ref.read(editorProvider(_docId)).document;
    final docPath = widget.opened.path;
    final defaultName = '${p.basenameWithoutExtension(docPath)}.pdf';

    String? savePath;
    try {
      savePath = await LinuxFilePicker.saveFile(
        defaultName: defaultName,
        extension: 'pdf',
        fallbackDir: p.dirname(docPath),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (!mounted || savePath == null) return;

    final progress = ValueNotifier<(int, int)>((0, 0));

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildProgressDialog(progress),
    ));

    try {
      final exporter = PdfExporter();
      final bytes = await exporter.export(
        document,
        documentPath: docPath,
        onProgress: (current, total) {
          progress.value = (current, total);
        },
      );
      await File(savePath).writeAsBytes(bytes);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      progress.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar PDF: $e')),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
    progress.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF exportado: $savePath')),
    );
  }

  Widget _buildProgressDialog(ValueNotifier<(int, int)> progress) {
    return ValueListenableBuilder(
      valueListenable: progress,
      builder: (ctx, value, _) {
        final (current, total) = value;
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Exportando PDF…'),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: total > 0 ? current / total : null,
              ),
              if (total > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Bloque $current de $total',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importPdf({String? afterBlockId}) async {
    List<String>? paths;
    try {
      paths = await LinuxFilePicker.pickFiles(extensions: ['pdf']);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (!mounted || paths == null) return;
    final path = paths.first;
    try {
      await ref
          .read(editorProvider(_docId).notifier)
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
    final editorState = ref.watch(editorProvider(_docId));
    final notifier = ref.read(editorProvider(_docId).notifier);

    final selectedBlock = editorState.selectedBlockId == null
        ? null
        : editorState.blocks
            .where((b) => b.id == editorState.selectedBlockId)
            .firstOrNull;
    final showInkToolbar = selectedBlock is InkBlock ||
        selectedBlock is ImageBlock ||
        selectedBlock is PdfPageBlock;
    // Shapes, selection and background options are only available for ink blocks.
    final showAdvancedTools = selectedBlock is InkBlock;
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
                  onRename: _renameDocument,
                  onAddMarkdown: () => notifier.addBlock(
                    Block.markdown(id: _uuid.v4(), content: ''),
                  ),
                  onAddInk: () {
                    final s = ref.read(settingsProvider);
                    notifier.addBlock(Block.ink(
                      id: _uuid.v4(),
                      height: 200.0,
                      background: s.defaultInkBackground,
                      backgroundSpacing: s.defaultBackgroundSpacing,
                      backgroundColor: s.defaultCanvasBackground != null
                          ? _colorToHex(s.defaultCanvasBackground!)
                          : null,
                      backgroundLineColor: s.defaultLineColor != null
                          ? _colorToHex(s.defaultLineColor!)
                          : null,
                    ));
                  },
                  onAddImage: _importImage,
                  onAddPdf: _importPdf,
                  onExportPdf: _exportToPdf,
                  onGoHome: () =>
                      ref.read(workspaceProvider.notifier).closeDirectory(),
                  showInkToolbar: showInkToolbar,
                  inkTool: _inkTool,
                  inkColor: _inkColor,
                  inkWidth: _inkWidth,
                  onInkToolChanged: (t) => setState(() {
                    _inkTool = t;
                    _inkShapeType = null;
                    _selectionMode = null;
                  }),
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
                  inkShapeType: _inkShapeType,
                  onInkShapeTypeChanged: showAdvancedTools
                      ? (ShapeType? t) => setState(() {
                            _inkShapeType = t;
                            if (t != null) _selectionMode = null;
                          })
                      : null,
                  inkSelectionMode: _selectionMode,
                  onInkSelectionModeChanged: showAdvancedTools
                      ? (SelectionMode? m) => setState(() {
                            _selectionMode = m;
                            if (m != null) _inkShapeType = null;
                          })
                      : null,
                  stylusOnly: ref.read(settingsProvider).stylusOnlyMode,
                  onStylusOnlyToggle: () {
                    final s = ref.read(settingsProvider);
                    ref.read(settingsProvider.notifier).update(
                          s.copyWith(stylusOnlyMode: !s.stylusOnlyMode),
                        );
                  },
                ),
                Expanded(
                  child: _BlockList(
                    editorState: editorState,
                    notifier: notifier,
                    onImportImage: _importImage,
                    onImportPdf: _importPdf,
                    inkTool: _inkTool,
                    inkColor: _inkColor,
                    inkWidth: _inkWidth,
                    textFontSize: _textFontSize,
                    textBold: _textBold,
                    textItalic: _textItalic,
                    inkShapeType: _inkShapeType,
                    inkSelectionMode: _selectionMode,
                    defaultInkBackground: ref.watch(settingsProvider).defaultInkBackground,
                    defaultCanvasBackgroundHex: ref.watch(settingsProvider).defaultCanvasBackground != null
                        ? _colorToHex(ref.watch(settingsProvider).defaultCanvasBackground!)
                        : null,
                    defaultLineColorHex: ref.watch(settingsProvider).defaultLineColor != null
                        ? _colorToHex(ref.watch(settingsProvider).defaultLineColor!)
                        : null,
                    markdownFontFamily: ref.watch(settingsProvider).markdownFontFamily,
                    markdownFontSize: ref.watch(settingsProvider).markdownFontSize,
                    stylusOnly: ref.watch(settingsProvider).stylusOnlyMode,
                    eraserRadius: ref.watch(settingsProvider).defaultEraserRadius,
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
    required this.onRename,
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
    this.inkShapeType,
    this.onInkShapeTypeChanged,
    this.inkSelectionMode,
    this.onInkSelectionModeChanged,
    this.stylusOnly = false,
    this.onStylusOnlyToggle,
  });

  final String path;
  final bool isDirty;
  final bool isImporting;
  final bool autosaveMessage;
  final VoidCallback onSave;
  final VoidCallback onRename;
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
  final ShapeType? inkShapeType;
  final ValueChanged<ShapeType?>? onInkShapeTypeChanged;
  final SelectionMode? inkSelectionMode;
  final ValueChanged<SelectionMode?>? onInkSelectionModeChanged;
  final bool stylusOnly;
  final VoidCallback? onStylusOnlyToggle;

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
              IconButton(
                icon: const Icon(Icons.drive_file_rename_outline),
                tooltip: 'Renombrar',
                onPressed: onRename,
                iconSize: 20,
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
              if (Platform.isAndroid || Platform.isIOS)
                IconButton(
                  icon: Icon(
                    stylusOnly ? Icons.draw : Icons.touch_app,
                    color: stylusOnly
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  tooltip: stylusOnly
                      ? 'Modo lápiz (toca para activar dedo)'
                      : 'Modo dedo (toca para activar solo lápiz)',
                  onPressed: onStylusOnlyToggle,
                  iconSize: 20,
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
              activeShapeType: inkShapeType,
              onShapeTypeChanged: onInkShapeTypeChanged,
              activeSelectionMode: inkSelectionMode,
              onSelectionModeChanged: onInkSelectionModeChanged,
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

class _BlockList extends StatefulWidget {
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
    required this.defaultInkBackground,
    this.defaultCanvasBackgroundHex,
    this.defaultLineColorHex,
    this.inkShapeType,
    this.inkSelectionMode,
    this.markdownFontFamily,
    this.markdownFontSize,
    this.stylusOnly = false,
    this.eraserRadius = 20.0,
  });

  final EditorState editorState;
  final EditorNotifier notifier;
  final Future<void> Function({String? afterBlockId}) onImportImage;
  final Future<void> Function({String? afterBlockId}) onImportPdf;
  final InkBackground defaultInkBackground;
  final String? defaultCanvasBackgroundHex;
  final String? defaultLineColorHex;
  final StrokeTool inkTool;
  final String inkColor;
  final double inkWidth;
  final double textFontSize;
  final bool textBold;
  final bool textItalic;
  final ShapeType? inkShapeType;
  final SelectionMode? inkSelectionMode;
  final String? markdownFontFamily;
  final double? markdownFontSize;
  final bool stylusOnly;
  final double eraserRadius;

  @override
  State<_BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<_BlockList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.editorState.blocks;

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

    void onReorder(int oldIndex, int newIndex) {
      if (newIndex > oldIndex) newIndex--;
      widget.notifier.moveBlock(blocks[oldIndex].id, newIndex);
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        buildDefaultDragHandles: false,
        onReorder: onReorder,
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          final block = blocks[index];
          final isSelected = widget.editorState.selectedBlockId == block.id;
          final autoFocus = isSelected &&
              block is MarkdownBlock &&
              block.content.isEmpty;
          return Column(
            key: ValueKey(block.id),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlockChrome(
                isSelected: isSelected,
                dragIndex: blocks.length > 1 ? index : null,
                onTap: () => widget.notifier.setSelectedBlock(block.id),
                onDelete: () =>
                    _confirmAndDeleteBlock(context, block, widget.notifier),
                child: BlockWidget(
                  block: block,
                  documentPath: widget.editorState.path,
                  isSelected: isSelected,
                  onUpdate: widget.notifier.updateBlock,
                  autoFocus: autoFocus,
                  onEnterAtEnd: () => widget.notifier.addBlock(
                    Block.markdown(id: const Uuid().v4(), content: ''),
                    afterId: block.id,
                  ),
                  inkTool: widget.inkTool,
                  inkColor: widget.inkColor,
                  inkWidth: widget.inkWidth,
                  textFontSize: widget.textFontSize,
                  textBold: widget.textBold,
                  textItalic: widget.textItalic,
                  inkShapeType: widget.inkShapeType,
                  inkSelectionMode: widget.inkSelectionMode,
                  markdownFontFamily: widget.markdownFontFamily,
                  markdownFontSize: widget.markdownFontSize,
                  stylusOnly: widget.stylusOnly,
                  eraserRadius: widget.eraserRadius,
                ),
              ),
              _InsertGap(
                onInsertMarkdown: () => widget.notifier.addBlock(
                  Block.markdown(id: const Uuid().v4(), content: ''),
                  afterId: block.id,
                ),
                onInsertInk: () {
                  widget.notifier.addBlock(
                    Block.ink(
                      id: const Uuid().v4(),
                      height: 200.0,
                      background: widget.defaultInkBackground,
                      backgroundColor: widget.defaultCanvasBackgroundHex,
                      backgroundLineColor: widget.defaultLineColorHex,
                    ),
                    afterId: block.id,
                  );
                },
                onInsertImage: () =>
                    widget.onImportImage(afterBlockId: block.id),
                onInsertPdf: () =>
                    widget.onImportPdf(afterBlockId: block.id),
              ),
            ],
          );
        },
      ),
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
