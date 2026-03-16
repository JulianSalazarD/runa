import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:runa/domain/domain.dart';

import 'ink_annotation_layer.dart';

/// Renders a single PDF page ([block.pageIndex]) with an ink annotation layer.
///
/// Multiple [PdfPageBlockView]s sharing the same [block.path] each load the
/// same underlying [PdfDocument]; they are independent widgets so that any
/// block type may be interleaved between pages.
class PdfPageBlockView extends StatefulWidget {
  const PdfPageBlockView({
    super.key,
    required this.block,
    required this.documentPath,
    required this.isSelected,
    this.onUpdate,
    this.activeTool = StrokeTool.pen,
    this.activeColor = '#000000FF',
    this.activeWidth = 3.0,
  });

  final PdfPageBlock block;

  /// Absolute path to the `.runa` file. Used to resolve the relative asset
  /// path stored in [block.path].
  final String documentPath;

  /// When `true`, the [InkAnnotationLayer] accepts pointer input.
  final bool isSelected;

  final ValueChanged<Block>? onUpdate;
  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;

  @override
  State<PdfPageBlockView> createState() => _PdfPageBlockViewState();
}

class _PdfPageBlockViewState extends State<PdfPageBlockView> {
  PdfDocument? _pdf;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(PdfPageBlockView old) {
    super.didUpdateWidget(old);
    if (old.block.path != widget.block.path ||
        old.documentPath != widget.documentPath) {
      _pdf?.dispose();
      _pdf = null;
      setState(() {
        _loading = true;
        _error = null;
      });
      _loadPdf();
    }
  }

  @override
  void dispose() {
    _pdf?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    // documentPath starts as '' during the first build (before initFromDocument
    // fires via addPostFrameCallback). Return early and wait for didUpdateWidget
    // to retry with the real path, keeping the loading indicator visible.
    if (widget.documentPath.isEmpty) return;

    final absolutePath =
        p.join(p.dirname(widget.documentPath), widget.block.path);
    try {
      final doc = await PdfDocument.openFile(absolutePath);
      if (!mounted) {
        await doc.dispose();
        return;
      }
      setState(() {
        _pdf = doc;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: LinearProgressIndicator(),
      );
    }

    if (_error != null) {
      return _PdfPageErrorPlaceholder(
        path: widget.block.path,
        pageIndex: widget.block.pageIndex,
        error: _error!,
      );
    }

    final doc = _pdf!;
    // Use stored dimensions populated at import time.
    // Fall back to 1:1 aspect ratio if dimensions are unavailable.
    final aspectRatio = widget.block.pageWidth > 0 && widget.block.pageHeight > 0
        ? widget.block.pageWidth / widget.block.pageHeight
        : 1.0;
    final pageNumber = widget.block.pageIndex + 1; // 1-based for PdfPageView

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page number label.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              'Página $pageNumber',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          // "Limpiar anotaciones" button (only when strokes exist).
          if (widget.block.strokes.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => widget.onUpdate
                    ?.call(widget.block.copyWith(strokes: const [])),
                icon: const Icon(Icons.clear, size: 14),
                label: const Text(
                  'Limpiar anotaciones',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          // PDF page render + annotation overlay.
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PdfPageView(document: doc, pageNumber: pageNumber),
                InkAnnotationLayer(
                  strokes: widget.block.strokes,
                  onStrokesChanged: (strokes) =>
                      widget.onUpdate?.call(widget.block.copyWith(strokes: strokes)),
                  activeTool: widget.activeTool,
                  activeColor: widget.activeColor,
                  activeWidth: widget.activeWidth,
                  readOnly: !widget.isSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPageErrorPlaceholder extends StatelessWidget {
  const _PdfPageErrorPlaceholder({
    required this.path,
    required this.pageIndex,
    required this.error,
  });

  final String path;
  final int pageIndex;
  final String error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_outlined,
              size: 32, color: colorScheme.outline),
          const SizedBox(height: 4),
          Text(
            'No se pudo abrir página ${pageIndex + 1}: $path',
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            error,
            style: TextStyle(fontSize: 10, color: colorScheme.error),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
