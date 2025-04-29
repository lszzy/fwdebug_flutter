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
  static bool isEnabled = true;
  static var talker = TalkerFlutter.init();
  static final navigatorObserver = TalkerRouteObserver(talker);

  static final ValueNotifier<bool> _inspectorVisible = ValueNotifier(false);
  static final Map<Icon, VoidCallback> _registeredEntries = {};
  static void Function(String url)? _openUrlCallback;

  static Widget inspector({
    required Widget child,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
  }) {
    if (!isEnabled) {
      return child;
    }

    if (Platform.isIOS && kDebugMode) {
      FwdebugFlutterPlatform.instance.registerEntry('👨🏾‍💻  Fwdebug Flutter',
          () {
        _inspectorVisible.value = !_inspectorVisible.value;
      });
    }

    return FwdebugFlutterInspector(
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      visibleNotifier: _inspectorVisible,
      child: child,
    );
  }

  static intercept(Dio dio) {
    if (!isEnabled) return;

    if (Platform.isIOS && kDebugMode) {
      dio.httpClientAdapter = NativeAdapter();
    }

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

  static toggle([bool? visible]) async {
    if (!isEnabled) return;

    _inspectorVisible.value = visible ?? !_inspectorVisible.value;
  }

  static systemLog(String message) async {
    if (!isEnabled) return;

    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.systemLog(message);
    }

    talker.info(message);
  }

  static customLog(String message) async {
    if (!isEnabled) return;

    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.customLog(message);
    }

    final data = TalkerLog(
      message,
      key: 'custom',
      title: 'custom',
      logLevel: LogLevel.error,
    );
    talker.logCustom(data);
  }

  static registerEntry(Icon icon, VoidCallback callback) async {
    if (!isEnabled) return;

    _registeredEntries[icon] = callback;
  }

  static openUrl(void Function(String url) callback) async {
    if (!isEnabled) return;

    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.openUrl(callback);
    }

    _openUrlCallback = callback;
  }
}
