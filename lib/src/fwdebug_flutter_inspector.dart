import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspector/inspector.dart';

import '../fwdebug_flutter.dart';
import 'draggable_floating_action_button.dart';
import 'multi_long_press_gesture_recognizer.dart';

class FwdebugFlutterInspector extends StatefulWidget {
  static final isVisible = ValueNotifier(false);
  static final inspectorVisible = ValueNotifier(false);
  static final panelVisible = ValueNotifier(false);
  static final List<(String, Widget)> registeredEntries = [];
  static final List<(String, dynamic Function())> registeredInfos = [];
  static final List<(String, void Function(String url)?)> registeredUrls = [];
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

class _FwdebugFlutterInspectorState extends State<FwdebugFlutterInspector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _animation = Tween(begin: 0.5, end: 1.0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FwdebugFlutterInspector.isVisible,
      builder: (valueContext, valueVisible, valueChild) {
        return LayoutBuilder(builder: (layoutContext, constraints) {
          final viewPadding = MediaQuery.paddingOf(context);
          const panelSize = 130.0;
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
                    bindings: kDebugMode
                        ? {
                            const SingleActivator(LogicalKeyboardKey.keyF,
                                alt: true): () => FwdebugFlutter.toggle(),
                            const SingleActivator(LogicalKeyboardKey.keyI,
                                alt: true): () {
                              FwdebugFlutter.togglePanel(false);
                              FwdebugFlutter.toggleInspector();
                            },
                            const SingleActivator(LogicalKeyboardKey.keyT,
                                alt: true): () {
                              FwdebugFlutter.showTalkerScreen();
                            },
                            const SingleActivator(LogicalKeyboardKey.keyD,
                                alt: true): () {
                              FwdebugFlutter.showInfoScreen();
                            },
                            const SingleActivator(LogicalKeyboardKey.keyU,
                                alt: true): () {
                              FwdebugFlutter.showUrlScreen();
                            },
                          }
                        : {},
                    child: RawGestureDetector(
                      gestures: {
                        MultiLongPressGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                                MultiLongPressGestureRecognizer>(
                          () => MultiLongPressGestureRecognizer(
                            pointerThreshold: kDebugMode ? 2 : 3,
                          ),
                          (instance) {
                            instance.onMultiLongPress = (details) {
                              HapticFeedback.mediumImpact();
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
                  minOffset: const Offset(-40, 0),
                  maxOffset: Offset(
                    constraints.maxWidth - panelSize + 40,
                    constraints.maxHeight - panelSize,
                  ),
                  initialOffset: Offset(
                    constraints.maxWidth - panelSize - 10,
                    constraints.maxHeight - viewPadding.bottom - panelSize - 10,
                  ),
                  child: SizedBox(
                    height: panelSize,
                    width: panelSize,
                    child: Stack(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              FwdebugFlutter.togglePanel();
                              if (FwdebugFlutterInspector.panelVisible.value) {
                                _animationController.forward(from: 0);
                              }
                            },
                            onDoubleTap: widget.onDoubleTap ??
                                () async {
                                  if (!(await FwdebugFlutter.showPlatform(() {
                                    FwdebugFlutterPlatform.instance.toggle();
                                  }))) {
                                    FwdebugFlutter.showTalkerScreen();
                                  }
                                },
                            onLongPress: widget.onLongPress ??
                                () {
                                  FwdebugFlutter.toggle(false);
                                },
                            child: _buildEntry(
                              50,
                              const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: FwdebugFlutterInspector.panelVisible,
                          builder: (panelContext, panelVisible, panelChild) {
                            if (!panelVisible ||
                                FwdebugFlutterInspector
                                    .registeredEntries.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return _buildPanel(
                              panelSize,
                              FwdebugFlutterInspector.registeredEntries
                                  .map((e) => e.$2)
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildPanel(double width, List<Widget> entries) {
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

    return RotationTransition(
      turns: _animation,
      child: Stack(
        children: List.generate(size, (index) {
          return Positioned.fromRect(
            rect: Rect.fromCenter(
              center: points[index],
              width: 30,
              height: 30,
            ),
            child: _buildEntry(30, entries[index]),
          );
        }),
      ),
    );
  }

  Widget _buildEntry(double size, Widget child) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            blurRadius: 4,
            color: Colors.black.withAlpha((255.0 * 0.2).round()),
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
