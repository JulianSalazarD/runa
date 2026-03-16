import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'ink_background_painter.dart';
import 'selection_helper.dart';
import 'selection_mode.dart';
import 'selection_overlay_painter.dart';
import 'shape_painter.dart';
import 'text_element_painter.dart';

// ---------------------------------------------------------------------------
// InkCanvasWidget
// ---------------------------------------------------------------------------

/// Drawing canvas for an [InkBlock].
///
/// Captures raw pointer events and dispatches to the active tool:
/// freehand strokes, text placement, geometric shapes, or element selection.
/// Emits the updated [InkBlock] via [onUpdate] after each committed action.
class InkCanvasWidget extends StatefulWidget {
  const InkCanvasWidget({
    super.key,
    required this.block,
    required this.height,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
    this.activeFontSize = 16.0,
    this.textBold = false,
    this.textItalic = false,
    this.activeShapeType,
    this.selectionMode,
    this.onUpdate,
  });

  final InkBlock block;
  final double height;
  final StrokeTool activeTool;

  /// Active color in `#RRGGBBAA` format.
  final String activeColor;

  /// Base stroke width in logical pixels.
  final double activeWidth;

  /// Font size used when placing a new text element.
  final double activeFontSize;

  /// Whether new text elements use bold weight.
  final bool textBold;

  /// Whether new text elements use italic style.
  final bool textItalic;

  /// When non-null, shape drawing mode is active.
  final ShapeType? activeShapeType;

  /// When non-null, selection mode is active (overrides all other tools).
  final SelectionMode? selectionMode;

  /// Called when any element is committed, erased, moved, or deleted.
  final ValueChanged<InkBlock>? onUpdate;

  @override
  State<InkCanvasWidget> createState() => _InkCanvasWidgetState();
}

class _InkCanvasWidgetState extends State<InkCanvasWidget> {
  static const _uuid = Uuid();
  static const _eraserRadius = 20.0;

  // Stroke tool state
  List<StrokePoint> _currentPoints = [];

  // Shape tool state
  Offset? _shapeStart;
  ShapeElement? _previewShape;

  // Text tool state
  TextElement? _editingElement;
  bool _isNewElement = true;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Selection tool state
  Set<String> _selectedIds = {};
  Rect? _selectionPreviewRect;   // rect dragged during rect-selection
  List<Offset> _lassoPoints = []; // path during lasso
  Rect? _selectionBounds;        // pixel bbox of selected elements
  bool _isMovingSelection = false;
  Offset? _moveStartPos;
  Offset _moveDelta = Offset.zero;

  BoxConstraints _constraints = const BoxConstraints();

  // Holds the parent scroll position while a pointer is active on the canvas,
  // preventing the ReorderableListView from scrolling during drawing.
  ScrollHoldController? _scrollHold;

