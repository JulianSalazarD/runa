import 'package:flutter_math_fork/flutter_math.dart' show MathStyle;
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/application/services/math_rasterizer.dart';

// ---------------------------------------------------------------------------
// Math syntax classes (pure Dart — no Flutter widgets)
// ---------------------------------------------------------------------------

/// Matches inline math `$...$` or `\(...\)` and emits a `math-inline` element
/// whose `expr` attribute holds the TeX expression.
class _InlineMathMdSyntax extends md.InlineSyntax {
  _InlineMathMdSyntax() : super(_pat);
  static const _pat = r'(?<!\\)\$([^\$\n]+?)\$|\\\((.+?)\\\)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final expr = (match[1] ?? match[2])!.trim();
    parser.addNode(md.Element('math-inline', null)..attributes['expr'] = expr);
    return true;
  }
}

/// Matches display-math blocks `$$...$$` or `\[...\]` and emits a `math-block`
/// element whose `expr` attribute holds the TeX expression.
class _BlockMathMdSyntax extends md.BlockSyntax {
  const _BlockMathMdSyntax();

  static final _start = RegExp(r'^\s*(\$\$|\\\[)\s*$');
  static final _endDollar = RegExp(r'^\s*\$\$\s*$');
  static final _endBracket = RegExp(r'^\s*\\\]\s*$');

  @override
  RegExp get pattern => _start;

  @override
  md.Node? parse(md.BlockParser parser) {
    final opening = _start.firstMatch(parser.current.content);
    if (opening == null) return null;
    final isDollar = opening[1] == r'$$';
    final endPat = isDollar ? _endDollar : _endBracket;
    parser.advance();
    final lines = <String>[];
    while (!parser.isDone) {
      if (endPat.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      }
      lines.add(parser.current.content);
      parser.advance();
    }
    return md.Element('math-block', null)
      ..attributes['expr'] = lines.join('\n').trim();
  }
}

// ---------------------------------------------------------------------------
// MarkdownPdfRenderer
// ---------------------------------------------------------------------------

class MarkdownPdfRenderer {
  MarkdownPdfRenderer({MathRasterizer? mathRasterizer})
      : _math = mathRasterizer ?? MathRasterizer(),
        _font = pw.Font.helvetica(),
        _fontBold = pw.Font.helveticaBold(),
        _fontItalic = pw.Font.helveticaOblique(),
        _fontBoldItalic = pw.Font.helveticaBoldOblique(),
        _fontMono = pw.Font.courier();

  final MathRasterizer _math;
  final pw.Font _font;
  final pw.Font _fontBold;
  final pw.Font _fontItalic;
  // ignore: unused_field
  final pw.Font _fontBoldItalic;
  final pw.Font _fontMono;

