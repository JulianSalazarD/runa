import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Public helper
// ---------------------------------------------------------------------------

/// Shows a validated name-input dialog and returns the entered name (trimmed)
/// or `null` if the user cancels.
///
/// Behaviour:
/// - The confirm button is disabled while the field is empty, the name
///   contains forbidden filesystem characters, or the trimmed name matches
///   an entry in [existingNames].
/// - [existingNames] is compared case-sensitively.
Future<String?> showNameInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? initial,
  Set<String> existingNames = const {},
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => NameInputDialog(
      title: title,
      hint: hint,
      initial: initial,
      existingNames: existingNames,
    ),
  );
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A validated name-input dialog used for creating and renaming documents
/// and subdirectories.
///
/// Validation rules (applied to the trimmed input):
/// - Empty string → confirm disabled, no error shown.
/// - Contains any of `/ \ : * ? " < > |` → error text shown, confirm disabled.
/// - Matches a name in [existingNames] → error text shown, confirm disabled.
class NameInputDialog extends StatefulWidget {
  const NameInputDialog({
    super.key,
    required this.title,
    required this.hint,
    this.initial,
    this.existingNames = const {},
  });

  final String title;
  final String hint;

  /// Pre-filled value for the text field (used when renaming).
  final String? initial;

  /// Names that are already taken in the target location.
  /// The dialog shows an error if the user enters a name found in this set.
  final Set<String> existingNames;

  @override
  State<NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  late final TextEditingController _ctrl;

  // Characters that are invalid in file / directory names across platforms.
  static final _invalidCharsRe = RegExp(r'[/\\:*?"<>|]');

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _name => _ctrl.text.trim();

  /// Returns an error string to display, or `null` when the current value is
  /// acceptable (including the special case where the field is empty — the
  /// confirm button is simply disabled without an error message).
  String? get _errorText {
    final name = _name;
    if (name.isEmpty) return null;
    if (_invalidCharsRe.hasMatch(name)) {
      return 'Caracteres no permitidos: / \\ : * ? " < > |';
    }
    if (widget.existingNames.contains(name)) {
      return 'Ya existe un elemento con ese nombre';
    }
    return null;
  }

  bool get _canConfirm => _name.isNotEmpty && _errorText == null;

  void _submit() {
    if (_canConfirm) Navigator.of(context).pop(_name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: _errorText,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _canConfirm ? _submit : null,
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
