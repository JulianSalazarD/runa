import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown_format_actions.dart';

TextEditingValue _value(String text, {int start = 0, int end = -1}) {
  final e = end < 0 ? text.length : end;
  return TextEditingValue(
    text: text,
    selection: TextSelection(baseOffset: start, extentOffset: e),
  );
}

TextEditingValue _cursor(String text, int offset) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

void main() {
  // ----------------------------------------------------------------
  // applyInlineWrap
  // ----------------------------------------------------------------
  group('applyInlineWrap — Ctrl+B (bold)', () {
    test('selection is wrapped in **', () {
      final result = applyInlineWrap(
        _value('hello world', start: 6, end: 11), // selects "world"
        '**',
        '**',
      );
      expect(result.text, 'hello **world**');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 15); // after second **
    });

    test('collapsed cursor inserts ** ** and places cursor between', () {
      final result = applyInlineWrap(
        _cursor('hello', 5), // cursor at end
        '**',
        '**',
      );
      expect(result.text, 'hello****');
      expect(result.selection.baseOffset, 7); // inside the **...**
    });

    test('invalid selection returns value unchanged', () {
      const v = TextEditingValue(text: 'hello');
      final result = applyInlineWrap(v, '**', '**');
      expect(result, v);
    });
  });

  group('applyInlineWrap — Ctrl+I (italic)', () {
    test('wraps selection in _', () {
      final result = applyInlineWrap(
        _value('say hello', start: 4, end: 9),
        '_',
        '_',
      );
      expect(result.text, 'say _hello_');
    });
  });

  group('applyInlineWrap — Ctrl+` (code)', () {
    test('wraps selection in backticks', () {
      final result = applyInlineWrap(
        _value('run main', start: 4, end: 8),
        '`',
        '`',
      );
      expect(result.text, 'run `main`');
    });
  });

  // ----------------------------------------------------------------
  // applyLinkWrap
  // ----------------------------------------------------------------
  group('applyLinkWrap — Ctrl+K', () {
    test('selection is wrapped as [selected](url) with url selected', () {
      final result = applyLinkWrap(_value('click here', start: 6, end: 10));
      expect(result.text, 'click [here](url)');
      // "url" starts at offset 13 and has length 3
      expect(result.selection.baseOffset, 13);
      expect(result.selection.extentOffset, 16);
    });

    test('collapsed cursor inserts [](url) and places cursor inside []', () {
      final result = applyLinkWrap(_cursor('text', 4));
      expect(result.text, 'text[](url)');
      expect(result.selection.baseOffset, 5); // inside []
      expect(result.selection.isCollapsed, isTrue);
    });
  });

  // ----------------------------------------------------------------
  // applyIndent
  // ----------------------------------------------------------------
  group('applyIndent — Tab', () {
    test('adds 2 spaces at line start', () {
      final result = applyIndent(_cursor('- item', 6));
      expect(result.text, '  - item');
      expect(result.selection.baseOffset, 8); // cursor moved right by 2
    });

    test('cursor in middle of line indents at line start', () {
      final result = applyIndent(_cursor('hello', 3));
      expect(result.text, '  hello');
      expect(result.selection.baseOffset, 5); // 3 + 2
    });

    test('multi-line: only current line is indented', () {
      // cursor on second line
      const text = 'first line\nsecond';
      final result = applyIndent(_cursor(text, 15)); // inside "second"
      expect(result.text, 'first line\n  second');
    });
  });

  group('applyIndent — Shift+Tab (unindent)', () {
    test('removes 2 leading spaces from line start', () {
      final result = applyIndent(_cursor('  - item', 6), unindent: true);
      expect(result.text, '- item');
      expect(result.selection.baseOffset, 4); // 6 - 2
    });

    test('removes only available spaces (less than 2)', () {
      final result = applyIndent(_cursor(' item', 3), unindent: true);
      expect(result.text, 'item');
      expect(result.selection.baseOffset, 2); // 3 - 1
    });

    test('line with no leading spaces returns value unchanged', () {
      final original = _cursor('item', 2);
      final result = applyIndent(original, unindent: true);
      expect(result, original);
    });

    test('cursor at start of line is clamped correctly', () {
      final result = applyIndent(_cursor('  text', 0), unindent: true);
      expect(result.text, 'text');
      expect(result.selection.baseOffset, 0);
    });
  });
}
