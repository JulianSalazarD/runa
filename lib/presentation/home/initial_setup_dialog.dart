import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runa/application/application.dart';

import '../utils/linux_file_picker.dart';

/// Runs the first-launch workspace setup.
///
/// - Android / iOS: silently resolves and stores the default app-documents
///   directory, then returns.
/// - Desktop: shows a modal dialog asking the user to confirm the default
///   `~/Runa` path or pick a custom folder.
///
/// Always marks [AppSettings.workspaceConfigured] = `true` when done and
/// opens the chosen directory in the workspace.
Future<void> runInitialSetup(BuildContext context, WidgetRef ref) async {
  if (Platform.isAndroid || Platform.isIOS) {
    await _configureAndroid(ref);
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProviderScope.containerOf(context).let(
      (container) => UncontrolledProviderScope(
        container: container,
        child: const _SetupDialog(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Android / iOS — auto configure
// ---------------------------------------------------------------------------

Future<void> _configureAndroid(WidgetRef ref) async {
  final dir =
      await ref.read(defaultDirectoryServiceProvider).getDefaultDirectory();
  final settings = ref.read(settingsProvider);
  await ref.read(settingsProvider.notifier).update(
        settings.copyWith(
          defaultWorkspacePath: dir.path,
          workspaceConfigured: true,
          stylusOnlyMode: true,
        ),
      );
  await ref.read(workspaceProvider.notifier).openDirectory(dir.path);
}

// ---------------------------------------------------------------------------
// Desktop dialog
// ---------------------------------------------------------------------------

class _SetupDialog extends ConsumerStatefulWidget {
  const _SetupDialog();

  @override
  ConsumerState<_SetupDialog> createState() => _SetupDialogState();
}

class _SetupDialogState extends ConsumerState<_SetupDialog> {
  String? _selectedPath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultPath();
  }

  Future<void> _loadDefaultPath() async {
    final dir =
        await ref.read(defaultDirectoryServiceProvider).getDefaultDirectory();
    if (mounted) {
      setState(() {
        _selectedPath = dir.path;
        _loading = false;
      });
    }
  }

  Future<void> _pickFolder() async {
    String? path;
    try {
      path = await LinuxFilePicker.pickDirectory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
      return;
    }
    if (path != null && mounted) {
      setState(() => _selectedPath = path);
    }
  }

  Future<void> _confirm() async {
    if (_selectedPath == null) return;
    setState(() => _saving = true);

    // Ensure the directory exists.
    await Directory(_selectedPath!).create(recursive: true);

    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update(
          settings.copyWith(
            defaultWorkspacePath: _selectedPath,
            workspaceConfigured: true,
          ),
        );
    await ref.read(workspaceProvider.notifier).openDirectory(_selectedPath!);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Dónde quieres guardar tus documentos?'),
      content: SizedBox(
        width: 480,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Runa guardará tus documentos en la carpeta siguiente. '
                    'Puedes cambiarla más adelante en Configuración.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedPath ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _pickFolder,
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      actions: [
        FilledButton(
          onPressed: (_loading || _saving || _selectedPath == null)
              ? null
              : _confirm,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Usar esta carpeta'),
        ),
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
