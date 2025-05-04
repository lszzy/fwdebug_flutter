import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final double scaleFactor;
  final Offset initialOffset;
  final double topPadding;
  final double bottomPadding;
  final double width;
  final double height;
  final Widget child;

  const DraggableFloatingActionButton({
    super.key,
    required this.scaleFactor,
    required this.initialOffset,
    required this.topPadding,
    required this.bottomPadding,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  final _key = GlobalKey();
  late Offset _offset;
  var _isDragging = false;
  var _minOffset = Offset.zero;
  var _maxOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _offset = widget.initialOffset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: _offset.dx,
        top: _offset.dy,
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
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;

    setState(() {
      _minOffset = Offset(0, widget.topPadding);
      _maxOffset = Offset(
        widget.width - size.width,
        widget.height - size.height,
      );
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent, bool isDragging) {
    if (!mounted) return;
    var newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    var newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

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
    if (newOffset == _offset) return;

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
      _isDragging = isDragging;
    });
  }
}
