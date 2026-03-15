import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runa/domain/domain.dart';

part 'opened_document.freezed.dart';

/// Represents a document that is currently open in a tab.
@freezed
abstract class OpenedDocument with _$OpenedDocument {
  const factory OpenedDocument({
    /// The in-memory document model.
    required Document document,

    /// Absolute path to the `.runa` file on disk.
    required String path,

    /// Whether the in-memory [document] differs from the saved version.
    @Default(false) bool hasUnsavedChanges,

    /// Whether to briefly show the "Guardado" indicator in the tab.
    ///
    /// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
    @Default(false) bool showSavedIndicator,
  }) = _OpenedDocument;
}
