import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:runa/domain/domain.dart';

import 'ink_annotation_layer.dart';
import 'ink_toolbar_widget.dart';

// ---------------------------------------------------------------------------
// _PdfBlockView
// ---------------------------------------------------------------------------

/// Renders a [PdfBlock] as a column of pages with shared ink toolbar.
///
/// Pages are displayed sequentially at full editor width. Each page has its
/// own [InkAnnotationLayer] for per-page annotations. The ink toolbar is
/// shared across all pages.
///
/// When the PDF is first opened and [block.pages] is empty, page dimensions
/// are read from the document and [onUpdate] is called to populate the model.
class PdfBlockView extends StatefulWidget {
  const PdfBlockView({
    super.key,
    required this.block,
    required this.documentPath,
    required this.isSelected,
    this.onUpdate,
  });

  final PdfBlock block;

  /// Absolute path to the `.runa` file. Used to resolve the relative asset
  /// path stored in [block.path].
  final String documentPath;

  /// When `true`, ink annotation layers accept pointer input.
  final bool isSelected;

  final ValueChanged<Block>? onUpdate;

  @override
  State<PdfBlockView> createState() => _PdfBlockViewState();
}

class _PdfBlockViewState extends State<PdfBlockView> {
  PdfDocument? _pdf;
  bool _loading = true;
  String? _error;

  StrokeTool _activeTool = StrokeTool.pen;
  String _activeColor = '#000000FF';
  double _activeWidth = 3.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(PdfBlockView old) {
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
      // Populate page annotations if this is the first time opening.
      if (widget.block.pages.isEmpty) {
        final pages = List.generate(doc.pages.length, (i) {
          final page = doc.pages[i]; // 0-indexed
          return PdfPageAnnotation(
            pageIndex: i,
            pageWidth: page.width,
            pageHeight: page.height,
          );
        });
        widget.onUpdate?.call(widget.block.copyWith(pages: pages));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool get _hasAnyStrokes =>
      widget.block.pages.any((ann) => ann.strokes.isNotEmpty);

  PdfPageAnnotation? _annotationFor(int pageIndex) {
    try {
      return widget.block.pages.firstWhere((a) => a.pageIndex == pageIndex);
    } catch (_) {
      return null;
    }
  }

  void _clearAllAnnotations() {
    final cleared = widget.block.pages
        .map((a) => a.copyWith(strokes: const []))
        .toList();
    widget.onUpdate?.call(widget.block.copyWith(pages: cleared));
  }

  void _updateAnnotation(PdfPageAnnotation ann) {
    final existingPages = List<PdfPageAnnotation>.from(widget.block.pages);
    final idx = existingPages.indexWhere((a) => a.pageIndex == ann.pageIndex);
    if (idx >= 0) {
      existingPages[idx] = ann;
    } else {
      existingPages.add(ann);
      existingPages.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    }
    widget.onUpdate?.call(widget.block.copyWith(pages: existingPages));
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
      return _PdfErrorPlaceholder(path: widget.block.path);
    }

    final doc = _pdf!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shared ink toolbar.
        InkToolbarWidget(
          activeTool: _activeTool,
          activeColor: _activeColor,
          activeWidth: _activeWidth,
          onToolChanged: (t) => setState(() => _activeTool = t),
          onColorChanged: (c) => setState(() => _activeColor = c),
          onWidthChanged: (w) => setState(() => _activeWidth = w),
        ),
        // "Limpiar todas las anotaciones" button.
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _hasAnyStrokes ? _clearAllAnnotations : null,
            icon: const Icon(Icons.clear_all, size: 14),
            label: const Text(
              'Limpiar todas las anotaciones',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        // One page item per PDF page.
        for (int i = 0; i < doc.pages.length; i++)
          _PdfPageItem(
            document: doc,
            pageIndex: i,
            annotation: _annotationFor(i),
            activeTool: _activeTool,
            activeColor: _activeColor,
            activeWidth: _activeWidth,
            isSelected: widget.isSelected,
            onAnnotationChanged: _updateAnnotation,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _PdfPageItem
// ---------------------------------------------------------------------------

class _PdfPageItem extends StatelessWidget {
  const _PdfPageItem({
    required this.document,
    required this.pageIndex,
    required this.annotation,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
    required this.isSelected,
    required this.onAnnotationChanged,
  });

  final PdfDocument document;

  /// 0-based page index.
  final int pageIndex;

  final PdfPageAnnotation? annotation;
  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;
  final bool isSelected;
  final ValueChanged<PdfPageAnnotation> onAnnotationChanged;

  @override
  Widget build(BuildContext context) {
    // pdfrx pages list is 0-indexed; PdfPageView uses 1-based pageNumber.
    final page = document.pages[pageIndex];
    final pageNumber = pageIndex + 1; // 1-based for display and PdfPageView
    final aspectRatio = page.width / page.height;

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
          // Page render + annotation overlay.
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PdfPageView(
                  document: document,
                  pageNumber: pageNumber,
                ),
                InkAnnotationLayer(
                  strokes: annotation?.strokes ?? const [],
                  onStrokesChanged: (strokes) {
                    final current = annotation ??
                        PdfPageAnnotation(
                          pageIndex: pageIndex,
                          pageWidth: page.width,
                          pageHeight: page.height,
                        );
                    onAnnotationChanged(current.copyWith(strokes: strokes));
                  },
                  activeTool: activeTool,
                  activeColor: activeColor,
                  activeWidth: activeWidth,
                  readOnly: !isSelected,
                ),
              ],
            ),
          ),
          // "Limpiar esta página" button (only when there are strokes).
          if (annotation != null && annotation!.strokes.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    onAnnotationChanged(annotation!.copyWith(strokes: const [])),
                icon: const Icon(Icons.clear, size: 14),
                label: Text(
                  'Limpiar página $pageNumber',
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PdfErrorPlaceholder
// ---------------------------------------------------------------------------

class _PdfErrorPlaceholder extends StatelessWidget {
  const _PdfErrorPlaceholder({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined,
              size: 32, color: colorScheme.outline),
          const SizedBox(height: 4),
          Text(
            'No se pudo abrir: $path',
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
