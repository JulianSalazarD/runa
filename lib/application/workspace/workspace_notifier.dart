import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import '../providers.dart';
import '../services/file_system_service.dart';
import '../services/recent_files_service.dart';
import 'opened_document.dart';
import 'workspace_state.dart';

part 'workspace_notifier.g.dart';

@riverpod
class WorkspaceNotifier extends _$WorkspaceNotifier {
  static const _uuid = Uuid();

  DocumentRepository get _repo => ref.read(documentRepositoryProvider);
  RecentFilesService get _recents => ref.read(recentFilesServiceProvider);
  FileSystemService get _fs => ref.read(fileSystemServiceProvider);

  @override
  WorkspaceState build() => WorkspaceState.empty();

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  /// Loads persisted recent paths into state. Call once on app startup.
  Future<void> initialize() async {
    final recents = await _recents.loadRecents();
    state = state.copyWith(recentPaths: recents);
  }

  // -------------------------------------------------------------------------
  // Directory
  // -------------------------------------------------------------------------

  /// Sets the sidebar directory to [path] without loading any documents.
  Future<void> openDirectory(String path) async {
    state = state.copyWith(openedDirectoryPath: path);
  }

  // -------------------------------------------------------------------------
  // Documents / tabs
  // -------------------------------------------------------------------------

  /// Opens the document at [path].
  ///
  /// - If already open: switches focus to its tab (no-op otherwise).
  /// - Otherwise: loads it, appends a new tab, and updates recents.
  Future<void> openDocument(String path) async {
    final existingIndex =
        state.openedDocuments.indexWhere((d) => d.path == path);
    if (existingIndex != -1) {
      setActiveDocument(state.openedDocuments[existingIndex].document.id);
      return;
    }

    final document = await _repo.load(path);
    final opened = OpenedDocument(document: document, path: path);

    state = state.copyWith(
      openedDocuments: [...state.openedDocuments, opened],
      activeDocumentId: document.id,
    );

    await _recents.addRecent(path);
    final updatedRecents = await _recents.loadRecents();
    state = state.copyWith(recentPaths: updatedRecents);
  }

  /// Closes the tab whose document has [id].
  ///
  /// If [id] is the active tab, the tab to its left (or right if leftmost)
  /// becomes active. When the last tab is closed, [activeDocumentId] is null.
  void closeDocument(String id) {
    final currentDocs = state.openedDocuments;
    final closingIndex =
        currentDocs.indexWhere((d) => d.document.id == id);
    if (closingIndex == -1) return;

    final remaining =
        currentDocs.where((d) => d.document.id != id).toList();

    String? newActiveId;
    if (state.activeDocumentId == id && remaining.isNotEmpty) {
      final newIndex = (closingIndex - 1).clamp(0, remaining.length - 1);
      newActiveId = remaining[newIndex].document.id;
    } else if (state.activeDocumentId != id) {
      newActiveId = state.activeDocumentId;
    }

    state = state.copyWith(
      openedDocuments: remaining,
      activeDocumentId: newActiveId,
    );
  }

  /// Switches the active tab to the document with [id]. No-op if not found.
  void setActiveDocument(String id) {
    state = state.copyWith(activeDocumentId: id);
  }

  // -------------------------------------------------------------------------
  // Creation
  // -------------------------------------------------------------------------

  /// Creates a new empty `.runa` document at `[directory]/[name].runa`,
  /// saves it to disk, and opens it in a new tab.
  Future<void> createDocument(String directory, String name) async {
    final filePath = p.join(directory, '$name.runa');
    final doc = Document(
      version: '0.1',
      id: _uuid.v4(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      blocks: const [],
    );
    await _repo.save(doc, filePath);
    await openDocument(filePath);
  }

  /// Creates a subdirectory named [name] inside [parent].
  Future<void> createSubdirectory(String parent, String name) async {
    await _fs.createDirectory(p.join(parent, name));
  }

  /// Marks the document with [id] as having (or not having) unsaved changes.
  ///
  /// Called by the editor when the user modifies content.
  void markHasUnsavedChanges(String id, {bool value = true}) {
    state = state.copyWith(
      openedDocuments: state.openedDocuments.map((d) {
        return d.document.id == id ? d.copyWith(hasUnsavedChanges: value) : d;
      }).toList(),
    );
  }

  /// Removes [path] from the recents list (both service and state).
  Future<void> removeRecentPath(String path) async {
    await _recents.remove(path);
    state = state.copyWith(
      recentPaths: state.recentPaths.where((r) => r != path).toList(),
    );
  }

  /// Clears all recent paths from both the persistent store and state.
  Future<void> clearRecentPaths() async {
    await _recents.clear();
    state = state.copyWith(recentPaths: []);
  }

  // -------------------------------------------------------------------------
  // Rename & delete
  // -------------------------------------------------------------------------

  /// Renames the document at [oldPath] to [newPath].
  ///
  /// Updates the open tab's path if the document was open, and refreshes
  /// recents so the new path is stored instead of the old one.
  Future<void> renameDocument(String oldPath, String newPath) async {
    await _fs.renameEntry(oldPath, newPath);

    final updatedDocs = state.openedDocuments.map((d) {
      return d.path == oldPath ? d.copyWith(path: newPath) : d;
    }).toList();
    state = state.copyWith(openedDocuments: updatedDocs);

    if (state.recentPaths.contains(oldPath)) {
      await _recents.remove(oldPath);
      await _recents.addRecent(newPath);
      state = state.copyWith(recentPaths: await _recents.loadRecents());
    }
  }

  /// Deletes the document at [path], closing its tab and removing from recents.
  Future<void> deleteDocument(String path) async {
    await _fs.deleteFile(path);

    final openDoc =
        state.openedDocuments.where((d) => d.path == path).firstOrNull;
    if (openDoc != null) closeDocument(openDoc.document.id);

    await removeRecentPath(path);
  }

  /// Deletes the directory at [path] and all its contents.
  ///
  /// Closes any open tabs whose documents live inside [path] and removes
  /// their paths from recents.
  Future<void> deleteDirectory(String path) async {
    final prefix = '$path/';
    final toClose = state.openedDocuments
        .where((d) => d.path.startsWith(prefix) || d.path == path)
        .toList();
    for (final doc in toClose) {
      closeDocument(doc.document.id);
    }

    final toRemove = state.recentPaths
        .where((r) => r.startsWith(prefix) || r == path)
        .toList();
    for (final r in toRemove) {
      await _recents.remove(r);
    }
    if (toRemove.isNotEmpty) {
      state = state.copyWith(recentPaths: await _recents.loadRecents());
    }

    await _fs.deleteDirectory(path);
  }
}
