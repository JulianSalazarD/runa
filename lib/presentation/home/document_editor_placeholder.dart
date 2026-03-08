import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:runa/application/application.dart';

/// Placeholder shown in the main editor area until the real editor is built
/// (Fase 2).
///
/// Displays the active document's filename, block count, and a Save button.
class DocumentEditorPlaceholder extends ConsumerWidget {
  const DocumentEditorPlaceholder({super.key, required this.opened});

  final OpenedDocument opened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(opened: opened),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  p.basenameWithoutExtension(opened.path),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _blockLabel(opened.document.blocks.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _blockLabel(int count) => switch (count) {
        0 => 'Sin bloques',
        1 => '1 bloque',
        _ => '$count bloques',
      };
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.opened});

  final OpenedDocument opened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              p.basenameWithoutExtension(opened.path),
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (opened.hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '●',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                semanticsLabel: 'Cambios sin guardar',
              ),
            ),
          TextButton(
            onPressed: () => _save(ref),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(WidgetRef ref) async {
    final repo = ref.read(documentRepositoryProvider);
    await repo.save(opened.document, opened.path);
  }
}
