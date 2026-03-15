// Application layer: business logic and use cases.
//
// Contains:
//   - WorkspaceState + WorkspaceNotifier (Riverpod)
//   - Service interfaces (FileSystemService, RecentFilesService, AssetManager)
//   - Provider definitions that wire domain interfaces to data implementations
//   - No direct Flutter widget dependencies
library;

export 'editor/editor_notifier.dart';
export 'editor/editor_state.dart';
export 'providers.dart';
export 'services/asset_manager.dart';
export 'services/file_system_service.dart';
export 'services/recent_entry.dart';
export 'services/recent_files_service.dart';
export 'settings/app_settings.dart';
export 'settings/settings_notifier.dart';
export 'settings/settings_repository.dart';
export 'workspace/opened_document.dart';
export 'workspace/recent_entries_provider.dart';
export 'workspace/workspace_notifier.dart';
export 'workspace/workspace_state.dart';
