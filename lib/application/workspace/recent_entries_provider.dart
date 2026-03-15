import 'package:riverpod/riverpod.dart';

import 'package:runa/application/providers.dart';
import 'package:runa/application/services/recent_entry.dart';
import 'workspace_notifier.dart';

/// Reactive list of recent entries with open timestamps.
///
/// Invalidates and re-fetches from [RecentFilesService] whenever
/// [WorkspaceState.recentPaths] changes (document opened, closed, or removed).
final recentEntriesProvider = FutureProvider<List<RecentEntry>>((ref) async {
  // Depend on recentPaths so this provider reruns on any change.
  ref.watch(workspaceProvider.select((ws) => ws.recentPaths));
  return ref.watch(recentFilesServiceProvider).loadRecentEntries();
});
