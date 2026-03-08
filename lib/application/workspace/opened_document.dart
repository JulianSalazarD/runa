import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runa/domain/domain.dart';

part 'opened_document.freezed.dart';

/// Represents a document that is currently open in a tab.
@freezed
class OpenedDocument with _$OpenedDocument {
  const factory OpenedDocument({
    /// The in-memory document model.
    required Document document,

    /// Absolute path to the `.runa` file on disk.
    required String path,

    /// Whether the in-memory [document] differs from the saved version.
    @Default(false) bool hasUnsavedChanges,
  }) = _OpenedDocument;
}
