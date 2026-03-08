import 'dart:async';

import 'package:flutter/material.dart';

/// A growing, monospaced [TextField] for editing raw Markdown.
///
/// Calls [onChanged] with a 300 ms debounce after each keystroke.
/// When focus is lost the pending debounce is cancelled and [onChanged]
/// is invoked immediately, ensuring no edits are lost.
class MarkdownEditorWidget extends StatefulWidget {
  const MarkdownEditorWidget({
    super.key,
    required this.initialContent,
    required this.onChanged,
  });

  final String initialContent;
  final ValueChanged<String> onChanged;

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

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onTextChanged,
      minLines: 1,
      maxLines: null,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      decoration: const InputDecoration(
        hintText: 'Escribe Markdown aquí…',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
        isDense: true,
      ),
    );
  }
}
