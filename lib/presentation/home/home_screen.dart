import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';
import 'package:runa/data/data.dart';
import 'package:runa/presentation/home/sidebar/name_input_dialog.dart';

import '../editor/document_editor.dart';
import '../utils/linux_file_picker.dart';
import 'sidebar/file_sidebar_widget.dart';
import 'tabs/document_tab_bar.dart';
import 'welcome_view.dart';

// ---------------------------------------------------------------------------
// Keyboard-shortcut intents
// ---------------------------------------------------------------------------

class CloseActiveTabIntent extends Intent {
  const CloseActiveTabIntent();
}

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class NewDocumentIntent extends Intent {
  const NewDocumentIntent();
}

class OpenDirectoryIntent extends Intent {
  const OpenDirectoryIntent();
}

const _kShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.keyW, control: true):
      CloseActiveTabIntent(),
  SingleActivator(LogicalKeyboardKey.tab, control: true): NextTabIntent(),
  SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true):
      PreviousTabIntent(),
  SingleActivator(LogicalKeyboardKey.keyN, control: true):
      NewDocumentIntent(),
  SingleActivator(LogicalKeyboardKey.keyO, control: true):
      OpenDirectoryIntent(),
};

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------

/// The main application shell.
///
/// - When no directory is open: shows [WelcomeView] full-screen.
/// - When a directory is open: renders sidebar + tab bar + editor area.
/// - Registers keyboard shortcuts for common actions.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _sidebarVisible = true;

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

    final Widget body = workspace.openedDirectoryPath == null
        ? const WelcomeView()
        : _buildMainArea(workspace);

    return Shortcuts(
      shortcuts: _kShortcuts,
      child: Actions(
        actions: {
          CloseActiveTabIntent: CallbackAction<CloseActiveTabIntent>(
            onInvoke: (_) {
              _closeActiveTab();
              return null;
            },
          ),
          NextTabIntent: CallbackAction<NextTabIntent>(
            onInvoke: (_) {
              _navigateTab(1);
              return null;
            },
          ),
          PreviousTabIntent: CallbackAction<PreviousTabIntent>(
            onInvoke: (_) {
              _navigateTab(-1);
              return null;
            },
          ),
          NewDocumentIntent: CallbackAction<NewDocumentIntent>(
            onInvoke: (_) {
              _newDocument();
              return null;
            },
          ),
          OpenDirectoryIntent: CallbackAction<OpenDirectoryIntent>(
            onInvoke: (_) {
              _openFolder();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(body: body),
        ),
      ),
    );
  }

  Widget _buildMainArea(WorkspaceState workspace) {
    final activeId = workspace.activeDocumentId;
    final activeDoc = activeId == null
        ? null
        : workspace.openedDocuments
            .where((d) => d.document.id == activeId)
            .firstOrNull;

    return Row(
      children: [
        // Sidebar panel — colapsable
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _sidebarVisible ? 250 : 0,
          child: _sidebarVisible
              ? FileSidebarWidget(
                  directoryPath: workspace.openedDirectoryPath!,
                )
              : const SizedBox.shrink(),
        ),
        // Toggle strip + divider
        Container(
          width: 20,
          decoration: BoxDecoration(
            border: Border(
              left: _sidebarVisible
                  ? BorderSide(color: Theme.of(context).dividerColor)
                  : BorderSide.none,
              right: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Tooltip(
            message:
                _sidebarVisible ? 'Ocultar sidebar' : 'Mostrar sidebar',
            child: InkWell(
              onTap: () => setState(() => _sidebarVisible = !_sidebarVisible),
              child: Center(
                child: Icon(
                  _sidebarVisible
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DocumentTabBar(),
              Expanded(
                child: activeDoc != null
                    ? DocumentEditor(opened: activeDoc)
                    : const _EmptyEditorArea(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Shortcut actions
  // -------------------------------------------------------------------------

  Future<void> _closeActiveTab() async {
    final ws = ref.read(workspaceNotifierProvider);
    final activeId = ws.activeDocumentId;
    if (activeId == null) return;
    final doc =
        ws.openedDocuments.firstWhere((d) => d.document.id == activeId);
    await confirmAndCloseDocument(context, ref, doc);
  }

  void _navigateTab(int delta) {
    final ws = ref.read(workspaceNotifierProvider);
    if (ws.openedDocuments.isEmpty) return;
    final currentIndex = ws.openedDocuments
        .indexWhere((d) => d.document.id == ws.activeDocumentId);
    if (currentIndex == -1) return;
    final len = ws.openedDocuments.length;
    final nextIndex = ((currentIndex + delta) % len + len) % len;
    ref
        .read(workspaceNotifierProvider.notifier)
        .setActiveDocument(ws.openedDocuments[nextIndex].document.id);
  }

  Future<void> _newDocument() async {
    final ws = ref.read(workspaceNotifierProvider);
    final directory = ws.openedDirectoryPath;
    if (directory != null) {
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
    } else {
      final dir = await const DefaultDirectoryService().getDefaultDirectory();
      final name = 'sin_titulo_${DateTime.now().millisecondsSinceEpoch}';
      await ref
          .read(workspaceNotifierProvider.notifier)
          .createDocument(dir.path, name);
    }
  }

  Future<void> _openFolder() async {
    String? path;
    try {
      path = await LinuxFilePicker.pickDirectory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
      return;
    }
    if (path == null) return;
    await ref.read(workspaceNotifierProvider.notifier).openDirectory(path);
  }
}

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
