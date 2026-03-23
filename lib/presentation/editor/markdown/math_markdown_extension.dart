import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

// ---------------------------------------------------------------------------
// Inline syntax: $...$ and \(...\)
// ---------------------------------------------------------------------------

/// Matches inline math delimited by `$...$` or `\(...\)`.
///
/// Rules:
/// - `\$` (escaped dollar) is NOT treated as math.
/// - The closing delimiter must be on the same line as the opening one.
/// - Content cannot be empty.
///
/// The expression is stored as an element attribute (not text content) to
/// avoid flutter_markdown pushing a stale `_inlines` entry during build.
class InlineMathSyntax extends md.InlineSyntax {

  InlineMathSyntax() : super(_pattern);
  // Matches either:
  //   $<expr>$       — non-escaped dollar, non-empty content, closing $
  //   \(<expr>\)     — \( ... \)
  //
  // The negative lookbehind `(?<!\\)` skips `\$`.
  static const _pattern = r'(?<!\\)\$([^\$\n]+?)\$'
      r'|'
      r'\\\((.+?)\\\)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    // Group 1 → $...$, Group 2 → \(...\)
    final expr = (match[1] ?? match[2])!.trim();
    // Store expression as an attribute, not as text content.
    // This prevents flutter_markdown from visiting a stale md.Text child
    // and leaving _inlines in a dirty state.
    final el = md.Element('math-inline', null)..attributes['expr'] = expr;
    parser.addNode(el);
    return true;
  }
}

// ---------------------------------------------------------------------------
// Block syntax: $$...$$ and \[...\]
// ---------------------------------------------------------------------------

/// Matches display math blocks delimited by `$$...$$` or `\[...\]`.
///
/// The opening delimiter must be the only content on its line.
///
/// The expression is stored as an element attribute (not text content) to
/// avoid flutter_markdown pushing an inline element onto `_inlines` during
/// the text-node visit of a block element, which would leave the stack dirty.
class BlockMathSyntax extends md.BlockSyntax {

  const BlockMathSyntax();
  static final _startPattern = RegExp(r'^\s*(\$\$|\\\[)\s*$');
  static final _endDollar = RegExp(r'^\s*\$\$\s*$');
  static final _endBracket = RegExp(r'^\s*\\\]\s*$');

  @override
  RegExp get pattern => _startPattern;

  @override
  md.Node? parse(md.BlockParser parser) {
    final opening = _startPattern.firstMatch(parser.current.content);
    if (opening == null) return null;

    final isDoubleDollar = opening[1]! == r'$$';
    final endPattern = isDoubleDollar ? _endDollar : _endBracket;

    parser.advance(); // consume opening line

    final exprLines = <String>[];
    while (!parser.isDone) {
      if (endPattern.hasMatch(parser.current.content)) {
        parser.advance(); // consume closing line
        break;
      }
      exprLines.add(parser.current.content);
      parser.advance();
    }

    final expr = exprLines.join('\n').trim();
    // No text children — expression stored as attribute only.
    return md.Element('math-block', null)..attributes['expr'] = expr;
  }
}

// ---------------------------------------------------------------------------
// Inline math builder
// ---------------------------------------------------------------------------

/// Renders `math-inline` elements produced by [InlineMathSyntax].
class MathInlineBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final expr = element.attributes['expr'] ?? '';
    final color = preferredStyle?.color ??
        parentStyle?.color ??
        DefaultTextStyle.of(context).style.color;

    return _InlineMathWidget(expr: expr, color: color);
  }
}

/// Renders an inline math expression, falling back to styled raw text on error.
///
/// Validity is detected synchronously via [Math.parseError] (a public field
/// set by [Math.tex] during its factory call) so we can avoid putting a
/// [Math] widget in the tree at all for invalid expressions.
class _InlineMathWidget extends StatelessWidget {
  const _InlineMathWidget({required this.expr, this.color});

  final String expr;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final mathWidget = Math.tex(
      expr,
      mathStyle: MathStyle.text,
      textStyle: TextStyle(color: color),
      onErrorFallback: (_) => const SizedBox.shrink(),
    );

    if (mathWidget.parseError != null) {
      return Tooltip(
        message: mathWidget.parseError!.message,
        child: Text(
          '\$$expr\$',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return mathWidget;
  }
}

// ---------------------------------------------------------------------------
// Block math builder
// ---------------------------------------------------------------------------

/// Renders `math-block` elements produced by [BlockMathSyntax].
class MathBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final expr = element.attributes['expr'] ?? '';
    return _BlockMathWidget(expr: expr);
  }
}

/// Renders a display math expression, falling back to styled raw text on error.
class _BlockMathWidget extends StatelessWidget {
  const _BlockMathWidget({required this.expr});

  final String expr;

  @override
  Widget build(BuildContext context) {
    final mathWidget = Math.tex(
      expr,
      onErrorFallback: (_) => const SizedBox.shrink(),
    );

    if (mathWidget.parseError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '\$\$$expr\$\$',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(child: mathWidget),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension bundle helpers
// ---------------------------------------------------------------------------

/// Inline syntaxes to pass to [MarkdownBody.inlineSyntaxes].
List<md.InlineSyntax> mathInlineSyntaxes() => [InlineMathSyntax()];

/// Block syntaxes to pass to [MarkdownBody.blockSyntaxes].
const List<md.BlockSyntax> mathBlockSyntaxes = [BlockMathSyntax()];

/// Element builders map to pass to [MarkdownBody.builders].
Map<String, MarkdownElementBuilder> mathBuilders() => {
      'math-inline': MathInlineBuilder(),
      'math-block': MathBlockBuilder(),
    };
