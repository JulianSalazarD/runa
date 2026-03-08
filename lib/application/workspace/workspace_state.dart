import 'package:freezed_annotation/freezed_annotation.dart';

import 'opened_document.dart';

part 'workspace_state.freezed.dart';

/// Immutable snapshot of the workspace UI state.
///
/// Held by [WorkspaceNotifier] and rebuilt on every state change.
@freezed
class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    /// Absolute path of the directory currently open in the sidebar, or null.
    String? openedDirectoryPath,

    /// Documents that are currently open as tabs (ordered by open time).
    @Default([]) List<OpenedDocument> openedDocuments,

    /// The [Document.id] of the document shown in the editor area, or null
    /// when no tab is active (e.g. after closing the last document).
    String? activeDocumentId,

    /// Most-recently-used document paths (most recent first, max 20).
    @Default([]) List<String> recentPaths,
  }) = _WorkspaceState;

  /// Starting state: no directory, no open documents, no recents.
  factory WorkspaceState.empty() => const WorkspaceState();
}
