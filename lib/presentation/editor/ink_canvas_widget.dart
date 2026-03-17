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
    this.stylusOnly = false,
    this.eraserRadius = 20.0,
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

  /// When `true`, only stylus/pen/mouse input draws; touch events are ignored
  /// so the finger can scroll the parent list.
  final bool stylusOnly;

  /// Eraser circle radius in logical pixels.
  final double eraserRadius;

  /// Called when any element is committed, erased, moved, or deleted.
  final ValueChanged<InkBlock>? onUpdate;

  @override
  State<InkCanvasWidget> createState() => _InkCanvasWidgetState();
}

class _InkCanvasWidgetState extends State<InkCanvasWidget> {
  static const _uuid = Uuid();

  // Stroke tool state
  List<StrokePoint> _currentPoints = [];

  // True when the current touch was identified as a palm on pointer-down.
  bool _palmRejected = false;

  // Eraser cursor position (null when eraser is not active or pointer is up).
  Offset? _eraserPosition;

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

  bool _isBlockedTouch(PointerEvent e) =>
      widget.stylusOnly && e.kind == ui.PointerDeviceKind.touch;

  void _onPointerDown(PointerDownEvent e) {
    if (_isBlockedTouch(e)) return;
    // Palm rejection: large-contact touch events are ignored.
    _palmRejected = e.kind == ui.PointerDeviceKind.touch &&
        e.radiusMajor > 15.0;
    if (_palmRejected) return;
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
    if (_isBlockedTouch(e) || _palmRejected) return;
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
    // Minimum distance filter: skip duplicate/near-duplicate points.
    if (_currentPoints.isNotEmpty) {
      final last = _currentPoints.last;
      final dx = e.localPosition.dx - last.x;
      final dy = e.localPosition.dy - last.y;
      if (dx * dx + dy * dy < 1.0) return;
    }
    setState(() {
      _currentPoints = [..._currentPoints, _makePoint(e)];
      if (widget.activeTool == StrokeTool.eraser) {
        _eraserPosition = e.localPosition;
      }
    });
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_isBlockedTouch(e)) return;
    if (_palmRejected) {
      _palmRejected = false;
      _releaseScrollHold();
      return;
    }
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
    _eraserPosition = null;
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
    final simplified = _douglasPeucker(points, 0.5);
    final stroke = Stroke(
      id: _uuid.v4(),
      color: widget.activeColor,
      width: widget.activeWidth,
      tool: widget.activeTool,
      points: simplified,
    );
    widget.onUpdate?.call(
      widget.block.copyWith(strokes: [...widget.block.strokes, stroke]),
    );
  }

  /// Douglas-Peucker polyline simplification.
  /// Removes points that deviate less than [epsilon] px from the simplified line,
  /// preserving start/end and perceptually important detail points.
  static List<StrokePoint> _douglasPeucker(
      List<StrokePoint> pts, double epsilon) {
    if (pts.length < 3) return pts;
    double maxDist = 0;
    int maxIdx = 0;
    final first = pts.first;
    final last = pts.last;
    for (int i = 1; i < pts.length - 1; i++) {
      final d = _perpDist(pts[i], first, last);
      if (d > maxDist) {
        maxDist = d;
        maxIdx = i;
      }
    }
    if (maxDist > epsilon) {
      final left = _douglasPeucker(pts.sublist(0, maxIdx + 1), epsilon);
      final right = _douglasPeucker(pts.sublist(maxIdx), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    }
    return [first, last];
  }

  /// Perpendicular distance from [p] to the line defined by [a] and [b].
  static double _perpDist(StrokePoint p, StrokePoint a, StrokePoint b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final len2 = dx * dx + dy * dy;
    if (len2 < 1e-10) {
      final ex = p.x - a.x;
      final ey = p.y - a.y;
      return math.sqrt(ex * ex + ey * ey);
    }
    final t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2;
    final px = a.x + t * dx;
    final py = a.y + t * dy;
    final ex = p.x - px;
    final ey = p.y - py;
    return math.sqrt(ex * ex + ey * ey);
  }

  void _handleErase(List<StrokePoint> eraserPoints) {
    final newStrokes = _splitByEraser(
        widget.block.strokes, eraserPoints, widget.eraserRadius);
    // Only trigger update when something actually changed.
    bool changed = newStrokes.length != widget.block.strokes.length;
    if (!changed) {
      for (int i = 0; i < newStrokes.length; i++) {
        if (!identical(newStrokes[i], widget.block.strokes[i])) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      widget.onUpdate?.call(widget.block.copyWith(strokes: newStrokes));
    }
  }

  /// Splits strokes point-by-point: erased points are discarded, the
  /// surviving segments before and after the erased region each become
  /// independent [Stroke]s.  A segment needs at least 2 points to survive.
  static List<Stroke> _splitByEraser(
    List<Stroke> strokes,
    List<StrokePoint> eraserPoints,
    double radius,
  ) {
    final r2 = radius * radius;
    final result = <Stroke>[];

    for (final stroke in strokes) {
      var segment = <StrokePoint>[];
      bool anySplit = false;

      for (final sp in stroke.points) {
        bool erased = false;
        for (final ep in eraserPoints) {
          final dx = sp.x - ep.x;
          final dy = sp.y - ep.y;
          if (dx * dx + dy * dy <= r2) {
            erased = true;
            break;
          }
        }

        if (erased) {
          anySplit = true;
          if (segment.length >= 2) {
            result.add(stroke.copyWith(id: _uuid.v4(), points: segment));
          }
          segment = [];
        } else {
          segment.add(sp);
        }
      }

      if (!anySplit) {
        // Nothing was erased — keep the original object (preserves identity).
        result.add(stroke);
      } else if (segment.length >= 2) {
        result.add(stroke.copyWith(id: _uuid.v4(), points: segment));
      }
    }

    return result;
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
          // When stylusOnly, exclude touch so finger events reach the parent
          // scroll recognizer and can scroll the document normally.
          behavior: HitTestBehavior.opaque,
          supportedDevices: widget.stylusOnly
              ? {
                  ui.PointerDeviceKind.stylus,
                  ui.PointerDeviceKind.invertedStylus,
                  ui.PointerDeviceKind.mouse,
                }
              : null,
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
                          eraserPosition: _eraserPosition,
                          eraserRadius: widget.eraserRadius,
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
    this.eraserPosition,
    this.eraserRadius = 20.0,
    StrokeSmoother? smoother,
  }) : smoother = smoother ?? const StrokeSmoother();

  final List<Stroke> strokes;
  final List<StrokePoint> currentPoints;
  final StrokeTool activeTool;
  final ui.Offset? eraserPosition;
  final double eraserRadius;
  final StrokeSmoother smoother;

  @override
  void paint(Canvas canvas, Size size) {
    // Pass 1: highlighters render below all other strokes.
    for (final stroke in strokes) {
      if (stroke.tool != StrokeTool.highlighter) continue;
      final smoothed = smoother.smoothWithPressure(stroke.points);
      if (smoothed.length < 2) continue;
      final color = _parseColor(stroke.color);
      _drawSegments(canvas, smoothed,
          color.withValues(alpha: color.a * 0.30), stroke.width * 5.0,
          taper: false, pressureSensitive: false);
    }

    // Pass 2: all other strokes.
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser ||
          stroke.tool == StrokeTool.highlighter) {
        continue;
      }
      final smoothed = smoother.smoothWithPressure(stroke.points);
      if (smoothed.length < 2) continue;
      _drawStroke(canvas, smoothed, stroke);
    }

    // In-progress preview: smooth the live points for a consistent look.
    if (currentPoints.length >= 2 && activeTool != StrokeTool.eraser) {
      final smoothed = smoother.smoothWithPressure(currentPoints);
      if (smoothed.length >= 2) {
        const previewColor = Color(0xFF888888);
        _drawSegments(canvas, smoothed, previewColor, 1.5,
            taper: false, pressureSensitive: false);
      }
    }

    // Eraser cursor — drawn last so it's always on top.
    _drawEraserCursor(canvas);
  }

  /// Dispatches to the right drawing style per tool.
  void _drawStroke(Canvas canvas, List<SmoothedPoint> pts, Stroke stroke) {
    final color = _parseColor(stroke.color);
    switch (stroke.tool) {
      case StrokeTool.pen:
        _drawRibbon(canvas, pts, color, stroke.width,
            taper: true, pressureSensitive: true, velocitySensitive: true);
      case StrokeTool.pencil:
        // Pencil: slightly transparent ribbon with opacity grain per segment.
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.65), stroke.width * 0.8,
            taper: true, pressureSensitive: true, velocitySensitive: true,
            grainSeed: stroke.id.hashCode);
      case StrokeTool.marker:
        // Two passes — feather edge then solid body.
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.25), stroke.width * 4.2,
            taper: false, pressureSensitive: false);
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.4), stroke.width * 3,
            taper: false, pressureSensitive: false);
      case StrokeTool.fountainPen:
        _drawFountainPen(canvas, pts, color, stroke.width, taper: true);
      case StrokeTool.highlighter:
      case StrokeTool.eraser:
      case StrokeTool.text:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Ribbon polygon — filled outline for pen/pencil variable-width strokes
  // ---------------------------------------------------------------------------

  /// Builds a filled outline polygon (ribbon) from [pts] with variable width
  /// driven by pressure, velocity, and taper.  Adds filled round caps at both
  /// ends via [Canvas.drawCircle].
  ///
  /// This produces smooth width transitions at every point — equivalent to
  /// what professional ink engines (Procreate, GoodNotes) use.
  void _drawRibbon(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
    required bool pressureSensitive,
    bool velocitySensitive = false,
  }) {
    final n = pts.length;
    if (n < 1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;

    // Pre-compute half-widths and perpendicular normals for each point.
    final hw = List<double>.filled(n, 0);
    final normals = List<ui.Offset>.filled(n, ui.Offset.zero);

    for (int i = 0; i < n; i++) {
      // Taper
      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit = (n - 1 - i) < taperN ? (n - 1 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }
      final pFactor = pressureSensitive
          ? 0.3 + 0.7 * math.pow(pts[i].pressure, 0.6)
          : 1.0;
      final vFactor =
          velocitySensitive ? (1.0 - pts[i].velocity * 0.35) : 1.0;
      hw[i] = (baseWidth * pFactor * vFactor * tFactor)
              .clamp(0.3, baseWidth * 2.0) /
          2;

      // Tangent via central difference; fall back to one-sided at endpoints.
      final ui.Offset tangent;
      if (i == 0) {
        tangent = pts[1].offset - pts[0].offset;
      } else if (i == n - 1) {
        tangent = pts[n - 1].offset - pts[n - 2].offset;
      } else {
        tangent = pts[i + 1].offset - pts[i - 1].offset;
      }
      final tLen =
          math.sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);
      if (tLen < 1e-6) {
        normals[i] = i > 0 ? normals[i - 1] : const ui.Offset(0, 1);
      } else {
        normals[i] = ui.Offset(-tangent.dy / tLen, tangent.dx / tLen);
      }
    }

    if (n == 1) {
      canvas.drawCircle(pts[0].offset, hw[0], paint);
      return;
    }

    // Build left and right offset arrays.
    final left = List<ui.Offset>.generate(
        n, (i) => pts[i].offset + normals[i] * hw[i]);
    final right = List<ui.Offset>.generate(
        n, (i) => pts[i].offset - normals[i] * hw[i]);

    // Ribbon: left side forward, right side backward.
    final path = Path()..moveTo(left[0].dx, left[0].dy);
    for (int i = 1; i < n; i++) {
      path.lineTo(left[i].dx, left[i].dy);
    }
    for (int i = n - 1; i >= 0; i--) {
      path.lineTo(right[i].dx, right[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Round caps at start and end.
    canvas.drawCircle(pts[0].offset, hw[0], paint);
    canvas.drawCircle(pts[n - 1].offset, hw[n - 1], paint);
  }

  // ---------------------------------------------------------------------------
  // Segment-based fallback (marker, preview)
  // ---------------------------------------------------------------------------

  /// Draws [pts] as per-segment lines.  Used for the marker tool (flat, blunt)
  /// and the in-progress ghost preview.
  void _drawSegments(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
    required bool pressureSensitive,
    bool velocitySensitive = false,
    int? grainSeed,
  }) {
    final n = pts.length;
    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;
    final rng = grainSeed != null ? math.Random(grainSeed) : null;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n - 1; i++) {
      final p = pts[i];
      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit = (n - 2 - i) < taperN ? (n - 2 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }
      final pFactor =
          pressureSensitive ? 0.3 + 0.7 * math.pow(p.pressure, 0.6) : 1.0;
      final vFactor = velocitySensitive ? (1.0 - p.velocity * 0.35) : 1.0;
      final gFactor = rng != null ? 0.85 + rng.nextDouble() * 0.15 : 1.0;
      paint.color = color.withValues(alpha: color.a * gFactor);
      paint.strokeWidth =
          (baseWidth * pFactor * vFactor * tFactor).clamp(0.3, baseWidth * 2.0);
      canvas.drawLine(p.offset, pts[i + 1].offset, paint);
    }
  }

  // ---------------------------------------------------------------------------
  // Fountain pen — angle-aware calligraphy width
  // ---------------------------------------------------------------------------

  /// Draws a calligraphy-style stroke whose width varies with stroke direction.
  /// A virtual nib at [_kNibAngle] (45°) produces thick strokes perpendicular
  /// to the nib and thin strokes parallel to it, just like a flat calligraphy pen.
  static const _kNibAngle = math.pi / 4; // 45°
  static const _kNibMinWidthFraction = 0.12;

  void _drawFountainPen(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
  }) {
    final n = pts.length;
    if (n < 1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;
    final hw = List<double>.filled(n, 0);
    final normals = List<ui.Offset>.filled(n, ui.Offset.zero);

    for (int i = 0; i < n; i++) {
      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit = (n - 1 - i) < taperN ? (n - 1 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }

      final ui.Offset tangent;
      if (i == 0) {
        tangent = pts[1].offset - pts[0].offset;
      } else if (i == n - 1) {
        tangent = pts[n - 1].offset - pts[n - 2].offset;
      } else {
        tangent = pts[i + 1].offset - pts[i - 1].offset;
      }
      final tLen =
          math.sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);

      double aFactor = _kNibMinWidthFraction;
      if (tLen > 1e-6) {
        final strokeAngle = math.atan2(tangent.dy, tangent.dx);
        aFactor = _kNibMinWidthFraction +
            (1.0 - _kNibMinWidthFraction) *
                math.sin(strokeAngle - _kNibAngle).abs();
      }

      hw[i] =
          (baseWidth * aFactor * tFactor).clamp(0.3, baseWidth * 2.0) / 2;

      if (tLen < 1e-6) {
        normals[i] = i > 0 ? normals[i - 1] : const ui.Offset(0, 1);
      } else {
        normals[i] = ui.Offset(-tangent.dy / tLen, tangent.dx / tLen);
      }
    }

    if (n == 1) {
      canvas.drawCircle(pts[0].offset, hw[0], paint);
      return;
    }

    final left = List<ui.Offset>.generate(
        n, (i) => pts[i].offset + normals[i] * hw[i]);
    final right = List<ui.Offset>.generate(
        n, (i) => pts[i].offset - normals[i] * hw[i]);

    final path = Path()..moveTo(left[0].dx, left[0].dy);
    for (int i = 1; i < n; i++) {
      path.lineTo(left[i].dx, left[i].dy);
    }
    for (int i = n - 1; i >= 0; i--) {
      path.lineTo(right[i].dx, right[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(pts[0].offset, hw[0], paint);
    canvas.drawCircle(pts[n - 1].offset, hw[n - 1], paint);
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  void _drawEraserCursor(Canvas canvas) {
    if (eraserPosition == null) return;
    final fill = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(eraserPosition!, eraserRadius, fill);
    canvas.drawCircle(eraserPosition!, eraserRadius, border);
  }

  @override
  bool shouldRepaint(InkPainter old) =>
      old.strokes != strokes ||
      old.currentPoints != currentPoints ||
      old.eraserPosition != eraserPosition;
}
