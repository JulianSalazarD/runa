import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

// ---------------------------------------------------------------------------
// Registry — shared numbering state for one render pass
// ---------------------------------------------------------------------------

/// Assigns sequential numbers to footnote IDs in the order they are first
/// referenced. Also tracks how many definitions have been rendered so the
/// first one can insert a divider above.
class FootnoteRegistry {
  final Map<String, int> _map = {};
  int _counter = 0;
  int _defsRendered = 0;

  int numberFor(String id) => _map.putIfAbsent(id, () => ++_counter);

  bool get isFirstDef => _defsRendered == 0;
  void markDefRendered() => _defsRendered++;
}

// ---------------------------------------------------------------------------
// Inline syntax: [^id]
// ---------------------------------------------------------------------------

/// Matches footnote references written as `[^id]` and emits a
/// `footnote-ref` element whose `id` attribute holds the raw identifier.
///
/// The expression is stored as an attribute (not text content) so that
/// flutter_markdown's `_inlines` stack is not left dirty.
class FootnoteInlineSyntax extends md.InlineSyntax {

  FootnoteInlineSyntax() : super(_pat);
  static const _pat = r'\[\^([^\]\n]+)\]';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final id = match[1]!;
    final el = md.Element('footnote-ref', null)..attributes['id'] = id;
    parser.addNode(el);
    return true;
  }
}

// ---------------------------------------------------------------------------
// Block syntax: [^id]: definition text
// ---------------------------------------------------------------------------

/// Matches footnote definitions written as `[^id]: definition text` on their
/// own line. Emits a `footnote-def` element with `id` and `text` attributes.
///
/// The text is stored as an attribute (not as a child text node) so that the
/// builder's `visitText` override is never triggered for block content.
class FootnoteBlockSyntax extends md.BlockSyntax {
  const FootnoteBlockSyntax();

  static final _start = RegExp(r'^\[\^([^\]]+)\]:\s*(.+)$');

  @override
  RegExp get pattern => _start;

  @override
  md.Node? parse(md.BlockParser parser) {
    final m = _start.firstMatch(parser.current.content);
    if (m == null) return null;
    parser.advance();
    return md.Element('footnote-def', null)
      ..attributes['id'] = m[1]!
      ..attributes['text'] = m[2]!;
  }
}

// ---------------------------------------------------------------------------
// Ref builder — renders [^id] as a small superscript-style number
// ---------------------------------------------------------------------------

class FootnoteRefBuilder extends MarkdownElementBuilder {
  FootnoteRefBuilder(this._registry);

  final FootnoteRegistry _registry;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final id = element.attributes['id'];
    if (id == null) return null;
    final n = _registry.numberFor(id);
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      '[$n]',
      style: TextStyle(fontSize: 10, color: colorScheme.primary),
    );
  }
}

// ---------------------------------------------------------------------------
// Def builder — renders [^id]: text as a styled definition row
// ---------------------------------------------------------------------------

class FootnoteDefBuilder extends MarkdownElementBuilder {
  FootnoteDefBuilder(this._registry);

  final FootnoteRegistry _registry;

  @override
  bool isBlockElement() => true;

  /// Required to prevent the `_inlines` assertion — block element text
  /// children must not be pushed onto the inline stack.
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
    final id = element.attributes['id'];
    final text = element.attributes['text'];
    if (id == null || text == null) return null;

    final n = _registry.numberFor(id);
    final colorScheme = Theme.of(context).colorScheme;
    final isFirst = _registry.isFirstDef;
    _registry.markDefRendered();

    final defRow = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$n] ',
            style: TextStyle(fontSize: 12, color: colorScheme.primary),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (isFirst) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          defRow,
        ],
      );
    }
    return defRow;
  }
}

// ---------------------------------------------------------------------------
// FootnoteExtension — bundles all syntaxes and builders
// ---------------------------------------------------------------------------

/// Creates a fresh [FootnoteExtension] for a single render pass.
///
/// Always instantiate this in `build()` so the registry resets each time
/// the widget rebuilds.
///
/// ```dart
/// final footnotes = FootnoteExtension.create();
/// MarkdownBody(
///   inlineSyntaxes: [...footnotes.inlineSyntaxes],
///   blockSyntaxes: [...footnotes.blockSyntaxes],
///   builders: {...footnotes.builders},
/// )
/// ```
class FootnoteExtension {
  FootnoteExtension._() : _registry = FootnoteRegistry();

  factory FootnoteExtension.create() => FootnoteExtension._();

  final FootnoteRegistry _registry;

  List<md.InlineSyntax> get inlineSyntaxes => [FootnoteInlineSyntax()];
  List<md.BlockSyntax> get blockSyntaxes => const [FootnoteBlockSyntax()];
  Map<String, MarkdownElementBuilder> get builders => {
        'footnote-ref': FootnoteRefBuilder(_registry),
        'footnote-def': FootnoteDefBuilder(_registry),
      };
}
