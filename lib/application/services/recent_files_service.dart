import 'recent_entry.dart';

/// Persistent store for the list of recently opened document paths.
///
/// Implementations decide where to persist the list (JSON file, shared
/// preferences, etc.). The list is ordered most-recent-first.
abstract interface class RecentFilesService {
  /// Returns the stored list of recent paths (most recent first).
  /// Returns an empty list if no data has been saved yet.
  Future<List<String>> loadRecents();

  /// Returns the stored list of recent entries with timestamps (most recent
  /// first). Returns an empty list if no data has been saved yet.
  Future<List<RecentEntry>> loadRecentEntries();

  /// Adds [path] to the front of the list, removing any existing entry for
  /// the same path. Implementations may cap the list to a maximum size.
  Future<void> addRecent(String path);

  /// Removes [path] from the list. No-op if [path] is not in the list.
  Future<void> remove(String path);

  /// Clears all entries from the list.
  Future<void> clear();
}
