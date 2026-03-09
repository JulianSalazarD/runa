import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import '../providers.dart';
import '../workspace/workspace_notifier.dart';
import 'editor_state.dart';

part 'editor_notifier.g.dart';

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.
@riverpod
class EditorNotifier extends _$EditorNotifier {
  static const _autosaveInterval = Duration(seconds: 30);
  static const _messageDuration = Duration(seconds: 2);

  Timer? _autosaveTimer;
  Timer? _messageTimer;

  @override
  EditorState build(String documentId) {
    _autosaveTimer = Timer.periodic(_autosaveInterval, (_) => _autosave());
    ref.onDispose(() {
      _autosaveTimer?.cancel();
      _messageTimer?.cancel();
    });
    return EditorState(
      path: '',
      document: Document(
        version: '0.1',
        id: documentId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        blocks: const [],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Load & save
  // -------------------------------------------------------------------------

  /// Initialises state from an already-loaded [doc] without hitting disk.
  ///
  /// Call this from a widget's `initState` / `didUpdateWidget` when the
  /// document is already available in memory (e.g. from [WorkspaceNotifier]).
  void initFromDocument(Document doc, String path) {
    state = state.copyWith(path: path, document: doc, isDirty: false);
  }

  /// Loads the document at [path] from the repository and resets dirty state.
  Future<void> loadDocument(String path) async {
    final doc = await ref.read(documentRepositoryProvider).load(path);
    state = state.copyWith(path: path, document: doc, isDirty: false);
  }

  /// Persists the current blocks to disk and clears the dirty flag.
  Future<void> saveDocument() async {
    final updated = state.document.copyWith(
      updatedAt: DateTime.now().toUtc(),
      blocks: state.blocks,
    );
    await ref.read(documentRepositoryProvider).save(updated, state.path);
    state = state.copyWith(document: updated, isDirty: false);
    ref
        .read(workspaceNotifierProvider.notifier)
        .markHasUnsavedChanges(documentId, value: false);
  }

  // -------------------------------------------------------------------------
  // Autosave
  // -------------------------------------------------------------------------

  /// Exposed for testing: runs the autosave logic immediately.
  Future<void> triggerAutosave() => _autosave();

  Future<void> _autosave() async {
    if (!state.isDirty) return;
    await saveDocument();
    _messageTimer?.cancel();
    state = state.copyWith(autosaveMessage: true);
    _messageTimer = Timer(_messageDuration, () {
      try {
        state = state.copyWith(autosaveMessage: false);
      } catch (_) {}
    });
  }

  // -------------------------------------------------------------------------
  // Block mutations
  // -------------------------------------------------------------------------

  /// Appends [block] to the end, or inserts it immediately after [afterId].
  ///
  /// The new block is automatically selected after insertion.
  void addBlock(Block block, {String? afterId}) {
    final blocks = List<Block>.from(state.blocks);
    if (afterId == null) {
      blocks.add(block);
    } else {
      final index = blocks.indexWhere((b) => b.id == afterId);
      blocks.insert(index == -1 ? blocks.length : index + 1, block);
    }
    _setBlocks(blocks);
    state = state.copyWith(selectedBlockId: block.id);
  }

  /// Removes the block with [id] from the document.
  ///
  /// If the removed block is an [ImageBlock] or [PdfPageBlock], and no other
  /// block in the document references the same asset path, the asset file
  /// is deleted from disk (best-effort — errors are silently ignored).
  Future<void> removeBlock(String id) async {
    final idx = state.blocks.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    final block = state.blocks[idx];

    // Remove from state immediately for a responsive UI.
    _setBlocks(state.blocks.where((b) => b.id != id).toList());

    // Determine if this block owned an asset.
    final assetPath = switch (block) {
      final ImageBlock b => b.path,
      final PdfPageBlock b => b.path,
      _ => null,
    };
    if (assetPath == null) return;

    // Delete asset only when no remaining block references the same path.
    final remaining = state.blocks; // already updated by _setBlocks above
    final isOrphaned = !remaining.any((b) => switch (b) {
      final ImageBlock ib => ib.path == assetPath,
      final PdfPageBlock pb => pb.path == assetPath,
      _ => false,
    });
    if (!isOrphaned) return;

    try {
      await ref.read(assetManagerProvider).deleteAsset(assetPath, state.path);
    } catch (_) {
      // Best-effort: ignore I/O errors.
    }
  }

  /// Replaces the block whose id matches [updated.id]. No-op if not found.
  void updateBlock(Block updated) {
    _setBlocks(
      state.blocks.map((b) => b.id == updated.id ? updated : b).toList(),
    );
  }

  /// Moves the block with [id] to [newIndex] in the list.
  void moveBlock(String id, int newIndex) {
    final blocks = List<Block>.from(state.blocks);
    final oldIndex = blocks.indexWhere((b) => b.id == id);
    if (oldIndex == -1) return;
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex.clamp(0, blocks.length), block);
    _setBlocks(blocks);
  }

  // -------------------------------------------------------------------------
  // Asset import
  // -------------------------------------------------------------------------

  /// Copies the image at [sourcePath] to the document's `_assets/` folder,
  /// reads its natural dimensions, creates an [ImageBlock], and inserts it.
  ///
  /// [afterBlockId] works the same as in [addBlock]. Throws on I/O error.
  Future<void> importImage(String sourcePath, {String? afterBlockId}) async {
    state = state.copyWith(isImporting: true);
    try {
      final am = ref.read(assetManagerProvider);
      final (w, h) = await am.readImageSize(sourcePath);
      final rel = await am.copyAsset(sourcePath, state.path);
      addBlock(
        Block.image(
          id: const Uuid().v4(),
          path: rel,
          naturalWidth: w,
          naturalHeight: h,
        ),
        afterId: afterBlockId,
      );
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  /// Copies the PDF at [sourcePath] to the document's `_assets/` folder,
  /// reads its page count and dimensions, and inserts one [PdfPageBlock] per
  /// page consecutively at the target position.
  ///
  /// [afterBlockId] works the same as in [addBlock]. Throws on I/O error.
  Future<void> importPdf(String sourcePath, {String? afterBlockId}) async {
    state = state.copyWith(isImporting: true);
    try {
      final am = ref.read(assetManagerProvider);
      final rel = await am.copyAsset(sourcePath, state.path);
      final absolutePath = am.resolveAsset(rel, state.path);
      final pages = await am.readPdfInfo(absolutePath);

      if (pages.isEmpty) return;

      final pageBlocks = [
        for (int i = 0; i < pages.length; i++)
          Block.pdfPage(
            id: const Uuid().v4(),
            path: rel,
            pageIndex: i,
            pageWidth: pages[i].$1,
            pageHeight: pages[i].$2,
          ),
      ];

      // Insert all page blocks consecutively at the target position.
      final blocks = List<Block>.from(state.blocks);
      var insertAt = afterBlockId == null
          ? blocks.length
          : blocks.indexWhere((b) => b.id == afterBlockId) + 1;
      if (insertAt <= 0) insertAt = blocks.length;
      blocks.insertAll(insertAt, pageBlocks);
      _setBlocks(blocks);
      state = state.copyWith(selectedBlockId: pageBlocks.first.id);
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  // -------------------------------------------------------------------------
  // Selection
  // -------------------------------------------------------------------------

  /// Sets the focused block. Pass null to deselect.
  void setSelectedBlock(String? id) {
    state = state.copyWith(selectedBlockId: id);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  void _setBlocks(List<Block> blocks) {
    state = state.copyWith(
      document: state.document.copyWith(blocks: blocks),
      isDirty: true,
    );
    ref
        .read(workspaceNotifierProvider.notifier)
        .markHasUnsavedChanges(documentId);
  }
}
