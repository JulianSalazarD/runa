import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'markdown/code_block_builder.dart';
import 'markdown/math_markdown_extension.dart';

/// Renders [content] as Markdown using the current Material3 theme.
///
/// Shows an italic placeholder when [content] is empty.
/// Supports inline math (`$...$`, `\(...\)`) and block math (`$$...$$`,
/// `\[...\]`) via [InlineMathSyntax] and [BlockMathSyntax].
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Escribe aquí…',
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return MarkdownBody(
      data: content,
      inlineSyntaxes: mathInlineSyntaxes(),
      blockSyntaxes: mathBlockSyntaxes,
      builders: {
        ...mathBuilders(),
        ...codeBlockBuilders(),
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
