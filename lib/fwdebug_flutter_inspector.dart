import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspector/inspector.dart';

import 'fwdebug_flutter.dart';
import 'src/draggable_floating_action_button.dart';
import 'src/multi_long_press_gesture_recognizer.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  static final isVisible = ValueNotifier(false);
  static final inspectorVisible = ValueNotifier(false);
  static final panelVisible = ValueNotifier(false);
  static final List<(String, Widget)> registeredEntries = [];
  static void Function(String url)? openUrlCallback;

  final Widget Function(Widget child)? detector;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final Widget child;

  const FwdebugFlutterInspector({
    super.key,
    required this.detector,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.child,
  });

  @override
  State<FwdebugFlutterInspector> createState() =>
      _FwdebugFlutterInspectorState();
}

class _FwdebugFlutterInspectorState extends State<FwdebugFlutterInspector> {
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
                builder: (inspectorContext, inspectorVisible, inspectorChild) {
                  final inspector = Inspector(
                    isEnabled: true,
                    isPanelVisible: inspectorVisible,
                    child: inspectorChild!,
                  );
                  if (widget.detector != null) {
                    return widget.detector!(inspector);
                  }

                  List<ShortcutActivator> shortcuts = const [
                    SingleActivator(LogicalKeyboardKey.keyF, alt: true),
                  ];
                  return CallbackShortcuts(
                    bindings: {
                      for (var shortcut in shortcuts)
                        shortcut: () => FwdebugFlutter.toggle(),
                    },
                    child: RawGestureDetector(
                      gestures: {
                        MultiLongPressGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                                MultiLongPressGestureRecognizer>(
                          () => MultiLongPressGestureRecognizer(
                            pointerThreshold: 2,
                          ),
                          (instance) {
                            instance.onMultiLongPress = (details) {
                              HapticFeedback.vibrate();
                              FwdebugFlutter.toggle();
                            };
                          },
                        ),
                      },
                      child: inspector,
                    ),
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
                    FwdebugFlutter.togglePanel();
                  },
                  onDoubleTap: widget.onDoubleTap ??
                      () async {
                        FwdebugFlutter.togglePanel(false);
                        FwdebugFlutter.toggle(false);
                        await FwdebugFlutter.showTalkerScreen();
                        FwdebugFlutter.toggle(true);
                      },
                  onLongPress: widget.onLongPress ??
                      () {
                        FwdebugFlutter.toggle(false);
                      },
                  child: ValueListenableBuilder(
                    valueListenable: FwdebugFlutterInspector.panelVisible,
                    builder: (panelContext, panelVisible, panelChild) {
                      return SizedBox(
                        height: 150,
                        width: 150,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 0,
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.3),
                                    )
                                  ],
                                ),
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
                            ),
                            if (panelVisible)
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
    final degree = 2 * pi / size;
    final c = Offset(width / 2, width / 2);
    final points = [];
    for (int i = 0; i < size; i++) {
      final d = i * degree;
      final x = c.dx + r * cos(d);
      final y = c.dy + r * sin(d);
      points.add(Offset(x, y));
    }

    return List.generate(size, (index) {
      return Positioned.fromRect(
        rect: Rect.fromCenter(
          center: points[index],
          width: 30,
          height: 30,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                spreadRadius: 0,
                blurRadius: 5,
                color: Colors.black.withOpacity(0.3),
              )
            ],
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white,
            ),
            child: entries[index],
          ),
        ),
      );
    });
  }
}