  /// Parses [markdown] and returns a list of PDF widgets.
  ///
  /// Math expressions (`$...$`, `$$...$$`) are rasterized to PNG images.
  /// If rasterization fails the expression is rendered as `[formula: tex]`
  /// in red — the export continues without crashing.
  Future<List<pw.Widget>> render(String markdown) async {
    if (markdown.trim().isEmpty) return [];
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [_InlineMathMdSyntax()],
      blockSyntaxes: const [_BlockMathMdSyntax()],
    );
    return _renderNodes(document.parse(markdown));
  }

  Future<List<pw.Widget>> _renderNodes(List<md.Node> nodes) async {
    final widgets = <pw.Widget>[];
    for (final node in nodes) {
      final w = await _renderNode(node);
      if (w != null) widgets.add(w);
    }
    return widgets;
  }

  Future<pw.Widget?> _renderNode(md.Node node) async {
    if (node is! md.Element) {
      if (node is md.Text) return pw.Text(node.text, style: _baseStyle());
      return null;
    }
    switch (node.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return _renderHeading(node);
      case 'p':
        return _renderParagraph(node);
      case 'pre':
        return _renderCodeBlock(node);
      case 'ul':
        return _renderList(node, ordered: false);
      case 'ol':
        return _renderList(node, ordered: true);
      case 'blockquote':
        return _renderBlockquote(node);
      case 'table':
        return _renderTable(node);
      case 'hr':
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Divider(color: PdfColors.grey400),
        );
      case 'math-inline':
        return _mathWidget(node.attributes['expr'] ?? '', MathStyle.text);
      case 'math-block':
        return _mathBlockWidget(node.attributes['expr'] ?? '');
      default:
        return null;
    }
  }

  pw.Widget _renderHeading(md.Element el) {
    final level = int.parse(el.tag.substring(1));
    const sizes = [24.0, 20.0, 17.0, 14.0, 12.0, 11.0];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
      child: pw.Text(
        el.textContent,
        style: pw.TextStyle(font: _fontBold, fontSize: sizes[level - 1]),
      ),
    );
  }

  Future<pw.Widget> _renderParagraph(md.Element el) async {
    final children = el.children ?? [];
    final hasMath =
        children.any((c) => c is md.Element && c.tag == 'math-inline');

    if (!hasMath) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.RichText(text: _buildSpan(el, _baseStyle())),
      );
    }

    // Paragraph with inline math: alternate text runs and math images.
    final parts = <pw.Widget>[];
    for (final child in children) {
      if (child is md.Element && child.tag == 'math-inline') {
        parts.add(await _mathWidget(child.attributes['expr'] ?? '', MathStyle.text));
      } else if (child is md.Text) {
        if (child.text.isNotEmpty) {
          parts.add(pw.Text(child.text, style: _baseStyle()));
        }
      } else if (child is md.Element) {
        parts.add(pw.RichText(text: _buildSpan(child, _baseStyle())));
      }
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Wrap(children: parts),
    );
  }

  pw.Widget _renderCodeBlock(md.Element pre) {
    String code = '';
    if (pre.children != null) {
      final codeEl = pre.children!
          .whereType<md.Element>()
          .cast<md.Element?>()
          .firstWhere((e) => e?.tag == 'code', orElse: () => null);
      code = codeEl?.textContent ?? pre.textContent;
    } else {
      code = pre.textContent;
    }
    if (code.endsWith('\n')) code = code.substring(0, code.length - 1);

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(code, style: pw.TextStyle(font: _fontMono, fontSize: 9)),
    );
  }

  pw.Widget _renderList(md.Element el, {required bool ordered}) {
    final items = <pw.Widget>[];
    int counter = 1;
    for (final child in el.children ?? []) {
      if (child is md.Element && child.tag == 'li') {
        String bullet = ordered ? '$counter.' : '•';
        if (child.children != null) {
          final inputEl = child.children!
              .whereType<md.Element>()
              .cast<md.Element?>()
              .firstWhere((e) => e?.tag == 'input', orElse: () => null);
          if (inputEl != null) {
            bullet = (inputEl.attributes['checked'] == 'true') ? '☑' : '☐';
          }
        }
        items.add(pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                width: 24,
                child: pw.Text(bullet, style: _baseStyle())),
            pw.Expanded(
                child: pw.RichText(
                    text: _buildSpan(child, _baseStyle()))),
          ],
        ));
        counter++;
      }
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: items),
    );
  }

  Future<pw.Widget> _renderBlockquote(md.Element el) async {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding:
          const pw.EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.grey400, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children:
            await _renderNodes(el.children?.cast<md.Node>().toList() ?? []),
      ),
    );
  }

  pw.Widget _renderTable(md.Element el) {
    final headers = <String>[];
    final rows = <List<String>>[];

    for (final child in el.children ?? []) {
      if (child is md.Element) {
        if (child.tag == 'thead') {
          for (final row in child.children ?? []) {
            if (row is md.Element && row.tag == 'tr') {
              for (final cell in row.children ?? []) {
                if (cell is md.Element && cell.tag == 'th') {
                  headers.add(cell.textContent);
                }
              }
            }
          }
        } else if (child.tag == 'tbody') {
          for (final row in child.children ?? []) {
            if (row is md.Element && row.tag == 'tr') {
              final cells = <String>[];
              for (final cell in row.children ?? []) {
                if (cell is md.Element && cell.tag == 'td') {
                  cells.add(cell.textContent);
                }
              }
              rows.add(cells);
            }
          }
        }
      }
    }

    if (headers.isEmpty && rows.isEmpty) return pw.SizedBox.shrink();

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.TableHelper.fromTextArray(
        headers: headers.isEmpty ? null : headers,
        data: rows,
        headerStyle: pw.TextStyle(font: _fontBold, fontSize: 10),
        cellStyle: pw.TextStyle(font: _font, fontSize: 10),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        border: pw.TableBorder.all(color: PdfColors.grey400),
        cellPadding:
            const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Math helpers
  // ---------------------------------------------------------------------------

  /// Renders [tex] as a small inline image, or falls back to red text on error.
  Future<pw.Widget> _mathWidget(String tex, MathStyle style) async {
    try {
      final bytes = await _math.rasterize(tex, style: style);
      return pw.Image(pw.MemoryImage(bytes), height: 18);
    } catch (_) {
      final delim = style == MathStyle.display ? r'$$' : r'$';
      return pw.Text(
        '[formula: $delim$tex$delim]',
        style: _baseStyle().copyWith(color: PdfColors.red700),
      );
    }
  }

  /// Renders a display-math block: centred image with vertical padding.
  Future<pw.Widget> _mathBlockWidget(String tex) async {
    try {
      final bytes =
          await _math.rasterize(tex, style: MathStyle.display, fontSize: 20);
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Center(child: pw.Image(pw.MemoryImage(bytes))),
      );
    } catch (_) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Text(
          r'[formula: $$' '$tex' r'$$]',
          style: _baseStyle().copyWith(color: PdfColors.red700),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Span builder (synchronous — plain text and inline styling only)
  // ---------------------------------------------------------------------------

  pw.TextSpan _buildSpan(md.Node node, pw.TextStyle parentStyle) {
    if (node is md.Text) {
      return pw.TextSpan(text: node.text, style: parentStyle);
    }
    if (node is! md.Element) {
      return pw.TextSpan(text: '', style: parentStyle);
    }
    if (node.tag == 'input' || node.tag == 'math-inline') {
      return pw.TextSpan(text: '', style: parentStyle);
    }

    final style = _spanStyleFor(node.tag, parentStyle);
    final children = node.children;
    if (children == null || children.isEmpty) {
      return pw.TextSpan(text: node.textContent, style: style);
    }
    return pw.TextSpan(
      style: style,
      children: children.map((c) => _buildSpan(c, style)).toList(),
    );
  }

  pw.TextStyle _spanStyleFor(String tag, pw.TextStyle parent) {
    switch (tag) {
      case 'strong':
        return parent.copyWith(font: _fontBold, fontWeight: pw.FontWeight.bold);
      case 'em':
        return parent.copyWith(
            font: _fontItalic, fontStyle: pw.FontStyle.italic);
      case 'code':
        return parent.copyWith(font: _fontMono, color: PdfColors.grey700);
      case 'del':
        return parent.copyWith(decoration: pw.TextDecoration.lineThrough);
      case 'a':
        return parent.copyWith(
            color: PdfColors.blue600,
            decoration: pw.TextDecoration.underline);
      default:
        return parent;
    }
  }

  pw.TextStyle _baseStyle() =>
      pw.TextStyle(font: _font, fontSize: 11, lineSpacing: 1.4);
}
