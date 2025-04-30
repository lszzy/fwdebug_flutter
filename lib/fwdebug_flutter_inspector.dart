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
  static final List<(String, String Function())> registeredInfos = [];
  static void Function(String url) openUrlCallback = (url) {
    FwdebugFlutter.navigatorObserver.navigator?.pushNamed(url);
  };

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

                  return CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.keyF, alt: true):
                          () => FwdebugFlutter.toggle(),
                      const SingleActivator(LogicalKeyboardKey.keyI, alt: true):
                          () {
                        FwdebugFlutter.togglePanel(false);
                        FwdebugFlutter.toggleInspector();
                      },
                      const SingleActivator(LogicalKeyboardKey.keyT, alt: true):
                          () {
                        FwdebugFlutter.showTalkerScreen();
                      },
                      const SingleActivator(LogicalKeyboardKey.keyD, alt: true):
                          () {
                        FwdebugFlutter.showInfoScreen();
                      },
                      const SingleActivator(LogicalKeyboardKey.keyU, alt: true):
                          () {
                        FwdebugFlutter.showUrlScreen();
                      },
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
                    constraints.maxWidth - 140,
                    constraints.maxHeight - viewPadding.bottom - 140,
                  ),
                  onTap: () {
                    FwdebugFlutter.togglePanel();
                  },
                  onDoubleTap: widget.onDoubleTap ??
                      () {
                        FwdebugFlutter.showTalkerScreen();
                      },
                  onLongPress: widget.onLongPress ??
                      () {
                        FwdebugFlutter.toggle(false);
                      },
                  child: ValueListenableBuilder(
                    valueListenable: FwdebugFlutterInspector.panelVisible,
                    builder: (panelContext, panelVisible, panelChild) {
                      return SizedBox(
                        height: 130,
                        width: 130,
                        child: Stack(
                          children: [
                            Center(
                              child: _buildEntry(
                                50,
                                const Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              ),
                            ),
                            if (panelVisible)
                              ..._buildPanel(
                                130,
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

  List<Widget> _buildPanel(double width, List<Widget> entries) {
    if (entries.isEmpty) {
      return [];
    }

    final size = entries.length;
    final radius = width / 2 - 15;
    final degree = 2 * pi / size;
    final center = Offset(width / 2, width / 2);
    final points = [];
    for (int i = 0; i < size; i++) {
      final d = i * degree;
      final x = center.dx + radius * cos(d);
      final y = center.dy + radius * sin(d);
      points.add(Offset(x, y));
    }

    return List.generate(size, (index) {
      return Positioned.fromRect(
        rect: Rect.fromCenter(
          center: points[index],
          width: 30,
          height: 30,
        ),
        child: _buildEntry(30, entries[index]),
      );
    });
  }

  Widget _buildEntry(double size, Widget child) {
    return Container(
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
        width: size,
        height: size,
        decoration: const ShapeDecoration(
          shape: CircleBorder(),
          color: Colors.white,
        ),
        child: child,
      ),
    );
  }
}
