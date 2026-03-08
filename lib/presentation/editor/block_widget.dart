import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

/// Dispatches to the appropriate block renderer based on [block] type.
///
/// Fase 2 — Parte 2: placeholder renderers (raw text / ink box).
/// Parts 3–4 will replace these with the real editor and canvas widgets.
class BlockWidget extends StatelessWidget {
  const BlockWidget({super.key, required this.block});

  final Block block;

  @override
  Widget build(BuildContext context) => switch (block) {
        MarkdownBlock(:final content) => _MarkdownView(content: content),
        InkBlock(:final height) => _InkPlaceholder(height: height),
      };
}

// ---------------------------------------------------------------------------
// Placeholder renderers (replaced in Parts 3–4)
// ---------------------------------------------------------------------------

class _MarkdownView extends StatelessWidget {
  const _MarkdownView({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: content.isEmpty
          ? Text(
              'Escribe aquí…',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            )
          : Text(content),
    );
  }
}

class _InkPlaceholder extends StatelessWidget {
  const _InkPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'Canvas de tinta (Fase 2, Parte 4)',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
