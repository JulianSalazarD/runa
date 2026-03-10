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

/// Indents or unindents the current line by [spaces] spaces.
///
/// [unindent] = false → inserts [spaces] spaces at the start of the current line.
/// [unindent] = true  → removes up to [spaces] leading spaces from the start.
TextEditingValue applyIndent(
  TextEditingValue value, {
  bool unindent = false,
  int spaces = 2,
}) {
  if (!value.selection.isValid) return value;
  final text = value.text;
  final cursorPos = value.selection.baseOffset;
  // Find start of the current line (last '\n' before cursor, +1)
  final lineStart =
      text.lastIndexOf('\n', cursorPos > 0 ? cursorPos - 1 : 0) + 1;

  if (unindent) {
    int count = 0;
    while (count < spaces &&
        lineStart + count < text.length &&
        text[lineStart + count] == ' ') {
      count++;
    }
    if (count == 0) return value;
    final newText =
        '${text.substring(0, lineStart)}${text.substring(lineStart + count)}';
    final newCursor = (cursorPos - count).clamp(lineStart, newText.length);
    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  } else {
    final indent = ' ' * spaces;
    final newText =
        '${text.substring(0, lineStart)}$indent${text.substring(lineStart)}';
    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + spaces),
    );
  }
}
