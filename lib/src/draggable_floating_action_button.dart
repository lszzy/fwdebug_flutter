import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final double scaleFactor;
  final Offset initialOffset;
  final Offset minOffset;
  final Offset maxOffset;
  final Widget child;

  const DraggableFloatingActionButton({
    super.key,
    required this.scaleFactor,
    required this.initialOffset,
    required this.minOffset,
    required this.maxOffset,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  static Offset? _lastOffset;
  final _key = GlobalKey();
  var _isDragging = false;
  var _minOffset = Offset.zero;
  var _maxOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _lastOffset ??= widget.initialOffset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: _lastOffset?.dx ?? 0,
        top: _lastOffset?.dy ?? 0,
        child: Listener(
          onPointerMove: (pointerMoveEvent) => _updatePosition(
            pointerMoveEvent,
            true,
          ),
          onPointerUp: (_) => _onPointerUp(),
          onPointerDown: (_) => HapticFeedback.mediumImpact(),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: widget.scaleFactor,
            child: Container(
              key: _key,
              child: widget.child,
            ),
          ),
        ),
      );

  void _onPointerUp() {
    if (!mounted) return;
    if (_isDragging) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isDragging = false;
      });
    }
  }

  void _setBoundary(_) {
    if (!mounted) return;
    setState(() {
      _minOffset = widget.minOffset;
      _maxOffset = widget.maxOffset;
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent, bool isDragging) {
    if (!mounted) return;
    var newOffsetX = (_lastOffset?.dx ?? 0) + pointerMoveEvent.delta.dx;
    var newOffsetY = (_lastOffset?.dy ?? 0) + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    final newOffset = Offset(newOffsetX, newOffsetY);
    if (newOffset == _lastOffset) return;

    setState(() {
      _lastOffset = Offset(newOffsetX, newOffsetY);
      _isDragging = isDragging;
    });
  }
}
