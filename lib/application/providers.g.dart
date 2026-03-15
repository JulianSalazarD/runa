// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Default [DocumentRepository] — reads/writes `.runa` files on disk.

@ProviderFor(documentRepository)
final documentRepositoryProvider = DocumentRepositoryProvider._();

/// Default [DocumentRepository] — reads/writes `.runa` files on disk.

final class DocumentRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentRepository,
          DocumentRepository,
          DocumentRepository
        >
    with $Provider<DocumentRepository> {
  /// Default [DocumentRepository] — reads/writes `.runa` files on disk.
  DocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepository create(Ref ref) {
    return documentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepository>(value),
    );
  }
}

String _$documentRepositoryHash() =>
    r'1d34b62135de9ba50a86cff05fee295c67d52da1';

/// Default [RecentFilesService] — persists recents to a JSON file.

@ProviderFor(recentFilesService)
final recentFilesServiceProvider = RecentFilesServiceProvider._();

/// Default [RecentFilesService] — persists recents to a JSON file.

final class RecentFilesServiceProvider
    extends
        $FunctionalProvider<
          RecentFilesService,
          RecentFilesService,
          RecentFilesService
        >
    with $Provider<RecentFilesService> {
  /// Default [RecentFilesService] — persists recents to a JSON file.
  RecentFilesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentFilesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentFilesServiceHash();

  @$internal
  @override
  $ProviderElement<RecentFilesService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentFilesService create(Ref ref) {
    return recentFilesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentFilesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentFilesService>(value),
    );
  }
}

String _$recentFilesServiceHash() =>
    r'2585b094b6e75b2d899ed7d8e612abab72f0f551';

/// Default [FileSystemService] — uses `dart:io` directly.

@ProviderFor(fileSystemService)
final fileSystemServiceProvider = FileSystemServiceProvider._();

/// Default [FileSystemService] — uses `dart:io` directly.

final class FileSystemServiceProvider
    extends
        $FunctionalProvider<
          FileSystemService,
          FileSystemService,
          FileSystemService
        >
    with $Provider<FileSystemService> {
  /// Default [FileSystemService] — uses `dart:io` directly.
  FileSystemServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileSystemServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileSystemServiceHash();

  @$internal
  @override
  $ProviderElement<FileSystemService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FileSystemService create(Ref ref) {
    return fileSystemService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileSystemService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileSystemService>(value),
    );
  }
}

String _$fileSystemServiceHash() => r'4be2240455c8df799c46d049f29e6fe58504a152';

/// Default [AssetManager] — copies/resolves assets on the local file system.

@ProviderFor(assetManager)
final assetManagerProvider = AssetManagerProvider._();

/// Default [AssetManager] — copies/resolves assets on the local file system.

final class AssetManagerProvider
    extends $FunctionalProvider<AssetManager, AssetManager, AssetManager>
    with $Provider<AssetManager> {
  /// Default [AssetManager] — copies/resolves assets on the local file system.
  AssetManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetManagerHash();

  @$internal
  @override
  $ProviderElement<AssetManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetManager create(Ref ref) {
    return assetManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetManager>(value),
    );
  }
}

String _$assetManagerHash() => r'c5ed889ea94b785306020f95a065c7e8c5ce80b5';

/// Default [SettingsRepository] — reads/writes `settings.json` on disk.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Default [SettingsRepository] — reads/writes `settings.json` on disk.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// Default [SettingsRepository] — reads/writes `settings.json` on disk.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'10f11a828f81bcf1e4139b0e5cb9070c311d2255';

/// Provides the [DefaultDirectoryService] so it can be overridden in tests.

@ProviderFor(defaultDirectoryService)
final defaultDirectoryServiceProvider = DefaultDirectoryServiceProvider._();

/// Provides the [DefaultDirectoryService] so it can be overridden in tests.

final class DefaultDirectoryServiceProvider
    extends
        $FunctionalProvider<
          DefaultDirectoryService,
          DefaultDirectoryService,
          DefaultDirectoryService
        >
    with $Provider<DefaultDirectoryService> {
  /// Provides the [DefaultDirectoryService] so it can be overridden in tests.
  DefaultDirectoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultDirectoryServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultDirectoryServiceHash();

  @$internal
  @override
  $ProviderElement<DefaultDirectoryService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DefaultDirectoryService create(Ref ref) {
    return defaultDirectoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefaultDirectoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefaultDirectoryService>(value),
    );
  }
}

String _$defaultDirectoryServiceHash() =>
    r'a14e86e60495f0e8f6cd0f45fb821753ce0a2eca';
