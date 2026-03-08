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
    final entriesAsync = ref.watch(recentEntriesProvider);

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
              entriesAsync.when(
                data: (entries) => entries.isEmpty
                    ? const SizedBox.shrink()
                    : _RecentSection(entries: entries.take(10).toList()),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
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

// ---------------------------------------------------------------------------
// Recent section (header + "Limpiar" button + list)
// ---------------------------------------------------------------------------

class _RecentSection extends ConsumerWidget {
  const _RecentSection({required this.entries});

  final List<RecentEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 56),
        SizedBox(
          width: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recientes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(workspaceNotifierProvider.notifier)
                        .clearRecentPaths(),
                    child: const Text('Limpiar recientes'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final entry in entries) RecentEntryItem(entry: entry),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual recent-file row
// ---------------------------------------------------------------------------

/// A single row in the recent-files list.
///
/// Shows a file-not-found indicator and a remove button when the file
/// no longer exists on disk.
class RecentEntryItem extends ConsumerWidget {
  const RecentEntryItem({super.key, required this.entry});

  final RecentEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exists = File(entry.path).existsSync();
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.description_outlined,
        color: exists ? null : colorScheme.error,
      ),
      title: Text(
        p.basenameWithoutExtension(entry.path),
        style: TextStyle(color: exists ? null : colorScheme.error),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            _formatDate(entry.openedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: exists
          ? null
          : IconButton(
              tooltip: 'Eliminar de recientes',
              icon: const Icon(Icons.close),
              onPressed: () => ref
                  .read(workspaceNotifierProvider.notifier)
                  .removeRecentPath(entry.path),
            ),
      onTap: exists
          ? () => ref
              .read(workspaceNotifierProvider.notifier)
              .openDocument(entry.path)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Date formatting helper
// ---------------------------------------------------------------------------

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final date = DateTime(local.year, local.month, local.day);
  if (date == today) return 'Hoy';
  if (date == yesterday) return 'Ayer';
  return '${local.day}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