  Size get _canvasSize =>
      Size(_constraints.maxWidth, widget.height);

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(_onTextFocusChanged);
  }

  @override
  void didUpdateWidget(InkCanvasWidget old) {
    super.didUpdateWidget(old);
    // Clear selection state when leaving selection mode.
    if (old.selectionMode != null && widget.selectionMode == null) {
      _clearSelection();
    }
    // Reset in-progress selection when switching between rect / lasso.
    if (old.selectionMode != widget.selectionMode &&
        widget.selectionMode != null) {
      setState(() {
        _selectionPreviewRect = null;
        _lassoPoints = [];
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.removeListener(_onTextFocusChanged);
    _textFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pointer dispatch
  // ---------------------------------------------------------------------------

  void _holdScroll() {
    _scrollHold = Scrollable.maybeOf(context)?.position.hold(() {});
  }

  void _releaseScrollHold() {
    _scrollHold?.cancel();
    _scrollHold = null;
  }

  void _onPointerDown(PointerDownEvent e) {
    _holdScroll();
    if (widget.selectionMode != null) {
      _onSelectionPointerDown(e.localPosition);
      return;
    }
    if (widget.activeShapeType != null) {
      setState(() {
        _shapeStart = e.localPosition;
        _previewShape = null;
      });
      return;
    }
    if (widget.activeTool == StrokeTool.text) return;
    setState(() => _currentPoints = [_makePoint(e)]);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (widget.selectionMode != null) {
      _onSelectionPointerMove(e.localPosition);
      return;
    }
    if (widget.activeShapeType != null) {
      if (_shapeStart != null) {
        setState(
            () => _previewShape = _buildShapeElement(_shapeStart!, e.localPosition));
      }
      return;
    }
    if (widget.activeTool == StrokeTool.text) return;
    setState(() => _currentPoints = [..._currentPoints, _makePoint(e)]);
  }

  void _onPointerUp(PointerUpEvent e) {
    _releaseScrollHold();
    if (widget.selectionMode != null) {
      _onSelectionPointerUp(e.localPosition);
      return;
    }
    if (widget.activeShapeType != null) {
      if (_shapeStart != null) {
        final shape = _buildShapeElement(_shapeStart!, e.localPosition);
        setState(() {
          _shapeStart = null;
          _previewShape = null;
        });
        widget.onUpdate?.call(
          widget.block.copyWith(shapes: [...widget.block.shapes, shape]),
        );
      }
      return;
    }
    if (widget.activeTool == StrokeTool.text) {
      _handleTextTap(e.localPosition);
      return;
    }
    final allPoints = [..._currentPoints, _makePoint(e)];
    _currentPoints = [];
    if (widget.activeTool == StrokeTool.eraser) {
      _handleErase(allPoints);
    } else {
      _commitStroke(allPoints);
    }
  }

  // ---------------------------------------------------------------------------
  // Selection tool
  // ---------------------------------------------------------------------------

  void _onSelectionPointerDown(Offset pos) {
    // If inside current selection bounds, start a move.
    if (_selectionBounds != null &&
        _selectionBounds!.inflate(4).contains(pos)) {
      setState(() {
        _isMovingSelection = true;
        _moveStartPos = pos;
        _moveDelta = Offset.zero;
      });
    } else {
      // Start a new selection — clear previous.
      setState(() {
        _selectedIds = {};
        _selectionBounds = null;
        _isMovingSelection = false;
        _moveDelta = Offset.zero;
        if (widget.selectionMode == SelectionMode.rect) {
          _selectionPreviewRect =
              Rect.fromLTWH(pos.dx, pos.dy, 0, 0);
          _lassoPoints = [];
        } else {
          _lassoPoints = [pos];
          _selectionPreviewRect = null;
        }
      });
    }
  }

  void _onSelectionPointerMove(Offset pos) {
    if (_isMovingSelection) {
      setState(() => _moveDelta = pos - _moveStartPos!);
    } else if (widget.selectionMode == SelectionMode.rect &&
        _selectionPreviewRect != null) {
      final origin = _selectionPreviewRect!.topLeft;
      setState(() => _selectionPreviewRect = Rect.fromPoints(origin, pos));
    } else if (widget.selectionMode == SelectionMode.lasso) {
      setState(() => _lassoPoints = [..._lassoPoints, pos]);
    }
  }

  void _onSelectionPointerUp(Offset pos) {
    if (_isMovingSelection) {
      _commitMove();
    } else {
      _finalizeSelection(pos);
    }
  }

  void _finalizeSelection(Offset upPos) {
    Set<String> selected;
    if (widget.selectionMode == SelectionMode.rect &&
        _selectionPreviewRect != null) {
      selected = SelectionHelper.hitTestRect(
          widget.block, _selectionPreviewRect!, _canvasSize);
    } else if (widget.selectionMode == SelectionMode.lasso &&
        _lassoPoints.length >= 3) {
      selected = SelectionHelper.hitTestLasso(
          widget.block, _lassoPoints, _canvasSize);
    } else {
      selected = {};
    }
    setState(() {
      _selectedIds = selected;
      _selectionPreviewRect = null;
      _lassoPoints = [];
      _selectionBounds = selected.isEmpty
          ? null
          : SelectionHelper.computeBounds(widget.block, selected, _canvasSize);
    });
  }

  void _commitMove() {
    final updated = SelectionHelper.moveSelection(
        widget.block, _selectedIds, _moveDelta, _canvasSize);
    setState(() {
      _isMovingSelection = false;
      _selectionBounds = _selectionBounds?.shift(_moveDelta);
      _moveDelta = Offset.zero;
      _moveStartPos = null;
    });
    if (updated != widget.block) {
      widget.onUpdate?.call(updated);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedIds = {};
      _selectionBounds = null;
      _selectionPreviewRect = null;
      _lassoPoints = [];
      _isMovingSelection = false;
      _moveDelta = Offset.zero;
    });
  }

  // ---------------------------------------------------------------------------
  // Delete selection
  // ---------------------------------------------------------------------------

  void _handleDeleteSelected() {
    if (_selectedIds.isEmpty) return;
    if (_selectedIds.length > 5) {
      final count = _selectedIds.length;
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar selección'),
          content: Text('¿Eliminar $count elementos seleccionados?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) _deleteSelected();
      });
    } else {
      _deleteSelected();
    }
  }

  void _deleteSelected() {
    final updated =
        SelectionHelper.deleteSelection(widget.block, _selectedIds);
    setState(() {
      _selectedIds = {};
      _selectionBounds = null;
    });
    widget.onUpdate?.call(updated);
  }

  // ---------------------------------------------------------------------------
  // Shape tool
  // ---------------------------------------------------------------------------

  ShapeElement _buildShapeElement(Offset start, Offset end) {
    final w = _constraints.maxWidth;
    final h = widget.height;
    if (w <= 0 || h <= 0) {
      return ShapeElement(
        id: _uuid.v4(),
        type: widget.activeShapeType!,
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 0,
        color: widget.activeColor,
        strokeWidth: widget.activeWidth,
      );
    }

    var endX = end.dx;
    var endY = end.dy;

    if (HardwareKeyboard.instance.isShiftPressed) {
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      if (widget.activeShapeType == ShapeType.line) {
        final angle = math.atan2(dy, dx);
        final snapped =
            (angle / (math.pi / 4)).round() * (math.pi / 4);
        final len = math.sqrt(dx * dx + dy * dy);
        endX = start.dx + len * math.cos(snapped);
        endY = start.dy + len * math.sin(snapped);
      } else {
        final side = math.min(dx.abs(), dy.abs());
        endX = start.dx + (dx < 0 ? -side : side);
        endY = start.dy + (dy < 0 ? -side : side);
      }
    }

    return ShapeElement(
      id: _uuid.v4(),
      type: widget.activeShapeType!,
      x1: (start.dx / w).clamp(0.0, 1.0),
      y1: (start.dy / h).clamp(0.0, 1.0),
      x2: (endX / w).clamp(0.0, 1.0),
      y2: (endY / h).clamp(0.0, 1.0),
      color: widget.activeColor,
      strokeWidth: widget.activeWidth,
    );
  }

  // ---------------------------------------------------------------------------
  // Stroke tool
  // ---------------------------------------------------------------------------

  StrokePoint _makePoint(PointerEvent e) => StrokePoint(
        x: e.localPosition.dx,
        y: e.localPosition.dy,
        pressure: e.pressure > 0.0 ? e.pressure : 1.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

  void _commitStroke(List<StrokePoint> points) {
    if (points.isEmpty) return;
    final stroke = Stroke(
      id: _uuid.v4(),
      color: widget.activeColor,
      width: widget.activeWidth,
      tool: widget.activeTool,
      points: points,
    );
    widget.onUpdate?.call(
      widget.block.copyWith(strokes: [...widget.block.strokes, stroke]),
    );
  }

  void _handleErase(List<StrokePoint> eraserPoints) {
    final remaining = widget.block.strokes
        .where((s) => !_intersectsEraser(s, eraserPoints))
        .toList();
    if (remaining.length != widget.block.strokes.length) {
      widget.onUpdate?.call(widget.block.copyWith(strokes: remaining));
    }
  }

  static bool _intersectsEraser(Stroke stroke, List<StrokePoint> eraser) {
    const r2 = _eraserRadius * _eraserRadius;
    for (final ep in eraser) {
      for (final sp in stroke.points) {
        final dx = sp.x - ep.x;
        final dy = sp.y - ep.y;
        if (dx * dx + dy * dy <= r2) return true;
      }
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Text tool
  // ---------------------------------------------------------------------------

  void _handleTextTap(Offset pos) {
    final w = _constraints.maxWidth;
    final h = _constraints.maxHeight;
    if (w <= 0 || h <= 0) return;

    final normX = (pos.dx / w).clamp(0.0, 1.0);
    final normY = (pos.dy / h).clamp(0.0, 1.0);

    final existing = widget.block.textElements.where((TextElement el) {
      final ex = el.x * w;
      final ey = el.y * h;
      return (pos.dx - ex).abs() < 20 && (pos.dy - ey).abs() < 20;
    }).firstOrNull;

    _textController.text = existing?.content ?? '';
    setState(() {
      _isNewElement = existing == null;
      _editingElement = existing ??
          TextElement(
            id: _uuid.v4(),
            x: normX,
            y: normY,
            content: '',
            fontSize: widget.activeFontSize,
            color: widget.activeColor,
            bold: widget.textBold,
            italic: widget.textItalic,
          );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });
  }

  void _onTextFocusChanged() {
    if (!_textFocusNode.hasFocus) _confirmText();
  }

  void _confirmText() {
    if (_editingElement == null) return;
    final content = _textController.text.trim();
    final el = _editingElement!;

    if (content.isEmpty) {
      if (!_isNewElement) {
        final updated = widget.block.textElements
            .where((TextElement e) => e.id != el.id)
            .toList();
        widget.onUpdate?.call(widget.block.copyWith(textElements: updated));
      }
    } else {
      final confirmed = el.copyWith(content: content);
      final List<TextElement> updated;
      if (_isNewElement) {
        updated = [...widget.block.textElements, confirmed];
      } else {
        updated = widget.block.textElements
            .map((TextElement e) => e.id == confirmed.id ? confirmed : e)
            .toList();
      }
      widget.onUpdate?.call(widget.block.copyWith(textElements: updated));
    }

    setState(() => _editingElement = null);
    _textController.clear();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Color? _parseColorHex(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  MouseCursor get _cursor {
    if (widget.selectionMode != null) {
      return _isMovingSelection && _selectionBounds != null
          ? SystemMouseCursors.move
          : SystemMouseCursors.precise;
    }
    if (widget.activeShapeType != null) return SystemMouseCursors.precise;
    return MouseCursor.defer;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // Escape: cancel text edit.
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (_editingElement != null) {
            setState(() => _editingElement = null);
            _textController.clear();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        // Delete / Backspace: delete selected elements.
        if (widget.selectionMode != null && _selectedIds.isNotEmpty) {
          if (event.logicalKey == LogicalKeyboardKey.delete ||
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _handleDeleteSelected();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: _cursor,
        child: GestureDetector(
          // Compete in the gesture arena for vertical drags so the parent
          // ReorderableListView cannot start a scroll while the user draws.
          // Empty handlers are enough to claim the gesture and reject the
          // parent's scroll recognizer.
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) {},
          onVerticalDragUpdate: (_) {},
          onVerticalDragEnd: (_) {},
          child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: (_) => _releaseScrollHold(),
          child: SizedBox(
            height: widget.height,
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _constraints = constraints;
                  final size = Size(constraints.maxWidth, widget.height);
                  return Stack(
                    children: [
                      CustomPaint(
                        painter: InkBackgroundPainter(
                          background: widget.block.background,
                          spacing: widget.block.backgroundSpacing,
                          lineColor: _parseColorHex(
                              widget.block.backgroundLineColor),
                          defaultColor:
                              Theme.of(context).colorScheme.outlineVariant,
                          backgroundColor:
                              _parseColorHex(widget.block.backgroundColor),
                        ),
                        size: size,
                      ),
                      CustomPaint(
                        painter: ShapePainter(
                          shapes: widget.block.shapes,
                          previewShape: _previewShape,
                        ),
                        size: size,
                      ),
                      CustomPaint(
                        painter: TextElementPainter(
                          elements: widget.block.textElements,
                        ),
                        size: size,
                      ),
                      CustomPaint(
                        painter: InkPainter(
                          strokes: widget.block.strokes,
                          currentPoints: _currentPoints,
                          activeTool: widget.activeTool,
                        ),
                        size: size,
                      ),
                      // Selection overlay — topmost layer.
                      if (widget.selectionMode != null)
                        CustomPaint(
                          painter: SelectionOverlayPainter(
                            selectionRect: _selectionPreviewRect,
                            lassoPoints: _lassoPoints,
                            selectedBounds: _selectionBounds,
                            moveDelta: _moveDelta,
                          ),
                          size: size,
                        ),
                      if (_editingElement != null)
                        Positioned(
                          left: (_editingElement!.x * constraints.maxWidth)
                              .clamp(0.0, constraints.maxWidth - 10),
                          top: (_editingElement!.y * widget.height)
                              .clamp(0.0, widget.height - 10),
                          child: _buildInlineEditor(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          ),  // Listener
        ),    // GestureDetector
      ),      // MouseRegion
    );
  }

  Widget _buildInlineEditor() {
    final el = _editingElement!;
    // Use the canvas background if set, otherwise fall back to the theme surface.
    final canvasBg = _parseColorHex(widget.block.backgroundColor) ??
        Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.primary;
    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(
          minWidth: 40,
          maxWidth: _constraints.maxWidth * 0.8,
        ),
        decoration: BoxDecoration(
          color: canvasBg.withValues(alpha: 0.92),
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          style: TextStyle(
            fontSize: el.fontSize,
            fontWeight: el.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: el.italic ? FontStyle.italic : FontStyle.normal,
            color: _parseColorHex(el.color) ?? Colors.black,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (_) => _confirmText(),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// InkPainter
// ---------------------------------------------------------------------------

/// [CustomPainter] that renders committed [Stroke]s and the in-progress stroke.
class InkPainter extends CustomPainter {
  const InkPainter({
    required this.strokes,
    required this.currentPoints,
    required this.activeTool,
    StrokeSmoother? smoother,
  }) : smoother = smoother ?? const StrokeSmoother();

  final List<Stroke> strokes;
  final List<StrokePoint> currentPoints;
  final StrokeTool activeTool;
  final StrokeSmoother smoother;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser) continue;
      final smoothed = smoother.smooth(stroke.points);
      if (smoothed.length < 2) continue;
      canvas.drawPath(_buildPath(smoothed), _makePaint(stroke));
    }

    if (currentPoints.length >= 2 && activeTool != StrokeTool.eraser) {
      final rawOffsets =
          currentPoints.map((p) => ui.Offset(p.x, p.y)).toList();
      final preview = Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(_buildPath(rawOffsets), preview);
    }
  }

  Path _buildPath(List<ui.Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  Paint _makePaint(Stroke stroke) {
    final color = _parseColor(stroke.color);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (stroke.tool) {
      case StrokeTool.pen:
        paint.color = color;
        paint.strokeWidth = stroke.width;
      case StrokeTool.pencil:
        paint.color = color.withValues(alpha: color.a * 0.6);
        paint.strokeWidth = stroke.width * 0.8;
      case StrokeTool.marker:
        paint.color = color.withValues(alpha: color.a * 0.4);
        paint.strokeWidth = stroke.width * 3;
      case StrokeTool.eraser:
        break;
      case StrokeTool.text:
        break;
    }
    return paint;
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  bool shouldRepaint(InkPainter old) =>
      old.strokes != strokes || old.currentPoints != currentPoints;
}
