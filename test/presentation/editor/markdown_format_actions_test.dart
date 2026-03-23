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
  group('applyIndent — Tab (collapsed)', () {
    test('list item: inserts 2 spaces at line start', () {
      // "- item" is a list item → indent the whole line
      final result = applyIndent(_cursor('- item', 6));
      expect(result.text, '  - item');
      expect(result.selection.baseOffset, 8); // cursor moved right by 2
    });

    test('list item with *: inserts 2 spaces at line start', () {
      final result = applyIndent(_cursor('* todo', 4));
      expect(result.text, '  * todo');
      expect(result.selection.baseOffset, 6);
    });

    test('ordered list item: inserts 2 spaces at line start', () {
      final result = applyIndent(_cursor('1. item', 5));
      expect(result.text, '  1. item');
      expect(result.selection.baseOffset, 7);
    });

    test('regular line: inserts 2 spaces at cursor position', () {
      final result = applyIndent(_cursor('hello', 3));
      expect(result.text, 'hel  lo');
      expect(result.selection.baseOffset, 5); // 3 + 2
    });

    test('regular multi-line text: inserts at cursor, not line start', () {
      const text = 'first line\nsecond';
      final result = applyIndent(_cursor(text, 15)); // inside "second"
      // "second" is not a list item → insert at cursor (pos 15 = "seco|nd")
      expect(result.text, 'first line\nseco  nd');
      expect(result.selection.baseOffset, 17);
    });
  });

  group('applyIndent — Tab (non-collapsed, multiline)', () {
    test('3-line selection: all lines indented at line start', () {
      const text = 'line1\nline2\nline3';
      // Select from start of line1 to end of line3
      final result = applyIndent(_value(text, end: 17));
      expect(result.text, '  line1\n  line2\n  line3');
    });

    test('selection spanning 2 lines: both indented', () {
      const text = 'alpha\nbeta';
      final result = applyIndent(_value(text, start: 2, end: 9));
      expect(result.text, '  alpha\n  beta');
    });

    test('selection within single line: that line is indented', () {
      final result = applyIndent(_value('hello world', start: 2, end: 7));
      expect(result.text, '  hello world');
    });
  });

  group('applyIndent — Shift+Tab (collapsed)', () {
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

  group('applyIndent — Shift+Tab (non-collapsed, multiline)', () {
    test('2-line selection: both lines unindented', () {
      const text = '  alpha\n  beta';
      final result = applyIndent(_value(text, end: 14),
          unindent: true);
      expect(result.text, 'alpha\nbeta');
    });

    test('line with only 1 space: removes just 1', () {
      const text = ' line1\n  line2';
      final result = applyIndent(_value(text, end: 14),
          unindent: true);
      expect(result.text, 'line1\nline2');
    });

    test('line with no spaces: left unchanged, others unindented', () {
      const text = '  line1\nline2';
      final result = applyIndent(_value(text, end: 13),
          unindent: true);
      expect(result.text, 'line1\nline2');
    });
  });
}
