// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.

@ProviderFor(EditorNotifier)
final editorProvider = EditorNotifierFamily._();

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.
final class EditorNotifierProvider
    extends $NotifierProvider<EditorNotifier, EditorState> {
  /// Manages editing state for a single document identified by [documentId].
  ///
  /// Create the notifier via `editorNotifierProvider(documentId)`, then call
  /// [loadDocument] with the file path before making any mutations.
  EditorNotifierProvider._({
    required EditorNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorNotifierHash();

  @override
  String toString() {
    return r'editorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorNotifier create() => EditorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditorNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorNotifierHash() => r'977ab427610a68c2e9cd03d09708a2594d781304';

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.

final class EditorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorNotifier,
          EditorState,
          EditorState,
          EditorState,
          String
        > {
  EditorNotifierFamily._()
    : super(
        retry: null,
        name: r'editorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages editing state for a single document identified by [documentId].
  ///
  /// Create the notifier via `editorNotifierProvider(documentId)`, then call
  /// [loadDocument] with the file path before making any mutations.

  EditorNotifierProvider call(String documentId) =>
      EditorNotifierProvider._(argument: documentId, from: this);

  @override
  String toString() => r'editorProvider';
}

/// Manages editing state for a single document identified by [documentId].
///
/// Create the notifier via `editorNotifierProvider(documentId)`, then call
/// [loadDocument] with the file path before making any mutations.

abstract class _$EditorNotifier extends $Notifier<EditorState> {
  late final _$args = ref.$arg as String;
  String get documentId => _$args;

  EditorState build(String documentId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EditorState, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditorState, EditorState>,
              EditorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
