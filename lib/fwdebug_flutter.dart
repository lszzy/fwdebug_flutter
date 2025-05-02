import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fwdebug_flutter/src/debug_url_screen.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'fwdebug_flutter_inspector.dart';
import 'fwdebug_flutter_platform_interface.dart';
import 'src/debug_info_screen.dart';

class FwdebugFlutter {
  static var isEnabled = true;
  static var fwdebugEnabled = true;
  static var talker = TalkerFlutter.init();
  static final navigatorObserver = TalkerRouteObserver(talker);

  static Widget inspector({
    required Widget child,
    Widget Function(Widget child)? detector,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
  }) {
    if (!isEnabled) {
      return child;
    }

    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.openUrl((url) {
        FwdebugFlutterInspector.openUrlCallback(url);
      });
      FwdebugFlutterPlatform.instance.registerEntry('👨🏾‍💻  Fwdebug Flutter',
          () {
        FwdebugFlutterInspector.isVisible.value =
            !FwdebugFlutterInspector.isVisible.value;
      });
    }

    registerEntry(
      'talker',
      GestureDetector(
        onTap: () {
          showTalkerScreen();
        },
        child: const Icon(Icons.bug_report, color: Colors.blue, size: 20),
      ),
    );
    registerEntry(
      'inspector',
      GestureDetector(
        onTap: () {
          togglePanel(false);
          toggleInspector();
        },
        child: const Icon(Icons.visibility, color: Colors.blue, size: 20),
      ),
    );
    registerEntry(
      'info',
      GestureDetector(
        onTap: () {
          showInfoScreen();
        },
        child: const Icon(Icons.perm_device_info, color: Colors.blue, size: 20),
      ),
    );
    registerEntry(
      'url',
      GestureDetector(
        onTap: () {
          showUrlScreen();
        },
        child: const Icon(Icons.link, color: Colors.blue, size: 20),
      ),
    );

    return FwdebugFlutterInspector(
      detector: detector,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  static intercept(Dio dio) {
    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      dio.httpClientAdapter = NativeAdapter();
    }

    if (!isEnabled) return;
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
          printResponseTime: true,
        ),
      ),
    );
  }

  static systemLog(String message) {
    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.systemLog(message);
    }

    if (!isEnabled) return;
    talker.info(message);
  }

  static customLog(String message) {
    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.customLog(message);
    }

    if (!isEnabled) return;
    final data = TalkerLog(
      message,
      key: 'custom',
      title: 'custom',
      logLevel: LogLevel.error,
    );
    talker.logCustom(data);
  }

  static bool registerEntry(String entry, Widget? icon) {
    if (!isEnabled) return false;
    if (icon == null) {
      if (!FwdebugFlutterInspector.registeredEntries
          .any((element) => element.$1 == entry)) return false;
    }
    FwdebugFlutterInspector.registeredEntries
        .removeWhere((element) => element.$1 == entry);
    if (icon != null) {
      FwdebugFlutterInspector.registeredEntries.add((entry, icon));
    }
    if (FwdebugFlutterInspector.panelVisible.value) {
      FwdebugFlutterInspector.panelVisible.value = false;
      FwdebugFlutterInspector.panelVisible.value = true;
    }
    return true;
  }

  static void registerInfo(String name, dynamic Function()? value) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.registeredInfos
        .removeWhere((element) => element.$1 == name);
    if (value != null) {
      FwdebugFlutterInspector.registeredInfos.add((name, value));
    }
  }

  static openUrl(void Function(String url) callback) {
    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.openUrl(callback);
    }

    if (!isEnabled) return;
    FwdebugFlutterInspector.openUrlCallback = callback;
  }

  static toggle([bool? visible]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.isVisible.value =
        visible ?? !FwdebugFlutterInspector.isVisible.value;
  }

  static togglePanel([bool? visible]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.panelVisible.value =
        visible ?? !FwdebugFlutterInspector.panelVisible.value;
  }

  static toggleInspector([bool? visible]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.inspectorVisible.value =
        visible ?? !FwdebugFlutterInspector.inspectorVisible.value;
  }

  static Future showTalkerScreen() async {
    await showScreen((context) => TalkerScreen(talker: talker));
  }

  static Future showInfoScreen() async {
    await showScreen((context) => const DebugInfoScreen());
  }

  static Future showUrlScreen() async {
    await showScreen((context) => const DebugUrlScreen());
  }

  static Future showScreen(WidgetBuilder builder) async {
    if (!isEnabled) return;
    final isVisible = FwdebugFlutterInspector.isVisible.value;
    if (isVisible) {
      togglePanel(false);
      toggle(false);
    }
    await navigatorObserver.navigator?.push(MaterialPageRoute(
      builder: builder,
    ));
    if (isVisible) {
      toggle(true);
    }
  }
}
