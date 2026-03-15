// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentRepositoryHash() =>
    r'1d34b62135de9ba50a86cff05fee295c67d52da1';

/// Default [DocumentRepository] — reads/writes `.runa` files on disk.
///
/// Copied from [documentRepository].
@ProviderFor(documentRepository)
final documentRepositoryProvider =
    AutoDisposeProvider<DocumentRepository>.internal(
      documentRepository,
      name: r'documentRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$documentRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DocumentRepositoryRef = AutoDisposeProviderRef<DocumentRepository>;
String _$recentFilesServiceHash() =>
    r'2585b094b6e75b2d899ed7d8e612abab72f0f551';

/// Default [RecentFilesService] — persists recents to a JSON file.
///
/// Copied from [recentFilesService].
@ProviderFor(recentFilesService)
final recentFilesServiceProvider =
    AutoDisposeProvider<RecentFilesService>.internal(
      recentFilesService,
      name: r'recentFilesServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentFilesServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentFilesServiceRef = AutoDisposeProviderRef<RecentFilesService>;
String _$fileSystemServiceHash() => r'4be2240455c8df799c46d049f29e6fe58504a152';

/// Default [FileSystemService] — uses `dart:io` directly.
///
/// Copied from [fileSystemService].
@ProviderFor(fileSystemService)
final fileSystemServiceProvider =
    AutoDisposeProvider<FileSystemService>.internal(
      fileSystemService,
      name: r'fileSystemServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fileSystemServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FileSystemServiceRef = AutoDisposeProviderRef<FileSystemService>;
String _$assetManagerHash() => r'c5ed889ea94b785306020f95a065c7e8c5ce80b5';

/// Default [AssetManager] — copies/resolves assets on the local file system.
///
/// Copied from [assetManager].
@ProviderFor(assetManager)
final assetManagerProvider = AutoDisposeProvider<AssetManager>.internal(
  assetManager,
  name: r'assetManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$assetManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssetManagerRef = AutoDisposeProviderRef<AssetManager>;
String _$settingsRepositoryHash() =>
    r'10f11a828f81bcf1e4139b0e5cb9070c311d2255';

/// Default [SettingsRepository] — reads/writes `settings.json` on disk.
///
/// Copied from [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeProvider<SettingsRepository>.internal(
      settingsRepository,
      name: r'settingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = AutoDisposeProviderRef<SettingsRepository>;
String _$defaultDirectoryServiceHash() =>
    r'a14e86e60495f0e8f6cd0f45fb821753ce0a2eca';

/// Provides the [DefaultDirectoryService] so it can be overridden in tests.
///
/// Copied from [defaultDirectoryService].
@ProviderFor(defaultDirectoryService)
final defaultDirectoryServiceProvider =
    AutoDisposeProvider<DefaultDirectoryService>.internal(
      defaultDirectoryService,
      name: r'defaultDirectoryServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultDirectoryServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultDirectoryServiceRef =
    AutoDisposeProviderRef<DefaultDirectoryService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
