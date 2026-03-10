/// Toggles the [index]-th checkbox in [source].
///
/// Pattern matches `- [ ]` or `- [x]` (case-insensitive).
/// If [index] is out of range, [source] is returned unchanged.
String toggleCheckboxAt(String source, int index, bool checked) {
  final pattern = RegExp(r'- \[[ xX]\]', multiLine: true);
  final matches = pattern.allMatches(source).toList();
  if (index >= matches.length) return source;
  final m = matches[index];
  return source.replaceRange(m.start, m.end, checked ? '- [x]' : '- [ ]');
}
