// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkspaceNotifier)
final workspaceProvider = WorkspaceNotifierProvider._();

final class WorkspaceNotifierProvider
    extends $NotifierProvider<WorkspaceNotifier, WorkspaceState> {
  WorkspaceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceNotifierHash();

  @$internal
  @override
  WorkspaceNotifier create() => WorkspaceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceState>(value),
    );
  }
}

String _$workspaceNotifierHash() => r'a2df87efa3fc960e907503eecea2e677d2095284';

abstract class _$WorkspaceNotifier extends $Notifier<WorkspaceState> {
  WorkspaceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WorkspaceState, WorkspaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceState, WorkspaceState>,
              WorkspaceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
