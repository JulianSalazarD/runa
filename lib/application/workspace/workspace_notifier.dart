import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:runa/domain/domain.dart';

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

  /// Removes [path] from the recents list (both service and state).
  Future<void> removeRecentPath(String path) async {
    await _recents.remove(path);
    state = state.copyWith(
      recentPaths: state.recentPaths.where((r) => r != path).toList(),
    );
  }
}
