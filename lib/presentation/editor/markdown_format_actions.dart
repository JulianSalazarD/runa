import 'package:flutter/services.dart';

/// Wraps the current selection in [open] and [close] delimiters.
///
/// - Non-collapsed selection → wraps the selected text; cursor placed after [close].
/// - Collapsed selection → inserts [open][close] and places cursor between them.
TextEditingValue applyInlineWrap(
  TextEditingValue value,
  String open,
  String close,
) {
  if (!value.selection.isValid) return value;
  final text = value.text;
  final start = value.selection.start;
  final end = value.selection.end;
  final selected = text.substring(start, end);
  final newText =
      '${text.substring(0, start)}$open$selected$close${text.substring(end)}';
  final newOffset = value.selection.isCollapsed
      ? start + open.length // cursor between open/close
      : start + open.length + selected.length + close.length; // cursor after close
  return value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: newOffset),
  );
}

/// Wraps the current selection as a Markdown link.
///
/// - Non-collapsed selection → `[selected](url)`, selects "url".
/// - Collapsed selection → `[](url)`, cursor placed inside `[]` at position 1.
TextEditingValue applyLinkWrap(TextEditingValue value) {
  if (!value.selection.isValid) return value;
  final text = value.text;
  final start = value.selection.start;
  final end = value.selection.end;
  final selected = text.substring(start, end);

  if (value.selection.isCollapsed) {
    const inserted = '[](url)';
    final newText =
        '${text.substring(0, start)}$inserted${text.substring(end)}';
    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1), // inside []
    );
  } else {
    final inserted = '[$selected](url)';
    final newText =
        '${text.substring(0, start)}$inserted${text.substring(end)}';
    final urlStart = start + 1 + selected.length + 2; // after "[selected]("
    return value.copyWith(
      text: newText,
      selection: TextSelection(
        baseOffset: urlStart,
        extentOffset: urlStart + 3, // select "url"
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// applyIndent helpers
// ---------------------------------------------------------------------------

/// Returns the offset of the first character on the line containing [pos].
int _lineStartOf(String text, int pos) =>
    text.lastIndexOf('\n', pos > 0 ? pos - 1 : 0) + 1;

/// Returns the text of the line containing [pos] (without trailing newline).
String _lineContentAt(String text, int pos) {
  final start = _lineStartOf(text, pos);
  final end = text.indexOf('\n', pos);
  return text.substring(start, end < 0 ? text.length : end);
}

/// Matches Markdown list items (unordered or ordered) at any indent level.
final _listRe = RegExp(r'^\s*[-*+]\s|^\s*\d+\.\s');

/// Indents or unindents text based on the current selection.
///
/// **Collapsed selection (no selection):**
/// - [unindent] = false:
///   - On a Markdown list-item line → inserts [spaces] spaces at the **line start**
///     (converts the item to a sub-item).
///   - Otherwise → inserts [spaces] spaces at the **cursor position**.
/// - [unindent] = true → removes up to [spaces] leading spaces from the
///   **line start**; cursor is clamped so it never goes before the new line start.
///
/// **Non-collapsed selection:**
/// - [unindent] = false → inserts [spaces] spaces at the start of every line
///   covered by the selection; selection is extended to cover the added characters.
/// - [unindent] = true → removes up to [spaces] leading spaces from the start of
///   every covered line; selection shrinks accordingly.
TextEditingValue applyIndent(
  TextEditingValue value, {
  bool unindent = false,
  int spaces = 2,
}) {
  if (!value.selection.isValid) return value;
  final text = value.text;
  final sel = value.selection;
  final indent = ' ' * spaces;

  // ─── Collapsed: single-line operation ─────────────────────────────────────
  if (sel.isCollapsed) {
    final lineStart = _lineStartOf(text, sel.baseOffset);

    if (unindent) {
      // Remove up to `spaces` leading spaces from line start.
      int count = 0;
      while (count < spaces &&
          lineStart + count < text.length &&
          text[lineStart + count] == ' ') {
        count++;
      }
      if (count == 0) return value;
      final newText =
          '${text.substring(0, lineStart)}${text.substring(lineStart + count)}';
      final newCursor =
          (sel.baseOffset - count).clamp(lineStart, newText.length);
      return value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // Tab: list-item line → indent the whole line (insert at line start).
    if (_listRe.hasMatch(_lineContentAt(text, sel.baseOffset))) {
      final newText =
          '${text.substring(0, lineStart)}$indent${text.substring(lineStart)}';
      return value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.baseOffset + spaces),
      );
    }

    // Tab: regular line → insert spaces at the cursor position.
    final newText =
        '${text.substring(0, sel.baseOffset)}$indent${text.substring(sel.baseOffset)}';
    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.baseOffset + spaces),
    );
  }

  // ─── Non-collapsed: all lines covered by the selection ────────────────────
  final firstLineStart = _lineStartOf(text, sel.start);
  final prefix = text.substring(0, firstLineStart);
  final region = text.substring(firstLineStart, sel.end);
  final suffix = text.substring(sel.end);

  final lines = region.split('\n');
  final newLines = <String>[];
  int totalDelta = 0;
  int deltaBeforeSelStart = 0;
  int regionOffset = 0;

  for (final line in lines) {
    final lineStartInText = firstLineStart + regionOffset;
    int delta;
    String newLine;

    if (unindent) {
      int count = 0;
      while (count < spaces && count < line.length && line[count] == ' ') {
        count++;
      }
      newLine = line.substring(count);
      delta = -count;
    } else {
      newLine = '$indent$line';
      delta = spaces;
    }

    newLines.add(newLine);
    totalDelta += delta;
    // Changes to lines that start before sel.start also shift sel.start.
    if (lineStartInText < sel.start) deltaBeforeSelStart += delta;
    regionOffset += line.length + 1; // +1 for the '\n' separator
  }

  final newRegion = newLines.join('\n');
  final newText = '$prefix$newRegion$suffix';
  final newStart =
      (sel.start + deltaBeforeSelStart).clamp(firstLineStart, newText.length);
  final newEnd = (sel.end + totalDelta).clamp(newStart, newText.length);

  return value.copyWith(
    text: newText,
    selection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
  );
}
