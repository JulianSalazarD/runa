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
  @override
  EditorState build(String documentId) {
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
  // Block mutations
  // -------------------------------------------------------------------------

  /// Appends [block] to the end, or inserts it immediately after [afterId].
  void addBlock(Block block, {String? afterId}) {
    final blocks = List<Block>.from(state.blocks);
    if (afterId == null) {
      blocks.add(block);
    } else {
      final index = blocks.indexWhere((b) => b.id == afterId);
      blocks.insert(index == -1 ? blocks.length : index + 1, block);
    }
    _setBlocks(blocks);
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
