import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'markdown/code_block_builder.dart';
import 'markdown/footnote_extension.dart';
import 'markdown/math_markdown_extension.dart';
import 'markdown/table_builder.dart';

/// Renders [content] as Markdown using the current Material3 theme.
///
/// Shows an italic placeholder when [content] is empty.
///
/// Supports:
/// - Inline and block math via [InlineMathSyntax] / [BlockMathSyntax]
/// - Syntax-highlighted code blocks via [CodeBlockBuilder]
/// - GFM tables via [TableBuilder]
/// - GFM task lists (checkboxes); interactive when [onCheckboxToggled] is set
/// - GFM strikethrough (`~~text~~`)
/// - GFM autolinks
/// - Footnotes via [FootnoteExtension]
class MarkdownPreviewWidget extends StatelessWidget {
  const MarkdownPreviewWidget({
    super.key,
    required this.content,
    this.onCheckboxToggled,
  });

  final String content;

  /// Called when the user taps a task-list checkbox.
  ///
  /// [index] is the zero-based position of the checkbox in document order.
  /// [checked] is the new desired state.
  ///
  /// When `null`, checkboxes are rendered as read-only.
  final void Function(int index, bool checked)? onCheckboxToggled;

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
    // Fresh registry per build so footnote numbering resets on each render.
    final footnotes = FootnoteExtension.create();
    // Counter reset per render so checkbox indices are stable.
    var checkboxIdx = 0;

    return MarkdownBody(
      data: content,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        ...mathInlineSyntaxes(),
        ...footnotes.inlineSyntaxes,
      ],
      blockSyntaxes: [
        ...mathBlockSyntaxes,
        ...footnotes.blockSyntaxes,
      ],
      builders: {
        ...mathBuilders(),
        ...codeBlockBuilders(),
        ...tableBuilders(),
        ...footnotes.builders,
      },
      checkboxBuilder: (bool checked) {
        final idx = checkboxIdx++;
        return Checkbox(
          value: checked,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          onChanged: onCheckboxToggled == null
              ? null
              : (v) => onCheckboxToggled!(idx, v ?? false),
        );
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        code: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        del: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
    );
  }
}
