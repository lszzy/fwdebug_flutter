import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';

import 'fwdebug_flutter.dart';
import 'src/draggable_floating_action_button.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  static final isVisible = ValueNotifier(false);
  static final inspectorVisible = ValueNotifier(false);
  static final entriesCount = ValueNotifier(0);
  static final List<(String, Widget)> registeredEntries = [];
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
                    constraints.maxWidth - 150,
                    constraints.maxHeight - viewPadding.bottom - 150,
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
                  child: ValueListenableBuilder(
                    valueListenable: FwdebugFlutterInspector.entriesCount,
                    builder: (countContext, countValue, countChild) {
                      return SizedBox(
                        height: 150,
                        width: 150,
                        child: Stack(
                          children: [
                            Center(
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
                            ..._buildCircle(
                              150,
                              FwdebugFlutterInspector.registeredEntries
                                  .map((e) => e.$2)
                                  .toList(),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  List<Widget> _buildCircle(double width, List<Widget> entries) {
    if (entries.isEmpty) {
      return [];
    }

    final size = entries.length;
    final r = width / 2 - 20;
    final pDegree = 2 * pi / size;
    final c = Offset(width / 2, width / 2);
    final points = [];
    for (int i = 0; i < size; i++) {
      final d = i * pDegree;
      final x = c.dx + r * cos(d);
      final y = c.dy + r * sin(d);
      points.add(Offset(x, y));
    }
    return List.generate(size, (index) {
      return Positioned.fromRect(
        rect: Rect.fromCenter(
          center: points[index],
          width: 120,
          height: 120,
        ),
        child: entries[index],
      );
    });
  }
}
