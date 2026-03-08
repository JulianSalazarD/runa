import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';

import 'document_editor_placeholder.dart';
import 'welcome_view.dart';

/// The main application shell.
///
/// - When no directory is open: shows [WelcomeView] full-screen.
/// - When a directory is open: renders a sidebar + main-area layout.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workspaceNotifierProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceNotifierProvider);

    if (workspace.openedDirectoryPath == null) {
      return const Scaffold(body: WelcomeView());
    }

    final activeId = workspace.activeDocumentId;
    final activeDoc = activeId == null
        ? null
        : workspace.openedDocuments
            .where((d) => d.document.id == activeId)
            .firstOrNull;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: _Sidebar(directoryPath: workspace.openedDirectoryPath!),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: activeDoc != null
                ? DocumentEditorPlaceholder(opened: activeDoc)
                : const _EmptyEditorArea(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar (placeholder — full implementation in Part 3)
// ---------------------------------------------------------------------------

class _Sidebar extends ConsumerStatefulWidget {
  const _Sidebar({required this.directoryPath});

  final String directoryPath;

  @override
  ConsumerState<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<_Sidebar> {
  late Future<List<String>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = _loadFiles();
  }

  @override
  void didUpdateWidget(_Sidebar old) {
    super.didUpdateWidget(old);
    if (old.directoryPath != widget.directoryPath) {
      setState(() => _filesFuture = _loadFiles());
    }
  }

  Future<List<String>> _loadFiles() =>
      ref.read(fileSystemServiceProvider).listRunaFiles(widget.directoryPath);

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarHeader(directoryPath: widget.directoryPath),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _filesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final files = snapshot.data!;
              if (files.isEmpty) {
                return const Center(
                  child: Text('Sin documentos', textAlign: TextAlign.center),
                );
              }
              return ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, i) {
                  final filePath = files[i];
                  final isActive = workspace.activeDocumentId != null &&
                      workspace.openedDocuments.any(
                        (d) =>
                            d.path == filePath &&
                            d.document.id == workspace.activeDocumentId,
                      );
                  return ListTile(
                    dense: true,
                    selected: isActive,
                    leading: const Icon(Icons.description_outlined, size: 16),
                    title: Text(
                      p.basenameWithoutExtension(filePath),
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => ref
                        .read(workspaceNotifierProvider.notifier)
                        .openDocument(filePath),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.directoryPath});

  final String directoryPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Text(
        p.basename(directoryPath),
        style: Theme.of(context).textTheme.titleSmall,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty editor area
// ---------------------------------------------------------------------------

class _EmptyEditorArea extends StatelessWidget {
  const _EmptyEditorArea();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Selecciona un documento del sidebar',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
