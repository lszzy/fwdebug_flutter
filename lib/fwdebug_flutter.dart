import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'fwdebug_flutter_platform_interface.dart';

class FwdebugFlutter {
  static var talker = TalkerFlutter.init();

  static final navigatorObserver = TalkerRouteObserver(talker);

  static final ValueNotifier<bool> _inspectorVisible = ValueNotifier(false);

  static Widget inspector({required Widget child}) {
    if (Platform.isIOS) {
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
      valueListenable: _inspectorVisible,
      builder: (context, visible, child) {
        return Inspector(
          isEnabled: true,
          isPanelVisible: visible,
          child: child!,
        );
      },
      child: child,
    );
  }

  static intercept(Dio dio) {
    if (Platform.isIOS) {
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
    if (Platform.isIOS) {
      await FwdebugFlutterPlatform.instance.toggle(visible: visible);
    }
  }

  static systemLog(String message) async {
    if (Platform.isIOS) {
      await FwdebugFlutterPlatform.instance.systemLog(message);
    }

    talker.info(message);
  }

  static customLog(String message) async {
    if (Platform.isIOS) {
      await FwdebugFlutterPlatform.instance.customLog(message);
    }

    final data = TalkerLog(
      message,
      key: 'custom',
      title: 'custom',
      exception: null,
      stackTrace: null,
      pen: AnsiPen()..red(),
      logLevel: LogLevel.error,
    );
    talker.logCustom(data);
  }

  static registerEntry(String name, VoidCallback callback) async {
    if (Platform.isIOS) {
      await FwdebugFlutterPlatform.instance.registerEntry(name, callback);
    }
  }

  static openUrl(void Function(String url) callback) async {
    if (Platform.isIOS) {
      await FwdebugFlutterPlatform.instance.openUrl(callback);
    }
  }
}
