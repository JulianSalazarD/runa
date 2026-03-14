import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

// ---------------------------------------------------------------------------
// TableBuilder
// ---------------------------------------------------------------------------

/// A [MarkdownElementBuilder] that renders GFM tables with zebra striping,
/// column alignment, and horizontal scroll support.
///
/// Registered for tag `'table'`. The builder walks the parsed [md.Element]
/// tree directly to extract header and body cells, using `cell.textContent`
/// for plain-text rendering.
///
/// **Critical note**: `visitText` returns `const SizedBox.shrink()` so that
/// flutter_markdown's internal `_inlines` stack stays clean. Without this
/// override the stack is left dirty when the parser visits text children of
/// block elements, triggering an `_inlines.isEmpty` assertion.
class TableBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) =>
      const SizedBox.shrink();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag != 'table') return null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // -----------------------------------------------------------------------
    // Parse header row
    // -----------------------------------------------------------------------
    final headers = <String>[];
    final alignments = <String>[];

    final thead = _findChild(element, 'thead');
    if (thead != null) {
      final tr = _findChild(thead, 'tr');
      if (tr != null) {
        for (final child in tr.children ?? <md.Node>[]) {
          if (child is md.Element && child.tag == 'th') {
            headers.add(child.textContent);
            alignments.add(child.attributes['align'] ?? 'left');
          }
        }
      }
    }

    // -----------------------------------------------------------------------
    // Parse body rows
    // -----------------------------------------------------------------------
    final rows = <List<String>>[];
    final tbody = _findChild(element, 'tbody');
    if (tbody != null) {
      for (final child in tbody.children ?? <md.Node>[]) {
        if (child is md.Element && child.tag == 'tr') {
          final cells = <String>[];
          for (final tdNode in child.children ?? <md.Node>[]) {
            if (tdNode is md.Element && tdNode.tag == 'td') {
              cells.add(tdNode.textContent);
            }
          }
          rows.add(cells);
        }
      }
    }

    // -----------------------------------------------------------------------
    // Build Flutter Table widget
    // -----------------------------------------------------------------------
    final columnCount = headers.isNotEmpty
        ? headers.length
        : (rows.isNotEmpty ? rows.first.length : 0);

    if (columnCount == 0) return const SizedBox.shrink();

    final columns = List.generate(columnCount, (_) => const IntrinsicColumnWidth());

    final tableRows = <TableRow>[];

    // Header row
    if (headers.isNotEmpty) {
      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
          ),
          children: List.generate(columnCount, (i) {
            final label = i < headers.length ? headers[i] : '';
            final align = i < alignments.length ? alignments[i] : 'left';
            return _TableCell(
              text: label,
              isHeader: true,
              alignment: _textAlign(align),
            );
          }),
        ),
      );
    }

    // Body rows with zebra striping
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final isEven = r.isEven;
      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            color: isEven
                ? colorScheme.surface
                : colorScheme.surfaceContainerLowest,
          ),
          children: List.generate(columnCount, (i) {
            final text = i < row.length ? row[i] : '';
            final align = i < alignments.length ? alignments[i] : 'left';
            return _TableCell(
              text: text,
              isHeader: false,
              alignment: _textAlign(align),
            );
          }),
        ),
      );
    }

    final table = Table(
      border: TableBorder.all(color: colorScheme.outlineVariant),
      columnWidths: {for (var i = 0; i < columnCount; i++) i: columns[i]},
      children: tableRows,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

md.Element? _findChild(md.Element parent, String tag) {
  for (final child in parent.children ?? <md.Node>[]) {
    if (child is md.Element && child.tag == tag) return child;
  }
  return null;
}

TextAlign _textAlign(String align) {
  return switch (align) {
    'center' => TextAlign.center,
    'right' => TextAlign.right,
    _ => TextAlign.left,
  };
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.text,
    required this.isHeader,
    required this.alignment,
  });

  final String text;
  final bool isHeader;
  final TextAlign alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        textAlign: alignment,
        style: isHeader
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Factory helper
// ---------------------------------------------------------------------------

/// Returns the builder map entry for [MarkdownBody.builders].
///
/// Usage:
/// ```dart
/// MarkdownBody(
///   builders: {
///     ...tableBuilders(),
///   },
/// )
/// ```
Map<String, MarkdownElementBuilder> tableBuilders() => {
      'table': TableBuilder(),
    };
