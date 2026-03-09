import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:runa/domain/domain.dart';

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

  /// Removes the block with [id]. No-op if not found.
  void removeBlock(String id) {
    _setBlocks(state.blocks.where((b) => b.id != id).toList());
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
