import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';

import 'src/draggable_floating_action_button.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final ValueNotifier<bool> visibleNotifier;
  final Widget child;

  const FwdebugFlutterInspector({
    super.key,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.visibleNotifier,
    required this.child,
  });

  @override
  State<FwdebugFlutterInspector> createState() =>
      _FwdebugFlutterInspectorState();
}

class _FwdebugFlutterInspectorState extends State<FwdebugFlutterInspector> {
  static final ValueNotifier<bool> _inspectorVisible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibleNotifier,
      builder: (valueContext, visible, valueChild) {
        return LayoutBuilder(builder: (layoutContext, constraints) {
          final viewPadding = MediaQuery.paddingOf(context);
          return Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: _inspectorVisible,
                builder: (context, visible, child) {
                  return Inspector(
                    isEnabled: true,
                    isPanelVisible: visible,
                    child: child!,
                  );
                },
                child: widget.child,
              ),
              if (widget.visibleNotifier.value)
                DraggableFloatingActionButton(
                  scaleFactor: visible ? 1 : 0,
                  topPadding: viewPadding.top,
                  bottomPadding: viewPadding.bottom,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight - viewPadding.bottom,
                  initialOffset: Offset(
                    constraints.maxWidth - 80,
                    constraints.maxHeight - viewPadding.bottom - 80,
                  ),
                  onTap: () {},
                  onDoubleTap: widget.onDoubleTap,
                  onLongPress: widget.onLongPress,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}
