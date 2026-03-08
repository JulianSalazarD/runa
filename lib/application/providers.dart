import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:runa/data/data.dart';
import 'package:runa/domain/domain.dart';

import 'services/file_system_service.dart';
import 'services/recent_files_service.dart';

part 'providers.g.dart';

/// Default [DocumentRepository] — reads/writes `.runa` files on disk.
@riverpod
DocumentRepository documentRepository(Ref ref) =>
    const LocalDocumentRepository();

/// Default [RecentFilesService] — persists recents to a JSON file.
@riverpod
RecentFilesService recentFilesService(Ref ref) =>
    const LocalRecentFilesService();

/// Default [FileSystemService] — uses `dart:io` directly.
@riverpod
FileSystemService fileSystemService(Ref ref) =>
    const LocalFileSystemService();
