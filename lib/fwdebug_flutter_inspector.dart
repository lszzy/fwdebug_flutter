import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  const FwdebugFlutterInspector({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.isPanelVisible = true,
    this.isEnabled,
  });

  final Widget child;
  final bool isPanelVisible;
  final Alignment alignment;
  final bool? isEnabled;

  static FwdebugFlutterInspectorState of(BuildContext context) {
    final FwdebugFlutterInspectorState? result = maybeOf(context);
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts([
      ErrorSummary(
        "Inspector.of() error.",
      ),
      context.describeElement("the context"),
    ]);
  }

  static FwdebugFlutterInspectorState? maybeOf(BuildContext? context) {
    return context?.findAncestorStateOfType<FwdebugFlutterInspectorState>();
  }

  @override
  FwdebugFlutterInspectorState createState() => FwdebugFlutterInspectorState();
}

class FwdebugFlutterInspectorState extends State<FwdebugFlutterInspector> {
  bool _isPanelVisible = false;
  bool get isPanelVisible => _isPanelVisible;

  void togglePanelVisibility() =>
      setState(() => _isPanelVisible = !_isPanelVisible);

  @override
  void initState() {
    _isPanelVisible = widget.isPanelVisible;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FwdebugFlutterInspector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPanelVisible != oldWidget.isPanelVisible) {
      _isPanelVisible = widget.isPanelVisible;
    }
  }

  bool get _isEnabled =>
      (widget.isEnabled == null && !kReleaseMode) ||
      (widget.isEnabled != null && widget.isEnabled!);

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) {
      return widget.child;
    }

    return Stack(
      children: [
        Align(
          alignment: widget.alignment,
          child: widget.child,
        ),
        if (_isPanelVisible)
          const Align(
            alignment: Alignment.centerRight,
            child: InspectorPanel(),
          ),
      ],
    );
  }
}

class InspectorPanel extends StatefulWidget {
  const InspectorPanel({super.key});

  final bool isInspectorEnabled = false;
  final ValueChanged<bool>? onInspectorStateChanged = null;

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  bool _isVisible = true;

  void _toggleVisibility() {
    setState(() => _isVisible = !_isVisible);
  }

  IconData get _visibilityButtonIcon {
    if (_isVisible) return Icons.rocket_launch_rounded;

    return Icons.close;
  }

  @override
  Widget build(BuildContext context) {
    final _height = 16.0;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onDoubleTap: () {
              print(1);
            },
            onLongPress: () {
              print(2);
            },
            child: FloatingActionButton(
              mini: true,
              onPressed: _toggleVisibility,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black54,
              child: Icon(_visibilityButtonIcon),
            ),
          ),
          if (_isVisible) ...[
            const SizedBox(height: 16.0),
          ] else
            SizedBox(height: _height),
        ],
      ),
    );
  }
}
