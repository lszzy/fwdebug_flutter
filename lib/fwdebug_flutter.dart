import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'fwdebug_flutter_inspector.dart';
import 'fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static var isEnabled = true;
  static var fwdebugEnabled = true;
  static var talker = TalkerFlutter.init();
  static final navigatorObserver = TalkerRouteObserver(talker);

  static Widget inspector({
    required Widget child,
    bool gestureEntry = true,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
  }) {
    if (!isEnabled) {
      return child;
    }

    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.registerEntry('👨🏾‍💻  Fwdebug Flutter',
          () {
        FwdebugFlutterInspector.isVisible.value =
            !FwdebugFlutterInspector.isVisible.value;
      });
    }

    registerEntry(
      'talker',
      GestureDetector(
        onTap: () => FwdebugFlutter.showTalkerScreen(),
        child: const Icon(Icons.speaker),
      ),
    );
    registerEntry(
      'inspector',
      GestureDetector(
        onTap: () => FwdebugFlutter.toggleInspectorPanel(),
        child: const Icon(Icons.insights),
      ),
    );

    return FwdebugFlutterInspector(
      gestureEntry: gestureEntry,
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

  static toggle([bool? visible]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.isVisible.value =
        visible ?? !FwdebugFlutterInspector.isVisible.value;
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

  static registerEntry(String entry, Widget icon) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.registeredEntries
        .removeWhere((element) => element.$1 == entry);
    FwdebugFlutterInspector.registeredEntries.add((entry, icon));
    FwdebugFlutterInspector.entriesCount.value =
        FwdebugFlutterInspector.registeredEntries.length;
  }

  static bool removeEntry(String entry) {
    if (!isEnabled) return false;
    if (!FwdebugFlutterInspector.registeredEntries
        .any((element) => element.$1 == entry)) return false;
    FwdebugFlutterInspector.registeredEntries
        .removeWhere((element) => element.$1 == entry);
    FwdebugFlutterInspector.entriesCount.value =
        FwdebugFlutterInspector.registeredEntries.length;
    return true;
  }

  static openUrl(void Function(String url) callback) {
    if (Platform.isIOS && kDebugMode && fwdebugEnabled) {
      FwdebugFlutterPlatform.instance.openUrl(callback);
    }

    if (!isEnabled) return;
    FwdebugFlutterInspector.openUrlCallback = callback;
  }

  static void showTalkerScreen() {
    if (!isEnabled) return;
    navigatorObserver.navigator?.push(MaterialPageRoute(
      builder: (context) => TalkerScreen(talker: FwdebugFlutter.talker),
    ));
  }

  static toggleInspectorPanel([bool? visible]) {
    if (!isEnabled) return;
    FwdebugFlutterInspector.inspectorVisible.value =
        visible ?? !FwdebugFlutterInspector.inspectorVisible.value;
  }
}
