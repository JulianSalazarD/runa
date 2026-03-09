import 'package:flutter/material.dart';

/// Visual wrapper for a single content block.
///
/// - Shows a drag handle (≡) and delete (×) button on hover or when selected.
/// - Highlights with a primary border when [isSelected] is true.
/// - [onTap] is called when the user clicks anywhere on the block.
/// - [onDelete] is called when the user presses the "×" button.
/// - [dragIndex] when non-null, wraps the drag handle with
///   [ReorderableDragStartListener] so this block can be reordered inside a
///   [ReorderableListView]. Pass null to hide drag-and-drop (e.g. single block).
class BlockChrome extends StatefulWidget {
  const BlockChrome({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.child,
    this.dragIndex,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Widget child;
  final int? dragIndex;

  @override
  State<BlockChrome> createState() => _BlockChromeState();
}

class _BlockChromeState extends State<BlockChrome> {
  bool _hovered = false;

  Widget _buildDragHandle(ColorScheme colorScheme) {
    final icon = Icon(
      Icons.drag_indicator,
      size: 16,
      color: colorScheme.onSurfaceVariant,
    );
    final idx = widget.dragIndex;
    if (idx == null) return icon;
    return ReorderableDragStartListener(index: idx, child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final showControls = _hovered || widget.isSelected;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.secondaryContainer.withValues(alpha: 0.25)
                : null,
            borderRadius: BorderRadius.circular(6),
            border: widget.isSelected
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle — visible on hover or selection.
              // Wrapped with ReorderableDragStartListener when reordering is
              // enabled (dragIndex != null).
              SizedBox(
                width: 28,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AnimatedOpacity(
                    opacity: showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 120),
                    child: _buildDragHandle(colorScheme),
                  ),
                ),
              ),
              // Content
              Expanded(child: widget.child),
              // Delete button — visible on hover or selection
              AnimatedOpacity(
                opacity: showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, right: 4),
                  child: InkWell(
                    onTap: showControls ? widget.onDelete : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                        semanticLabel: 'Eliminar bloque',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
