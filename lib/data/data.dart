// Data layer: persistence and serialization.
//
// Contains:
//   - LocalDocumentRepository (implements domain repository interface)
//   - JSON serialization / deserialization of .runa files
//   - DefaultDirectoryService
//   - Generated code: *.g.dart, *.freezed.dart
library;

export 'repositories/local_document_repository.dart';
export 'services/default_directory_service.dart';
export 'services/local_file_system_service.dart';
export 'services/local_asset_manager.dart';
export 'services/local_recent_files_service.dart';
