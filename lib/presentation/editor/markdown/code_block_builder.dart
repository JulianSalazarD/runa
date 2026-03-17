import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

// ---------------------------------------------------------------------------
// Supported languages for syntax highlighting
// ---------------------------------------------------------------------------

const _supportedLanguages = <String>{
  'dart',
  'python',
  'javascript',
  'typescript',
  'rust',
  'go',
  'c',
  'cpp',
  'java',
  'bash',
  'json',
  'yaml',
  'sql',
  'html',
  'css',
  'markdown',
};

// ---------------------------------------------------------------------------
// CodeBlockBuilder
// ---------------------------------------------------------------------------

/// A [MarkdownElementBuilder] that renders fenced code blocks with syntax
/// highlighting via [HighlightView] when the declared language is supported.
///
/// The language is read from the `class` attribute of the `code` child element
/// which flutter_markdown sets to `"language-<lang>"` for fenced blocks.
///
/// - Supported language → [HighlightView] with [githubTheme] (light) or
///   [atomOneDarkTheme] (dark).
/// - Unsupported or missing language → plain monospaced text in a tinted
///   container (same UX as before this builder was added).
///
/// A header row shows the language label (when known) and a "Copy" button
/// that writes the raw code to the clipboard and shows a brief check-mark
/// feedback for 2 seconds.
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  /// Return a zero-sized dummy widget so that flutter_markdown's internal
  /// `_inlines` stack gets a non-empty children list for the `<code>` inline
  /// element nested inside `<pre>`. Without this, the stack is left dirty and
  /// `_addAnonymousBlockIfNeeded` never clears it, triggering the
  /// `_inlines.isEmpty` assertion when the document finishes building.
  ///
  /// The actual code text is extracted from element children in
  /// [visitElementAfterWithContext], so returning a dummy here is safe.
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
    // flutter_markdown nests a <code class="language-X"> inside each <pre>.
    // The element we receive here IS the <pre>.  Extract the code text and
    // the language from the first (and only) child <code> element, if present.
    String code = '';
    String? language;

    final children = element.children;
    if (children != null && children.isNotEmpty) {
      final first = children.first;
      if (first is md.Element && first.tag == 'code') {
        // Text content of <code>
        code = first.textContent;
        // Attribute is "language-dart", "language-python", etc.
        final rawClass = first.attributes['class'] ?? '';
        if (rawClass.startsWith('language-')) {
          language = rawClass.substring('language-'.length);
        }
      } else {
        // Plain <pre> without a nested <code> (shouldn't happen with
        // flutter_markdown's standard rendering, but handle gracefully).
        code = element.textContent;
      }
    } else {
      code = element.textContent;
    }

    // Remove trailing newline that the Markdown parser appends.
    if (code.endsWith('\n')) {
      code = code.substring(0, code.length - 1);
    }

    final isSupported = language != null && _supportedLanguages.contains(language);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _CodeBlockWidget(
      code: code,
      language: isSupported ? language : null,
      isDark: isDark,
    );
  }
}

// ---------------------------------------------------------------------------
// _CodeBlockWidget — stateful for clipboard feedback
// ---------------------------------------------------------------------------

class _CodeBlockWidget extends StatefulWidget {
  const _CodeBlockWidget({
    required this.code,
    required this.language,
    required this.isDark,
  });

  final String code;
  final String? language;
  final bool isDark;

  @override
  State<_CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<_CodeBlockWidget> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final hasLanguage = widget.language != null;

    final containerColor = isDark
        ? const Color(0xFF282C34) // atom-one-dark background
        : const Color(0xFFF6F8FA); // github light background

    final borderColor = theme.colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header bar: language label + copy button
              _Header(
                language: hasLanguage ? widget.language! : null,
                isDark: isDark,
                copied: _copied,
                onCopy: _copyToClipboard,
              ),
              // Code body
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: hasLanguage && !Platform.isAndroid
                    ? HighlightView(
                        widget.code,
                        language: widget.language!,
                        theme: isDark ? atomOneDarkTheme : githubTheme,
                        padding: const EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      )
                    : _PlainCodeBody(code: widget.code, isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.language,
    required this.isDark,
    required this.copied,
    required this.onCopy,
  });

  final String? language;
  final bool isDark;
  final bool copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final headerColor = isDark
        ? const Color(0xFF21252B)
        : const Color(0xFFEAECEF);

    final labelColor = isDark
        ? const Color(0xFF9DA5B4)
        : const Color(0xFF57606A);

    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Language label
          Text(
            language ?? 'plain text',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: labelColor,
            ),
          ),
          const Spacer(),
          // Copy button
          Tooltip(
            message: copied ? 'Copiado' : 'Copiar',
            child: IconButton(
              key: const ValueKey('copy_button'),
              iconSize: 16,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: Icon(
                copied ? Icons.check : Icons.copy,
                size: 16,
                color: labelColor,
              ),
              onPressed: onCopy,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PlainCodeBody — fallback for unknown / missing languages
// ---------------------------------------------------------------------------

class _PlainCodeBody extends StatelessWidget {
  const _PlainCodeBody({required this.code, required this.isDark});

  final String code;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? const Color(0xFFABB2BF)
        : const Color(0xFF24292E);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: textColor,
        ),
      ),
    );
  }
}

/// Returns the builder map entry for [MarkdownBody.builders].
///
/// Usage:
/// ```dart
/// MarkdownBody(
///   builders: {
///     ...mathBuilders(),
///     ...codeBlockBuilders(),
///   },
/// )
/// ```
Map<String, MarkdownElementBuilder> codeBlockBuilders() => {
      'pre': CodeBlockBuilder(),
    };
