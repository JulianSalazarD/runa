import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'ink_background_painter.dart';
import 'text_element_painter.dart';

// ---------------------------------------------------------------------------
// InkCanvasWidget
// ---------------------------------------------------------------------------

/// Drawing canvas for an [InkBlock].
///
/// Captures raw pointer events and emits completed [Stroke]s or [TextElement]s
/// via [onUpdate]. Renders committed strokes (smoothed), text elements, and
/// the in-progress stroke through separate [CustomPainter]s.
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

  /// Called when a stroke is committed, a stroke is erased, or text elements
  /// are updated.
  final ValueChanged<InkBlock>? onUpdate;

  @override
  State<InkCanvasWidget> createState() => _InkCanvasWidgetState();
}

class _InkCanvasWidgetState extends State<InkCanvasWidget> {
  static const _uuid = Uuid();
  static const _eraserRadius = 20.0;

  List<StrokePoint> _currentPoints = [];

  // Text tool state
  TextElement? _editingElement;
  bool _isNewElement = true;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  BoxConstraints _constraints = const BoxConstraints();

  @override
  void initState() {
    super.initState();
    _textFocusNode.addListener(_onTextFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.removeListener(_onTextFocusChanged);
    _textFocusNode.dispose();
    super.dispose();
  }

  StrokePoint _makePoint(PointerEvent e) => StrokePoint(
        x: e.localPosition.dx,
        y: e.localPosition.dy,
        // If the device doesn't report pressure, e.pressure == 0; fallback 1.0.
        pressure: e.pressure > 0.0 ? e.pressure : 1.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

  void _onPointerDown(PointerDownEvent e) {
    if (widget.activeTool == StrokeTool.text) return;
    setState(() => _currentPoints = [_makePoint(e)]);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (widget.activeTool == StrokeTool.text) return;
    setState(() => _currentPoints = [..._currentPoints, _makePoint(e)]);
  }

  void _onPointerUp(PointerUpEvent e) {
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

  /// Returns `true` when any eraser point is within [_eraserRadius] of any
  /// point belonging to [stroke].
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
  // Text tool handlers
  // ---------------------------------------------------------------------------

  void _handleTextTap(Offset pos) {
    final w = _constraints.maxWidth;
    final h = _constraints.maxHeight;
    if (w <= 0 || h <= 0) return;

    final normX = (pos.dx / w).clamp(0.0, 1.0);
    final normY = (pos.dy / h).clamp(0.0, 1.0);

    // Hit-test existing elements (within 20px logical).
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
      // Delete element if it existed, otherwise cancel.
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
  // Color parsing
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _editingElement != null) {
          setState(() => _editingElement = null);
          _textController.clear();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: SizedBox(
          height: widget.height,
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _constraints = constraints;
                return Stack(
                  children: [
                    CustomPaint(
                      painter: InkBackgroundPainter(
                        background: widget.block.background,
                        spacing: widget.block.backgroundSpacing,
                        lineColor:
                            _parseColorHex(widget.block.backgroundLineColor),
                        defaultColor:
                            Theme.of(context).colorScheme.outlineVariant,
                        backgroundColor:
                            _parseColorHex(widget.block.backgroundColor),
                      ),
                      size: Size(constraints.maxWidth, widget.height),
                    ),
                    CustomPaint(
                      painter: TextElementPainter(
                        elements: widget.block.textElements,
                      ),
                      size: Size(constraints.maxWidth, widget.height),
                    ),
                    CustomPaint(
                      painter: InkPainter(
                        strokes: widget.block.strokes,
                        currentPoints: _currentPoints,
                        activeTool: widget.activeTool,
                      ),
                      size: Size(constraints.maxWidth, widget.height),
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
      ),
    );
  }

  Widget _buildInlineEditor() {
    final el = _editingElement!;
    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(
          minWidth: 40,
          maxWidth: _constraints.maxWidth * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          border: Border.all(
            color: Colors.blueAccent,
            width: 1.5,
          ),
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

/// [CustomPainter] that renders committed [Stroke]s and the in-progress
/// stroke from [currentPoints].
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
    // Draw committed strokes (smoothed).
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser) continue;
      final smoothed = smoother.smooth(stroke.points);
      if (smoothed.length < 2) continue;
      canvas.drawPath(_buildPath(smoothed), _makePaint(stroke));
    }

    // Draw in-progress stroke (raw, no smoothing yet).
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
        // Eraser strokes are never rendered; they remove other strokes.
        break;
      case StrokeTool.text:
        // Text elements are rendered by TextElementPainter, not here.
        break;
    }
    return paint;
  }

  /// Parses `#RRGGBBAA` into a Flutter [Color].
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
