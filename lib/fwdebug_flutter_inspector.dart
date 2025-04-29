import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';

import 'fwdebug_flutter.dart';
import 'src/draggable_floating_action_button.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  static final ValueNotifier<bool> isVisible = ValueNotifier(false);
  static final ValueNotifier<bool> inspectorVisible = ValueNotifier(false);
  static final Map<Icon, VoidCallback> registeredEntries = {};
  static void Function(String url)? openUrlCallback;

  final bool gestureEntry;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final Widget child;

  const FwdebugFlutterInspector({
    super.key,
    required this.gestureEntry,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.child,
  });

  @override
  State<FwdebugFlutterInspector> createState() =>
      _FwdebugFlutterInspectorState();
}

class _FwdebugFlutterInspectorState extends State<FwdebugFlutterInspector> {
  int _longPressTime = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FwdebugFlutterInspector.isVisible,
      builder: (valueContext, valueVisible, valueChild) {
        return LayoutBuilder(builder: (layoutContext, constraints) {
          final viewPadding = MediaQuery.paddingOf(context);
          return Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: FwdebugFlutterInspector.inspectorVisible,
                builder: (context, visible, child) {
                  if (widget.gestureEntry) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onLongPress: () {
                        final longPressTime =
                            DateTime.now().millisecondsSinceEpoch;
                        if (_longPressTime == 0) {
                          _longPressTime = longPressTime;
                        } else {
                          if (longPressTime - _longPressTime < 2000) {
                            FwdebugFlutter.toggle();
                          }
                          _longPressTime = 0;
                        }
                      },
                      child: Inspector(
                        isEnabled: true,
                        isPanelVisible: visible,
                        child: child!,
                      ),
                    );
                  }

                  return Inspector(
                    isEnabled: true,
                    isPanelVisible: visible,
                    child: child!,
                  );
                },
                child: widget.child,
              ),
              if (valueVisible)
                DraggableFloatingActionButton(
                  scaleFactor: valueVisible ? 1 : 0,
                  topPadding: viewPadding.top,
                  bottomPadding: viewPadding.bottom,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight - viewPadding.bottom,
                  initialOffset: Offset(
                    constraints.maxWidth - 80,
                    constraints.maxHeight - viewPadding.bottom - 80,
                  ),
                  onTap: () {
                    FwdebugFlutter.toggleInspectorPanel();
                  },
                  onDoubleTap: widget.onDoubleTap ??
                      () {
                        FwdebugFlutter.showTalkerScreen();
                      },
                  onLongPress: widget.onLongPress ??
                      () {
                        FwdebugFlutterInspector.isVisible.value = false;
                      },
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
