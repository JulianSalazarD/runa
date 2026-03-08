import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runa/application/application.dart';

import 'document_editor_placeholder.dart';
import 'sidebar/file_sidebar_widget.dart';
import 'welcome_view.dart';

/// The main application shell.
///
/// - When no directory is open: shows [WelcomeView] full-screen.
/// - When a directory is open: renders a [FileSidebarWidget] + main-area layout.
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
            child:
                FileSidebarWidget(directoryPath: workspace.openedDirectoryPath!),
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
