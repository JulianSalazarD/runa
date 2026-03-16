import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';

import '../settings/settings_screen.dart';
import '../utils/linux_file_picker.dart';
import 'sidebar/name_input_dialog.dart';

/// Shown when no folder is open. Provides quick actions and recent files.
class WelcomeView extends ConsumerStatefulWidget {
  const WelcomeView({super.key});

  @override
  ConsumerState<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends ConsumerState<WelcomeView> {
  /// Absolute path to `~/Runa/` once resolved. Null while loading or on error.
  String? _rootPath;

  @override
  void initState() {
    super.initState();
    _loadDefaultDir();
  }

  Future<void> _loadDefaultDir() async {
    try {
      final configuredPath = ref.read(settingsProvider).defaultWorkspacePath;
      final String dirPath;
      if (configuredPath != null && configuredPath.isNotEmpty) {
        dirPath = configuredPath;
      } else {
        final dir = await ref
            .read(defaultDirectoryServiceProvider)
            .getDefaultDirectory();
        dirPath = dir.path;
      }
      if (mounted) setState(() => _rootPath = dirPath);
    } catch (_) {
      // If the home directory cannot be determined, skip the browser.
    }
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(recentEntriesProvider);

    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Runa',
                      style: Theme.of(context).textTheme.headlineLarge),
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
                        onPressed: () => _openFolder(context),
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Abrir carpeta'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _newDocument,
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo documento'),
                      ),
                    ],
                  ),
                  if (_rootPath != null) ...[
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 480,
                      child: _DefaultDirectoryBrowser(rootPath: _rootPath!),
                    ),
                  ],
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
        ),
      ],
    );
  }

  Future<void> _openFolder(BuildContext context) async {
    String? path;
    try {
      path = await LinuxFilePicker.pickDirectory();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (path == null) return;
    await ref.read(workspaceProvider.notifier).openDirectory(path);
  }

  Future<void> _newDocument() async {
    final configuredPath = ref.read(settingsProvider).defaultWorkspacePath;
    final String dirPath;
    if (configuredPath != null && configuredPath.isNotEmpty) {
      await Directory(configuredPath).create(recursive: true);
      dirPath = configuredPath;
    } else {
      final dir = await ref
          .read(defaultDirectoryServiceProvider)
          .getDefaultDirectory();
      dirPath = dir.path;
    }
    final name = 'sin_titulo_${DateTime.now().millisecondsSinceEpoch}';
    await ref.read(workspaceProvider.notifier).createDocument(dirPath, name);
  }
}

// ---------------------------------------------------------------------------
// Default directory browser
// ---------------------------------------------------------------------------

/// Browses the default Runa directory (`~/Runa/`) showing folders and
/// `.runa` documents. Folders can be navigated into; documents open in the
/// editor. Provides "Nueva carpeta" and "Nuevo documento" actions.
class _DefaultDirectoryBrowser extends ConsumerStatefulWidget {
  const _DefaultDirectoryBrowser({required this.rootPath});

  final String rootPath;

  @override
  ConsumerState<_DefaultDirectoryBrowser> createState() =>
      _DefaultDirectoryBrowserState();
}

class _DefaultDirectoryBrowserState
    extends ConsumerState<_DefaultDirectoryBrowser> {
  late String _currentPath;
  List<DirectoryItem>? _items;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.rootPath;
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await ref
          .read(fileSystemServiceProvider)
          .listDirectory(_currentPath);
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _items = const []; _isLoading = false; });
    }
  }

  void _navigateInto(String folderPath) {
    setState(() {
      _currentPath = folderPath;
      _items = null;
    });
    _load();
  }

  void _navigateUp() {
    if (_currentPath == widget.rootPath) return;
    _navigateInto(p.dirname(_currentPath));
  }

  @override
  Widget build(BuildContext context) {
    final isAtRoot = _currentPath == widget.rootPath;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 56),
        Row(
          children: [
            if (!isAtRoot)
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 16),
                tooltip: 'Atrás',
                onPressed: _navigateUp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            Expanded(
              child: Text(
                isAtRoot ? 'Documentos' : p.basename(_currentPath),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.folder_open, size: 18),
              tooltip: 'Abrir en editor',
              onPressed: () => ref
                  .read(workspaceProvider.notifier)
                  .openDirectory(_currentPath),
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, size: 18),
              tooltip: 'Nueva carpeta',
              onPressed: () => _promptNewFolder(context),
            ),
            IconButton(
              icon: const Icon(Icons.note_add_outlined, size: 18),
              tooltip: 'Nuevo documento',
              onPressed: () => _promptNewDocument(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_items == null || _items!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Carpeta vacía',
              style: TextStyle(color: colorScheme.outline),
            ),
          )
        else
          for (final item in _items!)
            ListTile(
              dense: true,
              leading: Icon(
                item.isDirectory ? Icons.folder : Icons.description_outlined,
                size: 18,
              ),
              title: Text(
                item.isDirectory
                    ? p.basename(item.path)
                    : p.basenameWithoutExtension(item.path),
              ),
              onTap: item.isDirectory
                  ? () => _navigateInto(item.path)
                  : () => ref
                      .read(workspaceProvider.notifier)
                      .openDocument(item.path),
            ),
      ],
    );
  }

  Future<void> _promptNewFolder(BuildContext context) async {
    final entries = await ref
        .read(fileSystemServiceProvider)
        .listDirectory(_currentPath);
    final existingNames = entries
        .where((e) => e.isDirectory)
        .map((e) => p.basename(e.path))
        .toSet();
    if (!context.mounted) return;
    final name = await showNameInputDialog(
      context,
      title: 'Nueva carpeta',
      hint: 'nombre_carpeta',
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(workspaceProvider.notifier)
        .createSubdirectory(_currentPath, name);
    await _load();
  }

  Future<void> _promptNewDocument(BuildContext context) async {
    final entries = await ref
        .read(fileSystemServiceProvider)
        .listDirectory(_currentPath);
    final existingNames = entries
        .where((e) => !e.isDirectory)
        .map((e) => p.basenameWithoutExtension(e.path))
        .toSet();
    if (!context.mounted) return;
    final name = await showNameInputDialog(
      context,
      title: 'Nuevo documento',
      hint: 'nombre_documento',
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(workspaceProvider.notifier)
        .createDocument(_currentPath, name);
    await _load();
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
                        .read(workspaceProvider.notifier)
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
                  .read(workspaceProvider.notifier)
                  .removeRecentPath(entry.path),
            ),
      onTap: exists
          ? () => ref
              .read(workspaceProvider.notifier)
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
