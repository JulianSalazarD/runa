import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';
import 'package:runa/data/data.dart';

/// Shown when no folder is open. Provides quick actions and recent files.
class WelcomeView extends ConsumerWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentPaths = ref.watch(workspaceNotifierProvider).recentPaths;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Runa', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Editor de documentos por bloques',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => _openFolder(context, ref),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Abrir carpeta'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _newDocument(ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo documento'),
                  ),
                ],
              ),
              if (recentPaths.isNotEmpty) ...[
                const SizedBox(height: 56),
                SizedBox(
                  width: 480,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recientes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final path in recentPaths)
                        RecentFileItem(path: path),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFolder(BuildContext context, WidgetRef ref) async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;
    await ref.read(workspaceNotifierProvider.notifier).openDirectory(path);
  }

  Future<void> _newDocument(WidgetRef ref) async {
    final dir = await const DefaultDirectoryService().getDefaultDirectory();
    final name = 'sin_titulo_${DateTime.now().millisecondsSinceEpoch}';
    await ref
        .read(workspaceNotifierProvider.notifier)
        .createDocument(dir.path, name);
  }
}

/// A single row in the recent-files list.
///
/// Shows a file-not-found indicator and a remove button when the file
/// no longer exists on disk.
class RecentFileItem extends ConsumerWidget {
  const RecentFileItem({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exists = File(path).existsSync();
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.description_outlined,
        color: exists ? null : colorScheme.error,
      ),
      title: Text(
        p.basenameWithoutExtension(path),
        style: TextStyle(color: exists ? null : colorScheme.error),
      ),
      subtitle: Text(
        path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: exists
          ? null
          : IconButton(
              tooltip: 'Eliminar de recientes',
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(workspaceNotifierProvider.notifier).removeRecentPath(path),
            ),
      onTap: exists
          ? () =>
              ref.read(workspaceNotifierProvider.notifier).openDocument(path)
          : null,
    );
  }
}
