import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_settings.dart';

import 'src/fwdebug_flutter_inspector.dart';
import 'src/fwdebug_flutter_platform_interface.dart';
import 'src/debug_info_screen.dart';
import 'src/debug_url_screen.dart';

export 'package:talker/talker.dart';
export 'src/fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static var isEnabled = true;
  static var talker = TalkerFlutter.init();
  static var navigatorObserver = TalkerRouteObserver(talker);

  static Widget inspector({
    required Widget child,
    Widget Function(Widget child)? detector,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
  }) {
    if (!isEnabled) {
      return child;
    }

    showPlatform(() {
      FwdebugFlutterPlatform.instance.openUrl((url) {
        FwdebugFlutterInspector.openUrlCallback(url);
      });
      FwdebugFlutterPlatform.instance.registerEntry('👨🏾‍💻  Fwdebug Flutter',
          () {
        FwdebugFlutterInspector.isVisible.value =
            !FwdebugFlutterInspector.isVisible.value;
      });
    });

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
      'url',
      GestureDetector(
        onTap: () {
          showUrlScreen();
        },
        child: const Icon(Icons.link, color: Colors.blue, size: 20),
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
      'inspector',
      GestureDetector(
        onTap: () {
          togglePanel(false);
          toggleInspector();
        },
        child: const Icon(Icons.visibility, color: Colors.blue, size: 20),
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
    showPlatform(() {
      dio.httpClientAdapter = NativeAdapter();
    });

    if (!isEnabled) return;
    dio.interceptors.add(interceptor);
  }

  static Interceptor get interceptor {
    return TalkerDioLogger(
      talker: talker,
      settings: TalkerDioLoggerSettings(
        enabled: isEnabled,
        printRequestHeaders: true,
        printResponseHeaders: true,
        printResponseMessage: true,
      ),
    );
  }

  static ProviderObserver get riverpodObserver {
    return TalkerRiverpodObserver(
      talker: talker,
      settings: TalkerRiverpodLoggerSettings(
        enabled: isEnabled,
      ),
    );
  }

  static debug(String message, {String group = ''}) {
    systemLog(message, level: LogLevel.debug, group: group);
  }

  static info(String message, {String group = ''}) {
    systemLog(message, level: LogLevel.info, group: group);
  }

  static warning(String message, {String group = ''}) {
    systemLog(message, level: LogLevel.warning, group: group);
  }

  static error(String message, {String group = ''}) {
    systemLog(message, level: LogLevel.error, group: group);
  }

  static systemLog(
    String message, {
    LogLevel level = LogLevel.debug,
    String group = '',
  }) {
    showPlatform(() {
      FwdebugFlutterPlatform.instance.systemLog(
        '[${level.name.substring(0, 1).toUpperCase()}] ${group.isNotEmpty ? ('[' + group + '] ') : ''}$message',
      );
    });

    if (!isEnabled) return;
    talker.log(
      group.isNotEmpty ? '[${group}] $message' : message,
      logLevel: level,
    );
  }

  static customLog(
    String message, {
    LogLevel level = LogLevel.debug,
    String group = '',
  }) {
    showPlatform(() {
      FwdebugFlutterPlatform.instance.customLog(
        '[${level.name.substring(0, 1).toUpperCase()}] ${group.isNotEmpty ? ('[' + group + '] ') : ''}$message',
      );
    });

    if (!isEnabled) return;
    final type = TalkerLogType.fromLogLevel(level);
    final data = TalkerLog(
      group.isNotEmpty ? '[${group}] $message' : message,
      key: 'custom',
      title: 'custom',
      logLevel: level,
      pen: talker.settings.getPenByLogKey(type.key),
    );
    talker.logCustom(data);
  }

  static bool registerEntry(String entry, Widget? icon) {
    if (!isEnabled) {
      return false;
    }
    if (icon == null) {
      if (!FwdebugFlutterInspector.registeredEntries
          .any((element) => element.$1 == entry)) {
        return false;
      }
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

  static void registerUrl(String url, [void Function(String url)? callback]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.registeredUrls
        .removeWhere((element) => element.$1 == url);
    FwdebugFlutterInspector.registeredUrls.add((url, callback));
  }

  static openUrl(void Function(String url) callback) {
    showPlatform(() {
      FwdebugFlutterPlatform.instance.openUrl(callback);
    });

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

  static Future<bool> showPlatform(void Function() callback) async {
    if (await FwdebugFlutterPlatform.instance.isEnabled()) {
      callback.call();
      return true;
    }
    return false;
  }
}
