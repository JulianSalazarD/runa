// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editorNotifierHash() => r'32dbb9cf08ae62c9d7209166ce7a6d419f30a3b2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$EditorNotifier
    extends BuildlessAutoDisposeNotifier<EditorState> {
  late final String documentId;

  EditorState build(String documentId);
}

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.
///
/// Copied from [EditorNotifier].
@ProviderFor(EditorNotifier)
const editorNotifierProvider = EditorNotifierFamily();

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.
///
/// Copied from [EditorNotifier].
class EditorNotifierFamily extends Family<EditorState> {
  /// Manages editing state for a single document identified by [documentId].
  ///
  /// Create the notifier via `editorNotifierProvider(documentId)`, then call
  /// [loadDocument] with the file path before making any mutations.
  ///
  /// Copied from [EditorNotifier].
  const EditorNotifierFamily();

  /// Manages editing state for a single document identified by [documentId].
  ///
  /// Create the notifier via `editorNotifierProvider(documentId)`, then call
  /// [loadDocument] with the file path before making any mutations.
  ///
  /// Copied from [EditorNotifier].
  EditorNotifierProvider call(String documentId) {
    return EditorNotifierProvider(documentId);
  }

  @override
  EditorNotifierProvider getProviderOverride(
    covariant EditorNotifierProvider provider,
  ) {
    return call(provider.documentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'editorNotifierProvider';
}

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.
///
/// Copied from [EditorNotifier].
class EditorNotifierProvider
    extends AutoDisposeNotifierProviderImpl<EditorNotifier, EditorState> {
  /// Manages editing state for a single document identified by [documentId].
  ///
  /// Create the notifier via `editorNotifierProvider(documentId)`, then call
  /// [loadDocument] with the file path before making any mutations.
  ///
  /// Copied from [EditorNotifier].
  EditorNotifierProvider(String documentId)
    : this._internal(
        () => EditorNotifier()..documentId = documentId,
        from: editorNotifierProvider,
        name: r'editorNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$editorNotifierHash,
        dependencies: EditorNotifierFamily._dependencies,
        allTransitiveDependencies:
            EditorNotifierFamily._allTransitiveDependencies,
        documentId: documentId,
      );

  EditorNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.documentId,
  }) : super.internal();

  final String documentId;

  @override
  EditorState runNotifierBuild(covariant EditorNotifier notifier) {
    return notifier.build(documentId);
  }

  @override
  Override overrideWith(EditorNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditorNotifierProvider._internal(
        () => create()..documentId = documentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        documentId: documentId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EditorNotifier, EditorState>
  createElement() {
    return _EditorNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditorNotifierProvider && other.documentId == documentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, documentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditorNotifierRef on AutoDisposeNotifierProviderRef<EditorState> {
  /// The parameter `documentId` of this provider.
  String get documentId;
}

class _EditorNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<EditorNotifier, EditorState>
    with EditorNotifierRef {
  _EditorNotifierProviderElement(super.provider);

  @override
  String get documentId => (origin as EditorNotifierProvider).documentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
