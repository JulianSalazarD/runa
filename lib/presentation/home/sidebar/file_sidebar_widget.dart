import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';
import 'package:runa/presentation/home/sidebar/name_input_dialog.dart';
import 'package:runa/presentation/settings/settings_screen.dart';

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// The file-tree sidebar for the open workspace directory.
///
/// - Shows `.runa` files and subdirectories in an expandable tree.
/// - Highlights the file matching the active tab.
/// - Provides a "+" button to create new documents / subdirectories.
/// - Right-click context menu for rename / delete / create actions.
/// - Automatically refreshes when the directory contents change on disk.
class FileSidebarWidget extends ConsumerStatefulWidget {
  const FileSidebarWidget({super.key, required this.directoryPath});

  final String directoryPath;

  @override
  ConsumerState<FileSidebarWidget> createState() => _FileSidebarWidgetState();
}

class _FileSidebarWidgetState extends ConsumerState<FileSidebarWidget> {
  final Set<String> _expanded = {};
  List<_SidebarItem>? _items;
  StreamSubscription<FileSystemEvent>? _watchSub;

  @override
  void initState() {
    super.initState();
    _reload();
    _subscribeWatch();
  }

  @override
  void didUpdateWidget(FileSidebarWidget old) {
    super.didUpdateWidget(old);
    if (old.directoryPath != widget.directoryPath) {
      _expanded.clear();
      _watchSub?.cancel();
      _subscribeWatch();
      _reload();
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }

  void _subscribeWatch() {
    _watchSub = ref
        .read(fileSystemServiceProvider)
        .watchDirectory(widget.directoryPath)
        .listen((_) => _reload());
  }

  Future<void> _reload() async {
    final items = await _buildVisible(widget.directoryPath, 0);
    if (mounted) setState(() => _items = items);
  }

  Future<List<_SidebarItem>> _buildVisible(String dir, int depth) async {
    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(dir);
    final result = <_SidebarItem>[];
    for (final entry in entries) {
      result.add(_SidebarItem(
        path: entry.path,
        isDirectory: entry.isDirectory,
        depth: depth,
      ));
      if (entry.isDirectory && _expanded.contains(entry.path)) {
        result.addAll(await _buildVisible(entry.path, depth + 1));
      }
    }
    return result;
  }

  void _toggleExpand(String path) {
    if (_expanded.contains(path)) {
      _expanded.remove(path);
    } else {
      _expanded.add(path);
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceNotifierProvider);
    final items = _items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarHeader(directoryPath: widget.directoryPath),
        Expanded(
          child: items == null
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Sin documentos',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final isActive = !item.isDirectory &&
                            workspace.activeDocumentId != null &&
                            workspace.openedDocuments.any(
                              (d) =>
                                  d.path == item.path &&
                                  d.document.id == workspace.activeDocumentId,
                            );
                        return _SidebarItemTile(
                          item: item,
                          isActive: isActive,
                          isExpanded:
                              item.isDirectory && _expanded.contains(item.path),
                          onTap: item.isDirectory
                              ? () => _toggleExpand(item.path)
                              : () => ref
                                  .read(workspaceNotifierProvider.notifier)
                                  .openDocument(item.path),
                          onContextMenu: (pos) =>
                              _showContextMenu(context, item, pos),
                        );
                      },
                    ),
        ),
        _SidebarFooter(onSettings: _openSettings),
      ],
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Context menu
  // -------------------------------------------------------------------------

  Future<void> _showContextMenu(
    BuildContext context,
    _SidebarItem item,
    Offset position,
  ) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    );

    final menuItems = item.isDirectory
        ? <PopupMenuEntry<String>>[
            const PopupMenuItem(
                value: 'new_doc', child: Text('Nuevo documento aquí')),
            const PopupMenuItem(
                value: 'new_folder', child: Text('Nueva subcarpeta')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'rename', child: Text('Renombrar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ]
        : <PopupMenuEntry<String>>[
            const PopupMenuItem(value: 'open', child: Text('Abrir')),
            const PopupMenuItem(value: 'rename', child: Text('Renombrar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ];

    final selected = await showMenu<String>(
      context: context,
      position: rect,
      items: menuItems,
    );
    if (!mounted || selected == null) return;

    switch (selected) {
      case 'open':
        await ref
            .read(workspaceNotifierProvider.notifier)
            .openDocument(item.path);
      case 'new_doc':
        await _promptNewDocument(item.path);
      case 'new_folder':
        await _promptNewSubdirectory(item.path);
      case 'rename':
        await _promptRename(item);
      case 'delete':
        await _promptDelete(item);
    }
  }

  // -------------------------------------------------------------------------
  // Action prompts
  // -------------------------------------------------------------------------

  Future<void> _promptNewDocument(String directory) async {
    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(directory);
    final existingNames = entries
        .where((e) => !e.isDirectory)
        .map((e) => p.basenameWithoutExtension(e.path))
        .toSet();
    if (!mounted) return;

    final name = await showNameInputDialog(
      context,
      title: 'Nuevo documento',
      hint: 'nombre_documento',
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(workspaceNotifierProvider.notifier)
        .createDocument(directory, name);
  }

  Future<void> _promptNewSubdirectory(String directory) async {
    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(directory);
    final existingNames = entries
        .where((e) => e.isDirectory)
        .map((e) => p.basename(e.path))
        .toSet();
    if (!mounted) return;

    final name = await showNameInputDialog(
      context,
      title: 'Nueva subcarpeta',
      hint: 'nombre_carpeta',
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(workspaceNotifierProvider.notifier)
        .createSubdirectory(directory, name);
  }

  Future<void> _promptRename(_SidebarItem item) async {
    final current = item.isDirectory
        ? p.basename(item.path)
        : p.basenameWithoutExtension(item.path);
    final entries = await ref
        .read(fileSystemServiceProvider)
        .listDirectory(p.dirname(item.path));
    final existingNames = entries
        .where((e) => e.isDirectory == item.isDirectory)
        .map((e) => item.isDirectory
            ? p.basename(e.path)
            : p.basenameWithoutExtension(e.path))
        .where((n) => n != current)
        .toSet();
    if (!mounted) return;

    final name = await showNameInputDialog(
      context,
      title: 'Renombrar',
      hint: current,
      initial: current,
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty || name == current) return;

    final ext = item.isDirectory ? '' : '.runa';
    final newPath = p.join(p.dirname(item.path), '${name.trim()}$ext');

    if (item.isDirectory) {
      await ref
          .read(fileSystemServiceProvider)
          .renameEntry(item.path, newPath);
      if (_expanded.remove(item.path)) _expanded.add(newPath);
      await _reload();
    } else {
      await ref
          .read(workspaceNotifierProvider.notifier)
          .renameDocument(item.path, newPath);
    }
  }

  Future<void> _promptDelete(_SidebarItem item) async {
    final name = p.basename(item.path);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text(
          item.isDirectory
              ? '¿Eliminar la carpeta "$name" y todo su contenido?'
              : '¿Eliminar "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (item.isDirectory) {
      await ref
          .read(workspaceNotifierProvider.notifier)
          .deleteDirectory(item.path);
    } else {
      await ref
          .read(workspaceNotifierProvider.notifier)
          .deleteDocument(item.path);
    }
  }
}

// ---------------------------------------------------------------------------
// Sidebar header
// ---------------------------------------------------------------------------

class _SidebarHeader extends ConsumerWidget {
  const _SidebarHeader({required this.directoryPath});

  final String directoryPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.basename(directoryPath),
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () => _promptNewDocument(context, ref),
                child: const Text('Nuevo documento'),
              ),
              MenuItemButton(
                onPressed: () => _promptNewSubdirectory(context, ref),
                child: const Text('Nueva subcarpeta'),
              ),
            ],
            builder: (context, controller, _) => IconButton(
              icon: const Icon(Icons.add, size: 18),
              tooltip: 'Nuevo…',
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _promptNewDocument(BuildContext context, WidgetRef ref) async {
    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(directoryPath);
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
        .read(workspaceNotifierProvider.notifier)
        .createDocument(directoryPath, name);
  }

  Future<void> _promptNewSubdirectory(
      BuildContext context, WidgetRef ref) async {
    final entries =
        await ref.read(fileSystemServiceProvider).listDirectory(directoryPath);
    final existingNames = entries
        .where((e) => e.isDirectory)
        .map((e) => p.basename(e.path))
        .toSet();
    if (!context.mounted) return;

    final name = await showNameInputDialog(
      context,
      title: 'Nueva subcarpeta',
      hint: 'nombre_carpeta',
      existingNames: existingNames,
    );
    if (name == null || name.isEmpty) return;
    await ref
        .read(workspaceNotifierProvider.notifier)
        .createSubdirectory(directoryPath, name);
  }
}

// ---------------------------------------------------------------------------
// Individual tile
// ---------------------------------------------------------------------------

class _SidebarItemTile extends StatelessWidget {
  const _SidebarItemTile({
    required this.item,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
    required this.onContextMenu,
  });

  final _SidebarItem item;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final void Function(Offset) onContextMenu;

  @override
  Widget build(BuildContext context) {
    final icon = item.isDirectory
        ? (isExpanded ? Icons.folder_open : Icons.folder)
        : Icons.description_outlined;

    return GestureDetector(
      onSecondaryTapDown: (details) => onContextMenu(details.globalPosition),
      child: ListTile(
        dense: true,
        selected: isActive,
        contentPadding: EdgeInsets.only(
          left: 12.0 + item.depth * 16.0,
          right: 8,
        ),
        leading: Icon(icon, size: 16),
        title: Text(
          item.isDirectory
              ? p.basename(item.path)
              : p.basenameWithoutExtension(item.path),
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar footer (gear icon)
// ---------------------------------------------------------------------------

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.settings_outlined, size: 18),
          tooltip: 'Configuración',
          onPressed: onSettings,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal model
// ---------------------------------------------------------------------------

class _SidebarItem {
  const _SidebarItem({
    required this.path,
    required this.isDirectory,
    required this.depth,
  });

  final String path;
  final bool isDirectory;
  final int depth;
}

