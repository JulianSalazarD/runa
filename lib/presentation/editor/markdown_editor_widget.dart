import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'markdown_format_actions.dart';

/// A growing, monospaced [TextField] for editing raw Markdown.
///
/// Calls [onChanged] with a 300 ms debounce after each keystroke.
/// When focus is lost the pending debounce is cancelled and [onChanged]
/// is invoked immediately, ensuring no edits are lost.
///
/// If [onEnterAtEnd] is provided, pressing Enter when the cursor is at
/// the end of the text and the last line is empty (text is '' or ends
/// with '\n') triggers [onEnterAtEnd] instead of inserting a newline.
/// The trailing '\n', if present, is removed and flushed via [onChanged]
/// before the callback fires.
class MarkdownEditorWidget extends StatefulWidget {
  const MarkdownEditorWidget({
    super.key,
    required this.initialContent,
    required this.onChanged,
    this.autoFocus = false,
    this.onEnterAtEnd,
    this.fontFamily,
    this.fontSize,
  });

  final String initialContent;
  final ValueChanged<String> onChanged;

  /// Whether to request focus when this widget is first built.
  final bool autoFocus;

  /// Called when Enter is pressed at the end of an empty last line.
  final VoidCallback? onEnterAtEnd;

  /// Font family for the raw editor text. Defaults to monospace.
  final String? fontFamily;

  /// Font size for the raw editor text. Defaults to 16.
  final double? fontSize;

  @override
  State<MarkdownEditorWidget> createState() => _MarkdownEditorWidgetState();
}

class _MarkdownEditorWidgetState extends State<MarkdownEditorWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  static const _debounceDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _focusNode = FocusNode()..addListener(_onFocusChange);
    if (!Platform.isAndroid && !Platform.isIOS) {
      _focusNode.onKeyEvent = _handleKeyEvent;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _debounce?.cancel();
      _debounce = null;
      widget.onChanged(_controller.text);
    }
  }

  void _scheduleChange() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => widget.onChanged(_controller.text));
  }

  void _applyFormat(TextEditingValue Function(TextEditingValue) transform) {
    final newValue = transform(_controller.value);
    if (newValue == _controller.value) return;
    _controller.value = newValue;
    _scheduleChange();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;

    // ----------------------------------------------------------------
    // Ctrl+Enter → create new block (existing behaviour)
    // ----------------------------------------------------------------
    if (ctrl && !shift && key == LogicalKeyboardKey.enter) {
      if (widget.onEnterAtEnd == null) return KeyEventResult.ignored;

      final text = _controller.text;
      final selection = _controller.selection;
      final atEnd =
          selection.isCollapsed && selection.baseOffset == text.length;

      if (atEnd && (text.isEmpty || text.endsWith('\n'))) {
        if (text.endsWith('\n')) {
          final trimmed = text.substring(0, text.length - 1);
          _controller.text = trimmed;
          _controller.selection =
              TextSelection.collapsed(offset: trimmed.length);
        }
        _debounce?.cancel();
        _debounce = null;
        widget.onChanged(_controller.text);
        widget.onEnterAtEnd?.call();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // ----------------------------------------------------------------
    // Format shortcuts (Ctrl, no Shift)
    // ----------------------------------------------------------------
    if (ctrl && !shift) {
      if (key == LogicalKeyboardKey.keyB) {
        _applyFormat((v) => applyInlineWrap(v, '**', '**'));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyI) {
        _applyFormat((v) => applyInlineWrap(v, '_', '_'));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyK) {
        _applyFormat(applyLinkWrap);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.backquote) {
        _applyFormat((v) => applyInlineWrap(v, '`', '`'));
        return KeyEventResult.handled;
      }
    }

    // ----------------------------------------------------------------
    // Tab / Shift+Tab → indent / unindent
    // ----------------------------------------------------------------
    if (!ctrl && key == LogicalKeyboardKey.tab) {
      _applyFormat((v) => applyIndent(v, unindent: shift));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    final selectionColor = Theme.of(context)
        .colorScheme
        .primary
        .withValues(alpha: 0.25);

    return TextSelectionTheme(
      data: TextSelectionThemeData(selectionColor: selectionColor),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        autofocus: widget.autoFocus,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: null,
        style: TextStyle(
          fontFamily: widget.fontFamily ?? 'monospace',
          fontSize: widget.fontSize ?? 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          hintText: 'Escribe Markdown aquí…',
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
      ),
    );
  }
}
