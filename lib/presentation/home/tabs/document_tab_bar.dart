import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';

// ---------------------------------------------------------------------------
// Public utility
// ---------------------------------------------------------------------------

/// Closes [doc]'s tab, showing an unsaved-changes confirmation dialog if
/// [doc.hasUnsavedChanges] is true.
///
/// Called by both [DocumentTabBar] and the `Ctrl+W` keyboard shortcut
/// in [HomeScreen].
Future<void> confirmAndCloseDocument(
  BuildContext context,
  WidgetRef ref,
  OpenedDocument doc,
) async {
  if (doc.hasUnsavedChanges) {
    final action = await showDialog<_CloseAction>(
      context: context,
      builder: (_) => _UnsavedDialog(name: p.basenameWithoutExtension(doc.path)),
    );
    if (action == null) return;
    if (action == _CloseAction.save) {
      await ref.read(documentRepositoryProvider).save(doc.document, doc.path);
    }
  }
  ref.read(workspaceProvider.notifier).closeDocument(doc.document.id);
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

/// Horizontal scrollable bar showing one tab per open document.
///
/// - Clicking a tab makes it active.
/// - Clicking × closes the tab (with unsaved-changes confirmation if needed).
/// - The active tab is highlighted with a bottom border and background tint.
/// - Tabs with unsaved changes show a ● indicator.
class DocumentTabBar extends ConsumerWidget {
  const DocumentTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final docs = workspace.openedDocuments;

    if (docs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, i) {
          final doc = docs[i];
          final isActive = doc.document.id == workspace.activeDocumentId;
          return _Tab(
            opened: doc,
            isActive: isActive,
            onTap: () => ref
                .read(workspaceProvider.notifier)
                .setActiveDocument(doc.document.id),
            onClose: () => confirmAndCloseDocument(context, ref, doc),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual tab
// ---------------------------------------------------------------------------

class _Tab extends StatelessWidget {
  const _Tab({
    required this.opened,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final OpenedDocument opened;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isActive ? colorScheme.secondaryContainer.withOpacity(0.4) : null,
          border: Border(
            bottom: isActive
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
            right: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (opened.showSavedIndicator)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: colorScheme.primary,
                  semanticLabel: 'Guardado',
                ),
              )
            else if (opened.hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '●',
                  style: TextStyle(fontSize: 8, color: colorScheme.primary),
                  semanticsLabel: 'Cambios sin guardar',
                ),
              ),
            Text(
              p.basenameWithoutExtension(opened.path),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Unsaved-changes confirmation dialog
// ---------------------------------------------------------------------------

enum _CloseAction { save, discard }

class _UnsavedDialog extends StatelessWidget {
  const _UnsavedDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambios sin guardar'),
      content: Text('¿Deseas guardar "$name" antes de cerrar?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_CloseAction.discard),
          child: const Text('Descartar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_CloseAction.save),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
