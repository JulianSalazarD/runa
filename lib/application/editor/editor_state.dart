import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runa/domain/domain.dart';

part 'editor_state.freezed.dart';

/// Immutable state for a document that is being actively edited.
///
/// Held by [EditorNotifier]. All mutations return a new instance.
@freezed
class EditorState with _$EditorState {
  const EditorState._();

  const factory EditorState({
    /// Absolute path to the `.runa` file on disk.
    required String path,

    /// The in-memory representation of the document.
    required Document document,

    /// The [Block.id] of the block that currently has focus, or null.
    String? selectedBlockId,

    /// Whether the in-memory state differs from the last save.
    @Default(false) bool isDirty,

    /// Whether to show the "Guardado automáticamente" indicator briefly.
    @Default(false) bool autosaveMessage,
  }) = _EditorState;

  /// Shorthand for [document.blocks].
  List<Block> get blocks => document.blocks;
}
