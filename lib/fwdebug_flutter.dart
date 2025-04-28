import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'fwdebug_flutter_inspector.dart';
import 'fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static var isEnabled = true;

  static var talker = TalkerFlutter.init();

  static final navigatorObserver = TalkerRouteObserver(talker);

  static final ValueNotifier<bool> _fwdebugVisible = ValueNotifier(false);
  static final ValueNotifier<bool> _inspectorVisible = ValueNotifier(false);
  static final Map<String, VoidCallback> _registeredEntries = {};
  static void Function(String url)? _openUrlCallback;

  static Widget inspector({required Widget child}) {
    if (Platform.isIOS && kDebugMode) {
      FwdebugFlutterPlatform.instance
          .registerEntry('👨🏾‍💻  Flutter Inspector', () {
        _inspectorVisible.value = !_inspectorVisible.value;
      });
      FwdebugFlutterPlatform.instance.registerEntry('🎤  Talker Flutter', () {
        navigatorObserver.navigator?.push(MaterialPageRoute(
          builder: (context) => TalkerScreen(talker: talker),
        ));
      });
    }

    return ValueListenableBuilder(
      valueListenable: _fwdebugVisible,
      builder: (context, visible, child) {
        return FwdebugFlutterInspector(
          isEnabled: isEnabled,
          isPanelVisible: visible,
          child: ValueListenableBuilder(
            valueListenable: _inspectorVisible,
            builder: (context, visible, child) {
              return Inspector(
                isEnabled: true,
                isPanelVisible: visible,
                child: child!,
              );
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static intercept(Dio dio) {
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

  static toggle({bool? visible}) async {
    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.toggle(visible: visible);
    }

    _fwdebugVisible.value = !_fwdebugVisible.value;
  }

  static systemLog(String message) async {
    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.systemLog(message);
    }

    talker.info(message);
  }

  static customLog(String message) async {
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

  static registerEntry(String name, VoidCallback callback) async {
    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.registerEntry(name, callback);
    }

    _registeredEntries[name] = callback;
  }

  static openUrl(void Function(String url) callback) async {
    if (Platform.isIOS && kDebugMode) {
      await FwdebugFlutterPlatform.instance.openUrl(callback);
    }

    _openUrlCallback = callback;
  }
}
